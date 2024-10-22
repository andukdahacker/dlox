import 'package:dlox/token_type_enum.dart';

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  Token({
    required this.type,
    required this.lexeme,
    required this.line,
    this.literal,
  });
}
