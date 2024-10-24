import 'package:dlox/token.dart';

sealed class Expr<T> {
  T accept(ExprVisitor<T> visitor);
}

abstract class ExprVisitor<T> {
  T visitBinaryExpr(Binary expr);

  T visitGroupingExpr(Grouping expr);

  T visitLiteralExpr(Literal expr);

  T visitUnaryExpr(Unary expr);
}

class Binary<T> extends Expr<T> {
  final Expr left;

  final Token operator;

  final Expr right;

  Binary({
    required this.left,
    required this.operator,
    required this.right,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class Grouping<T> extends Expr<T> {
  final Expr expression;

  Grouping({
    required this.expression,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class Literal<T> extends Expr<T> {
  final Object? value;

  Literal({
    required this.value,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class Unary<T> extends Expr<T> {
  final Token operator;

  final Expr right;

  Unary({
    required this.operator,
    required this.right,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}
