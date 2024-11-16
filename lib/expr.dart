import 'package:dlox/token.dart';

import 'stmt.dart';

sealed class Expr<T> {
  T accept(ExprVisitor<T> visitor);
}

abstract class ExprVisitor<T> {
  T visitAssignExpr(AssignExpr expr);

  T visitBinaryExpr(BinaryExpr expr);

  T visitCallExpr(CallExpr expr);

  T visitLambdaExpr(LambdaExpr expr);

  T visitGroupingExpr(GroupingExpr expr);

  T visitLiteralExpr(LiteralExpr expr);

  T visitLogicalExpr(LogicalExpr expr);

  T visitUnaryExpr(UnaryExpr expr);

  T visitVariableExpr(VariableExpr expr);

  T visitGetExpr(GetExpr expr);

  T visitSetExpr(SetExpr expr);

  T visitThisExpr(ThisExpr expr);
}

class AssignExpr<T> extends Expr<T> {
  final Token name;

  final Expr value;

  AssignExpr({
    required this.name,
    required this.value,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitAssignExpr(this);
  }
}

class BinaryExpr<T> extends Expr<T> {
  final Expr left;

  final Token operator;

  final Expr right;

  BinaryExpr({
    required this.left,
    required this.operator,
    required this.right,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class CallExpr<T> extends Expr<T> {
  final Expr callee;

  final Token paren;

  final List<Expr>? arguments;

  CallExpr({
    required this.callee,
    required this.paren,
    required this.arguments,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitCallExpr(this);
  }
}

class LambdaExpr<T> extends Expr<T> {
  final List<Token>? parameters;

  final List<Stmt> body;

  LambdaExpr({
    required this.parameters,
    required this.body,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitLambdaExpr(this);
  }
}

class GroupingExpr<T> extends Expr<T> {
  final Expr expression;

  GroupingExpr({
    required this.expression,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class LiteralExpr<T> extends Expr<T> {
  final Object? value;

  LiteralExpr({
    required this.value,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class LogicalExpr<T> extends Expr<T> {
  final Expr left;

  final Token operator;

  final Expr right;

  LogicalExpr({
    required this.left,
    required this.operator,
    required this.right,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitLogicalExpr(this);
  }
}

class UnaryExpr<T> extends Expr<T> {
  final Token operator;

  final Expr right;

  UnaryExpr({
    required this.operator,
    required this.right,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}

class VariableExpr<T> extends Expr<T> {
  final Token name;

  VariableExpr({
    required this.name,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitVariableExpr(this);
  }
}

class GetExpr<T> extends Expr<T> {
  final Expr object;

  final Token name;

  GetExpr({
    required this.object,
    required this.name,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitGetExpr(this);
  }
}

class SetExpr<T> extends Expr<T> {
  final Expr object;

  final Token name;

  final Expr value;

  SetExpr({
    required this.object,
    required this.name,
    required this.value,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitSetExpr(this);
  }
}

class ThisExpr<T> extends Expr<T> {
  final Token keyword;

  ThisExpr({
    required this.keyword,
  });
  @override
  T accept(ExprVisitor<T> visitor) {
    return visitor.visitThisExpr(this);
  }
}
