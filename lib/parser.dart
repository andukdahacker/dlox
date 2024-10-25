import 'package:dlox/dlox.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser({required this.tokens});

  Expr? parse() {
    try {
      return _expression();
    } on ParseError catch (e) {
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Expr _expression() {
    return _equality();
  }

  Expr _equality() {
    Expr expr = _comparison();

    while (_match([TokenType.bangEqual, TokenType.equalEqual])) {
      final Token operator = _previous();
      final Expr right = _comparison();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _comparison() {
    Expr expr = _term();

    while (_match([
      TokenType.greater,
      TokenType.greateEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      final Token operator = _previous();
      final Expr right = _term();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _term() {
    Expr expr = _factor();

    while (_match([TokenType.minus, TokenType.plus])) {
      final Token operator = _previous();
      final Expr right = _factor();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _factor() {
    Expr expr = _unary();

    while (_match([TokenType.slash, TokenType.star])) {
      final Token operator = _previous();
      final Expr right = _unary();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([TokenType.bang, TokenType.minus])) {
      final Token operator = _previous();
      final Expr right = _unary();
      return Unary(operator: operator, right: right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.tFalse])) return Literal(value: false);
    if (_match([TokenType.tTrue])) return Literal(value: true);
    if (_match([TokenType.nil])) return Literal(value: null);
    if (_match([TokenType.number, TokenType.string])) {
      return Literal(value: _previous().literal);
    }

    if (_match([TokenType.leftParen])) {
      final expr = _expression();
      _consume(TokenType.rightParen, 'Expect \')\' after expression.');
      return Grouping(expression: expr);
    }

    throw error(_peek(), 'Expect expression');
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw error(_peek(), message);
  }

  bool _match(List<TokenType> tokenTypes) {
    for (final type in tokenTypes) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;

    return _previous();
  }

  Token _peek() {
    return tokens[_current];
  }

  Token _previous() {
    return tokens[_current - 1];
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.eof;
  }

  ParseError error(Token token, String message) {
    LoxErrorHandler.instance.error(token, message);
    return ParseError();
  }

  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.semicolon) return;

      switch (_peek().type) {
        case TokenType.tClass:
        case TokenType.tElse:
        case TokenType.fun:
        case TokenType.tFor:
        case TokenType.tIf:
        case TokenType.print:
        case TokenType.tReturn:
        case TokenType.tVar:
        case TokenType.tWhile:
          return;
        default:
          break;
      }

      _advance();
    }
  }
}

class ParseError implements Exception {}
