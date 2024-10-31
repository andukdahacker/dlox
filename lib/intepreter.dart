import 'package:dlox/dlox.dart';

import 'expr.dart';
import 'token.dart';
import 'token_type_enum.dart';

class Interpreter implements ExprVisitor<Object?> {
  void interpret(Expr expr) {
    try {
      final value = _evaluate(expr);
      print(value.toString());
    } on RuntimeError catch (e) {
      LoxErrorHandler.instance.runtimeError(e);
    }
  }

  Object? _evaluate(Expr expr) {
    return expr.accept(this);
  }

  @override
  Object? visitBinaryExpr(Binary expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.minus:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) - (right as double);
      case TokenType.slash:
        _checkNumberOperands(expr.operator, left, right);
        if ((right as double) == 0) {
          throw RuntimeError(
              token: expr.operator, message: 'Cannot divide by zero');
        }
        return (left as double) / (right);
      case TokenType.star:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);
      case TokenType.plus:
        if (left is String && right is String) {
          return left + right;
        }
        if (left is double && right is double) {
          return left + right;
        }

        if (left is String || right is String) {
          return left.toString() + right.toString();
        }

        throw RuntimeError(
          token: expr.operator,
          message: 'Operands must be two numbers or two strings',
        );
      case TokenType.greater:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) > (right as double);
      case TokenType.greateEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.less:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) < (right as double);
      case TokenType.lessEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.bangEqual:
        return !_isEqual(left, right);
      case TokenType.equalEqual:
        return _isEqual(left, right);
      default:
        return null;
    }
  }

  @override
  Object? visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.minus:
        _checkNumberOperand(expr.operator, right);
        return -(right as double);
      case TokenType.bang:
        return !_isTruthy(right);
      default:
        return null;
    }
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return;

    throw RuntimeError(token: operator, message: 'Operand must be a number');
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is double && right is double) return;

    throw RuntimeError(token: operator, message: 'Operand must be a numbers');
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
}

class RuntimeError implements Exception {
  final Token token;
  final String message;

  RuntimeError({required this.token, required this.message});
}
