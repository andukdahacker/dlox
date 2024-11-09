import 'package:dlox/token.dart';    sealed class Expr<T> {
      T accept(ExprVisitor<T> visitor);
    }

      abstract class ExprVisitor<T> {
        T visitAssignExpr(AssignExpr expr);

          T visitBinaryExpr(BinaryExpr expr);

          T visitCallExpr(CallExpr expr);

          T visitGroupingExpr(GroupingExpr expr);

          T visitLiteralExpr(LiteralExpr expr);

          T visitLogicalExpr(LogicalExpr expr);

          T visitUnaryExpr(UnaryExpr expr);

          T visitVariableExpr(VariableExpr expr);

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

    }      class BinaryExpr<T> extends Expr<T> {

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

    }      class CallExpr<T> extends Expr<T> {

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

    }      class GroupingExpr<T> extends Expr<T> {

              final Expr expression;

            GroupingExpr({
        required this.expression,
    });
      @override
      T accept(ExprVisitor<T> visitor) {
        return visitor.visitGroupingExpr(this);
      }

    }      class LiteralExpr<T> extends Expr<T> {

              final Object? value;

            LiteralExpr({
        required this.value,
    });
      @override
      T accept(ExprVisitor<T> visitor) {
        return visitor.visitLiteralExpr(this);
      }

    }      class LogicalExpr<T> extends Expr<T> {

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

    }      class UnaryExpr<T> extends Expr<T> {

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

    }      class VariableExpr<T> extends Expr<T> {

              final Token name;

            VariableExpr({
        required this.name,
    });
      @override
      T accept(ExprVisitor<T> visitor) {
        return visitor.visitVariableExpr(this);
      }

    }