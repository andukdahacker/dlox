import 'package:dlox/ast_printer.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

void main(List<String> args) {
  final Expr simpleExpr = Binary(
      left: Literal(value: 1),
      right: Literal(value: 2),
      operator: Token(type: TokenType.plus, lexeme: '+', line: 1));

  final Expr expr = Binary(
    left: Unary(
        operator: Token(
          type: TokenType.minus,
          lexeme: '-',
          line: 1,
        ),
        right: Literal(value: 123)),
    right: Grouping(expression: Literal(value: 45.67)),
    operator: Token(type: TokenType.star, lexeme: '*', line: 1),
  );

  print(AstPrinter().printAst(simpleExpr));
  print(AstPrinter().printAst(expr));
}
