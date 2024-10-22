import 'package:dlox/token.dart';

sealed class Expr {}

class Binary extends Expr {
  final Expr left;

  final Token operator;

  final Expr right;

  Binary({
    required this.left,
    required this.operator,
    required this.right,
  });
}

class Grouping extends Expr {
  final Expr expression;

  Grouping({
    required this.expression,
  });
}

class Literal extends Expr {
  final Object value;

  Literal({
    required this.value,
  });
}

class Unary extends Expr {
  final Token operator;

  final Expr right;

  Unary({
    required this.operator,
    required this.right,
  });
}
