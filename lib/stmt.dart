import 'package:dlox/token.dart';

import 'expr.dart';

sealed class Stmt<T> {
  T accept(StmtVisitor<T> visitor);
}

abstract class StmtVisitor<T> {
  T visitExpressionStmt(ExpressionStmt stmt);

  T visitPrintStmt(PrintStmt stmt);

  T visitVarStmt(VarStmt stmt);
}

class ExpressionStmt<T> extends Stmt<T> {
  final Expr expression;

  ExpressionStmt({
    required this.expression,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}

class PrintStmt<T> extends Stmt<T> {
  final Expr expression;

  PrintStmt({
    required this.expression,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

class VarStmt<T> extends Stmt<T> {
  final Token name;

  final Expr? initializer;

  VarStmt({
    required this.name,
    required this.initializer,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitVarStmt(this);
  }
}
