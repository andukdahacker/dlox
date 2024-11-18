import 'package:dlox/dlox.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/intepreter.dart';
import 'package:dlox/stmt.dart';
import 'package:dlox/token_type_enum.dart';

import 'token.dart';

enum FunctionType { function, method, initializer, none }

enum ClassType { tClass, subclass, none }

enum VariableState { isDeclared, isDefined, isResolved }

class VariableInfo {
  final Token token;
  final VariableState state;

  VariableInfo({required this.token, required this.state});
}

class Resolver implements ExprVisitor<void>, StmtVisitor<void> {
  final Interpreter _interpreter;
  final List<Map<String, VariableInfo>> _scopes = [];
  FunctionType _currentFunction = FunctionType.none;
  ClassType _currentClass = ClassType.none;

  Resolver(this._interpreter);

  @override
  void visitBlockStmt(BlockStmt stmt) {
    _beginScope();
    resolveListStmt(stmt.statements);
    _endScope();
  }

  void resolveListStmt(List<Stmt> stmts) {
    for (final stmt in stmts) {
      _resolveStmt(stmt);
    }
  }

  void _resolveStmt(Stmt stmt) {
    stmt.accept(this);
  }

  void _resolveExpr(Expr expr) {
    expr.accept(this);
  }

  void _beginScope() {
    _scopes.add({});
  }

  void _endScope() {
    final last = _scopes.last;
    last.forEach(
      (key, value) {
        if (value.state != VariableState.isResolved &&
            value.token.type != TokenType.tThis) {
          LoxErrorHandler.instance
              .error(value.token, 'Variable is defined but not used');
        }
      },
    );
    _scopes.removeLast();
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    _declare(stmt.name);
    if (stmt.initializer != null) {
      _resolveExpr(stmt.initializer!);
    }
    _define(stmt.name);
  }

  void _declare(Token token) {
    if (_scopes.isEmpty) return;

    final scope = _scopes.last;

    if (scope.containsKey(token.lexeme)) {
      LoxErrorHandler.instance
          .error(token, 'Already variable with this name in this scope');
    }

    scope.addAll({
      token.lexeme: VariableInfo(token: token, state: VariableState.isDeclared)
    });
  }

  void _define(Token token) {
    if (_scopes.isEmpty) return;
    _scopes.last.addAll({
      token.lexeme: VariableInfo(token: token, state: VariableState.isDefined)
    });
  }

  @override
  void visitVariableExpr(VariableExpr expr) {
    if (_scopes.isNotEmpty &&
        _scopes.last[expr.name.lexeme]?.state == VariableState.isDeclared) {
      LoxErrorHandler.instance.error(
          expr.name, 'Cannot read local variable in its own initializer');
    }

    _resolveLocal(expr, expr.name);
  }

  void _resolveLocal(Expr expr, Token token) {
    for (var i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(token.lexeme)) {
        _scopes[i][token.lexeme] =
            VariableInfo(token: token, state: VariableState.isResolved);
        _interpreter.resolve(expr, _scopes.length - 1 - i);
        return;
      }
    }
  }

  @override
  void visitAssignExpr(AssignExpr expr) {
    _resolveExpr(expr.value);
    _resolveLocal(expr, expr.name);
  }

  @override
  void visitFunctionStmt(FunctionStmt stmt) {
    _declare(stmt.name);
    _define(stmt.name);
    _resolveFunction(stmt, FunctionType.function);
  }

  void _resolveFunction(FunctionStmt stmt, FunctionType type) {
    FunctionType enclosingFunction = _currentFunction;
    _currentFunction = type;
    _beginScope();
    for (final param in stmt.parameters ?? []) {
      _declare(param);
      _define(param);
    }

    resolveListStmt(stmt.body);
    _endScope();
    _currentFunction = enclosingFunction;
  }

  @override
  void visitBinaryExpr(BinaryExpr expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitCallExpr(CallExpr expr) {
    _resolveExpr(expr.callee);
    for (final arg in expr.arguments ?? []) {
      _resolveExpr(arg);
    }
  }

  @override
  void visitExpressionStmt(ExpressionStmt stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitGroupingExpr(GroupingExpr expr) {
    _resolveExpr(expr.expression);
  }

  @override
  void visitIfStmt(IfStmt stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.thenBranch);

    if (stmt.elseBranch != null) _resolveStmt(stmt.elseBranch!);
  }

  @override
  void visitLambdaExpr(LambdaExpr expr) {
    _beginScope();
    for (final param in expr.parameters ?? []) {
      _declare(param);
      _define(param);
    }
    resolveListStmt(expr.body);
    _endScope();
  }

  @override
  void visitLiteralExpr(LiteralExpr expr) {}

  @override
  void visitLogicalExpr(LogicalExpr expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitPrintStmt(PrintStmt stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(ReturnStmt stmt) {
    if (_currentFunction == FunctionType.none) {
      LoxErrorHandler.instance
          .error(stmt.keyword, 'Cannot return from top-level code');
    }
    if (stmt.value != null) {
      if (_currentFunction == FunctionType.initializer) {
        LoxErrorHandler.instance
            .error(stmt.keyword, 'Cannot return a value from an initializer');
      }
      _resolveExpr(stmt.value!);
    }
  }

  @override
  void visitUnaryExpr(UnaryExpr expr) {
    _resolveExpr(expr.right);
  }

  @override
  void visitWhileStmt(WhileStmt stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.body);
  }

  @override
  void visitClassStmt(ClassStmt stmt) {
    ClassType enclosingClass = _currentClass;
    _currentClass = ClassType.tClass;
    _declare(stmt.name);
    _define(stmt.name);

    if (stmt.superclass != null) {
      if (stmt.superclass?.name.lexeme == stmt.name.lexeme) {
        LoxErrorHandler.instance
            .error(stmt.superclass!.name, 'A class cannot inherit from itself');
      } else {
        _currentClass = ClassType.subclass;
        _resolveExpr(stmt.superclass!);
        _beginScope();
        _scopes.last['super'] = VariableInfo(
            token: stmt.superclass!.name, state: VariableState.isResolved);
      }
    }

    _beginScope();
    _scopes.last.addAll({
      'this': VariableInfo(
        token:
            Token(type: TokenType.tThis, lexeme: 'this', line: stmt.name.line),
        state: VariableState.isDefined,
      )
    });

    for (final method in stmt.methods) {
      FunctionType declaration = FunctionType.method;

      if (method.name.lexeme == 'init') {
        declaration = FunctionType.initializer;
      }

      _resolveFunction(method, declaration);
    }

    if (stmt.superclass != null) {
      _endScope();
    }

    _endScope();
    _currentClass = enclosingClass;
  }

  @override
  void visitGetExpr(GetExpr expr) {
    _resolveExpr(expr.object);
  }

  @override
  void visitSetExpr(SetExpr expr) {
    _resolveExpr(expr.value);
    _resolveExpr(expr.object);
  }

  @override
  void visitThisExpr(ThisExpr expr) {
    if (_currentClass == ClassType.none) {
      LoxErrorHandler.instance.error(
          expr.keyword, 'Cannot use \'this\' keyword outside of a class');
    }
    _resolveLocal(expr, expr.keyword);
  }

  @override
  void visitSuperExpr(SuperExpr expr) {
    if (_currentClass == ClassType.none) {
      LoxErrorHandler.instance
          .error(expr.keyword, 'Cannot use super outside of a class');
    } else if (_currentClass == ClassType.subclass) {
      LoxErrorHandler.instance.error(
          expr.keyword, 'Cannot use super in a class with no superclass');
    }
    _resolveLocal(expr, expr.keyword);
  }
}
