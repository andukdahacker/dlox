import 'package:dlox/ast_printer.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

void main(List<String> args) {
  final Expr simpleExpr = BinaryExpr(
      left: LiteralExpr(value: 1),
      right: LiteralExpr(value: 2),
      operator: Token(type: TokenType.plus, lexeme: '+', line: 1));

  final Expr expr = BinaryExpr(
    left: UnaryExpr(
        operator: Token(
          type: TokenType.minus,
          lexeme: '-',
          line: 1,
        ),
        right: LiteralExpr(value: 123)),
    right: GroupingExpr(expression: LiteralExpr(value: 45.67)),
    operator: Token(type: TokenType.star, lexeme: '*', line: 1),
  );

  final Expr varExpr = VariableExpr(
      name: Token(type: TokenType.identifier, lexeme: 'a', line: 1));

  final Expr assignExpr = AssignExpr(
    name: Token(type: TokenType.identifier, lexeme: 'a', line: 1),
    value: expr,
  );

  print(AstPrinter().printAst(simpleExpr));
  print(AstPrinter().printAst(expr));
  print(AstPrinter().printAst(varExpr));
  print(AstPrinter().printAst(assignExpr));
}
