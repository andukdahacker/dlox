import 'package:dlox/token.dart';

import 'expr.dart';

sealed class Stmt<T> {
  T accept(StmtVisitor<T> visitor);
}

abstract class StmtVisitor<T> {
  T visitBlockStmt(BlockStmt stmt);

  T visitExpressionStmt(ExpressionStmt stmt);

  T visitIfStmt(IfStmt stmt);

  T visitPrintStmt(PrintStmt stmt);

  T visitVarStmt(VarStmt stmt);

  T visitWhileStmt(WhileStmt stmt);
}

class BlockStmt<T> extends Stmt<T> {
  final List<Stmt> statements;

  BlockStmt({
    required this.statements,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitBlockStmt(this);
  }
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

class IfStmt<T> extends Stmt<T> {
  final Expr condition;

  final Stmt thenBranch;

  final Stmt? elseBranch;

  IfStmt({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitIfStmt(this);
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

class WhileStmt<T> extends Stmt<T> {
  final Expr condition;

  final Stmt body;

  WhileStmt({
    required this.condition,
    required this.body,
  });
  @override
  T accept(StmtVisitor<T> visitor) {
    return visitor.visitWhileStmt(this);
  }
}
