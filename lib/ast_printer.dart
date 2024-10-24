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
  String visitBinaryExpr(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return 'nil';
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }
}
