import 'package:dlox/expr.dart';

class AstPrinter implements ExprVisitor<String> {
  String printAst(Expr expr) {
    return expr.accept(this);
  }

  String parenthesize(String name, List<Expr> exprs) {
    StringBuffer buffer = StringBuffer('(');
    buffer.write(name);
    for (final expr in exprs) {
      buffer.write(' ');
      buffer.write(expr.accept(this));
    }

    buffer.write(')');

    return buffer.toString();
  }

  @override
  String visitBinaryExpr(BinaryExpr expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(GroupingExpr expr) {
    return parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteralExpr(LiteralExpr expr) {
    if (expr.value == null) return 'nil';
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(UnaryExpr expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  @override
  String visitVariableExpr(VariableExpr expr) {
    return expr.name.lexeme;
  }

  @override
  String visitAssignExpr(AssignExpr expr) {
    return parenthesize('set ${expr.name.lexeme}', [expr.value]);
  }

  @override
  String visitLogicalExpr(LogicalExpr expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitCallExpr(CallExpr expr) {
    return parenthesize(expr.callee.accept(this), [...?expr.arguments]);
  }
}
