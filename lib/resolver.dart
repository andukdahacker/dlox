import 'package:dlox/dlox.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/intepreter.dart';
import 'package:dlox/stmt.dart';

import 'token.dart';

enum FunctionType { function, none }

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
        if (value.state != VariableState.isResolved) {
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
}
