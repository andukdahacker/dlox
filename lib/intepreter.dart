import 'package:dlox/dlox.dart';
import 'package:dlox/environment.dart';
import 'package:dlox/lox_callable.dart';
import 'package:dlox/lox_function.dart';
import 'package:dlox/return.dart';
import 'package:dlox/stmt.dart';

import 'expr.dart';
import 'token.dart';
import 'token_type_enum.dart';

class Interpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  final Environment globals = Environment();

  late Environment _environment = globals;

  Interpreter() {
    globals.define(
      Token(type: TokenType.identifier, lexeme: 'clock', line: -1),
      ClockNativeCallable(),
    );
  }

  void interpret(List<Stmt> statements) {
    try {
      for (final stmt in statements) {
        _execute(stmt);
      }
    } on RuntimeError catch (e) {
      LoxErrorHandler.instance.runtimeError(e);
    } on UninitializedError catch (e) {
      LoxErrorHandler.instance.error(e.token, 'Uninitialized variable');
    }
  }

  void _execute(Stmt stmt) {
    stmt.accept(this);
  }

  Object? _evaluate(Expr expr) {
    return expr.accept(this);
  }

  @override
  Object? visitBinaryExpr(BinaryExpr expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.minus:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) - (right as num);
      case TokenType.slash:
        _checkNumberOperands(expr.operator, left, right);
        if ((right as num) == 0) {
          throw RuntimeError(
              token: expr.operator, message: 'Cannot divide by zero');
        }
        return (left as num) / (right);
      case TokenType.star:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) * (right as num);
      case TokenType.plus:
        if (left is String && right is String) {
          return left + right;
        }
        if (left is num && right is num) {
          return left + right;
        }

        if (left is String || right is String) {
          return left.toString() + right.toString();
        }

        throw RuntimeError(
          token: expr.operator,
          message: 'Operands must be either a string or a number',
        );
      case TokenType.greater:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) > (right as num);
      case TokenType.greateEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) >= (right as num);
      case TokenType.less:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) < (right as num);
      case TokenType.lessEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) <= (right as num);
      case TokenType.bangEqual:
        return !_isEqual(left, right);
      case TokenType.equalEqual:
        return _isEqual(left, right);
      default:
        return null;
    }
  }

  @override
  Object? visitGroupingExpr(GroupingExpr expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(LiteralExpr expr) {
    return expr.value;
  }

  @override
  Object? visitUnaryExpr(UnaryExpr expr) {
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.minus:
        _checkNumberOperand(expr.operator, right);
        return -(right as num);
      case TokenType.bang:
        return !_isTruthy(right);
      default:
        return null;
    }
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is num) return;

    throw RuntimeError(token: operator, message: 'Operand must be a number');
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is num && right is num) return;

    throw RuntimeError(token: operator, message: 'Operand must be numbers');
  }

  bool _isEqual(Object? a, Object? b) {
    if (a == null && b == null) {
      return true;
    }

    if (a == null || b == null) {
      return false;
    }

    if (a.runtimeType == b.runtimeType) {
      return a == b;
    }

    return false;
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;

    return true;
  }

  @override
  void visitExpressionStmt(ExpressionStmt stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(PrintStmt stmt) {
    final value = _evaluate(stmt.expression);

    print(value.toString());
  }

  @override
  void visitVarStmt(VarStmt stmt) {
    Object? value;

    if (stmt.initializer != null) {
      value = _evaluate(stmt.initializer!);
    }

    _environment.define(stmt.name, value);
  }

  @override
  Object? visitVariableExpr(VariableExpr expr) {
    return _environment.getVar(expr.name);
  }

  @override
  Object? visitAssignExpr(AssignExpr expr) {
    final value = _evaluate(expr.value);

    _environment.assign(expr.name, value);

    return value;
  }

  @override
  void visitBlockStmt(BlockStmt stmt) {
    executeBlock(stmt.statements, Environment(enclosing: _environment));
  }

  void executeBlock(List<Stmt> statements, Environment environment) {
    final previousEnv = _environment;

    try {
      _environment = environment;

      for (final stmt in statements) {
        _execute(stmt);
      }
    } finally {
      _environment = previousEnv;
    }
  }

  @override
  void visitIfStmt(IfStmt stmt) {
    if (_isTruthy(_evaluate(stmt.condition))) {
      _execute(stmt.thenBranch);
    } else if (stmt.elseBranch != null) {
      _execute(stmt.elseBranch!);
    }
  }

  @override
  Object? visitLogicalExpr(LogicalExpr expr) {
    final left = _evaluate(expr.left);

    if (expr.operator.type == TokenType.or) {
      if (_isTruthy(left)) return left;
    } else {
      if (!_isTruthy(left)) return left;
    }

    return _evaluate(expr.right);
  }

  @override
  void visitWhileStmt(WhileStmt stmt) {
    while (_isTruthy(_evaluate(stmt.condition))) {
      _execute(stmt.body);
    }
  }

  @override
  Object? visitCallExpr(CallExpr expr) {
    final callee = _evaluate(expr.callee);

    final List<Object?> arguments = [];

    for (final args in expr.arguments ?? []) {
      arguments.add(_evaluate(args));
    }

    if (callee is! LoxCallable) {
      throw RuntimeError(
          token: expr.paren, message: 'Can only call functions and classes');
    }

    if (arguments.length != callee.arity()) {
      throw RuntimeError(
        token: expr.paren,
        message:
            'Expected ${callee.arity()} arguments but got ${arguments.length}.',
      );
    }

    return callee.call(this, arguments);
  }

  @override
  void visitFunctionStmt(FunctionStmt stmt) {
    final function = LoxFunction(declaration: stmt, closure: _environment);

    _environment.define(stmt.name, function);

    if (function.arity() == 0) {
      function.call(this, []);
    }
  }

  @override
  void visitReturnStmt(ReturnStmt stmt) {
    Object? value;

    if (stmt.value != null) {
      value = _evaluate(stmt.value!);
    }

    throw Return(value);
  }

  @override
  Object? visitLambdaExpr(LambdaExpr expr) {
    return LoxFunction(
      declaration: FunctionStmt(
        name: Token(
          type: TokenType.identifier,
          lexeme: expr.hashCode.toString(),
          line: -1,
        ),
        parameters: expr.parameters,
        body: expr.body,
      ),
      closure: _environment,
    );
  }
}

class RuntimeError implements Exception {
  final Token token;
  final String message;

  RuntimeError({required this.token, required this.message});
}

class ClockNativeCallable implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().microsecondsSinceEpoch;
  }

  @override
  String toString() {
    return '<native fn>';
  }
}
