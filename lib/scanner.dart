import 'package:dlox/dlox.dart';
import 'package:dlox/keywords.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

class Scanner {
  final String source;

  Scanner(this.source);

  final List<Token> _tokens = [];
  int _start = 0;
  int _current = 0;
  int _line = 0;

  bool get isAtEnd {
    return _current >= source.length;
  }

  String _advance() {
    _current++;
    return source[_current - 1];
  }

  void _addToken(TokenType type, {Object? literal}) {
    String lexeme = source.substring(_start, _current);

    _tokens
        .add(Token(type: type, lexeme: lexeme, literal: literal, line: _line));
  }

  bool _match(String char) {
    if (isAtEnd) {
      return false;
    }

    if (source[_current] != char) {
      return false;
    }

    _current++;

    return true;
  }

  String _peek() {
    if (isAtEnd) {
      return '\\0';
    }

    return source[_current];
  }

  String _peekNext() {
    if (_current + 1 > source.length) return '\\0';

    return source[_current + 1];
  }

  void _string() {
    while (_peek() != '"' && !isAtEnd) {
      if (_peek() == '\n') {
        _line++;
      }
      _advance();
    }

    if (isAtEnd) {
      LoxErrorHandler.instance
          .error(line: _line, message: 'Unterminated string');
      return;
    }

    _advance();

    final value = source.substring(_start + 1, _current - 1);

    _addToken(TokenType.string, literal: value);
  }

  bool _isDigit(String char) {
    final number = int.tryParse(char);

    if (number == null) {
      return false;
    }

    return true;
  }

  void _number() {
    while (_isDigit(_peek())) {
      _advance();
    }

    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();

      while (_isDigit(_peek())) {
        _advance();
      }
    }

    final string = source.substring(_start, _current);

    _addToken(TokenType.number, literal: double.tryParse(string));
  }

  bool _isAlpha(String char) {
    if (char == '_') {
      return true;
    }

    int codeUnit = char.codeUnitAt(0);

    //a-z
    //A-Z
    return (codeUnit >= 65 && codeUnit <= 90) ||
        (codeUnit >= 97 && codeUnit <= 122);
  }

  bool _isAlphaNumeric(String char) {
    return _isAlpha(char) || _isDigit(char);
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final text = source.substring(_start, _current);

    TokenType? type = keywords[text];

    type ??= TokenType.identifier;

    _addToken(type);
  }

  void _scanBlockComment() {
    int nestLevel = 1;

    while (nestLevel > 0) {
      if (isAtEnd) {
        LoxErrorHandler.instance
            .error(line: _line, message: 'Unterminated block comment');
        return;
      }

      String char = _advance();

      if (char == '/' && _peek() == '*') {
        nestLevel++;
        _advance();
      } else if (char == '*' && _peek() == '/') {
        nestLevel--;
        _advance();
      } else if (char == '\n') {
        _line++;
      }
    }
  }

  void scanToken() {
    String char = _advance();

    switch (char) {
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case '.':
        _addToken(TokenType.dot);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(
          TokenType.semicolon,
        );
        break;
      case '*':
        _addToken(TokenType.star);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.bangEqual : TokenType.bang);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.equalEqual : TokenType.equal);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.lessEqual : TokenType.less);
        break;
      case '>':
        _addToken(_match('=') ? TokenType.greateEqual : TokenType.greater);
        break;
      case '/':
        if (_match('/')) {
          while (_peek() != '\n' && !isAtEnd) {
            _advance();
          }
        } else if (_match('*')) {
          _scanBlockComment();
        } else {
          _addToken(TokenType.slash);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        break;
      case '\n':
        _line++;
        break;
      case '"':
        _string();
        break;
      default:
        if (_isDigit(char)) {
          _number();
        } else if (_isAlpha(char)) {
          _identifier();
        } else {
          LoxErrorHandler.instance
              .error(line: _line, message: 'Unhandled char $char');
        }
    }
  }

  List<Token> scanTokens() {
    while (!isAtEnd) {
      _start = _current;
      scanToken();
    }

    _tokens.add(Token(type: TokenType.eof, lexeme: '', line: _line));

    return _tokens;
  }
}
