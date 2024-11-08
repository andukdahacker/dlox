import 'package:dlox/dlox.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/stmt.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser({required this.tokens});

  List<Stmt> parse() {
    final List<Stmt> statements = [];

    while (!_isAtEnd()) {
      try {
        statements.add(_declaration());
      } on ParseError {
        _synchronize();
        continue;
      }
    }

    return statements;
  }

  Stmt _declaration() {
    if (_match([TokenType.tVar])) {
      return _varDeclaration();
    }

    return _statement();
  }

  Stmt _varDeclaration() {
    final name = _consume(TokenType.identifier, 'Expect variable name.');

    Expr? initializer;

    if (_match([TokenType.equal])) {
      initializer = _expression();
    }

    _consume(TokenType.semicolon, 'Expect \';\' after variable declaration');

    return VarStmt(name: name, initializer: initializer);
  }

  Stmt _statement() {
    if (_match([TokenType.tIf])) {
      return _ifStatement();
    }

    if (_match([TokenType.print])) {
      return _printStatement();
    }

    if (_match([TokenType.tWhile])) {
      return _whileStatement();
    }

    if (_match([TokenType.leftBrace])) {
      return _block();
    }

    if (_match([TokenType.tFor])) {
      return _forStatement();
    }

    return _expressionStatement();
  }

  Stmt _forStatement() {
    _consume(TokenType.leftParen, 'Expect ( after for statement');
    Stmt? initializer;
    if (_match([TokenType.semicolon])) {
      initializer = null;
    } else if (_match([TokenType.tVar])) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    Expr? condition;

    if (!_check(TokenType.semicolon)) {
      condition = _expression();
    }

    _consume(TokenType.semicolon, 'Expect ; after loop condition');

    Expr? increment;

    if (!_check(TokenType.rightParen)) {
      increment = _expression();
    }

    _consume(TokenType.rightParen, 'Expect ) after for clauses');

    Stmt body = _statement();

    if (increment != null) {
      body =
          BlockStmt(statements: [body, ExpressionStmt(expression: increment)]);
    }

    condition ??= LiteralExpr(value: true);

    body = WhileStmt(condition: condition, body: body);

    if (initializer != null) {
      body = BlockStmt(statements: [initializer, body]);
    }

    return body;
  }

  Stmt _whileStatement() {
    _consume(TokenType.leftParen, 'Expect ( after while statement');
    final condition = _expression();
    _consume(TokenType.rightParen, 'Expect ) after while condition');

    Stmt statement = _statement();

    return WhileStmt(condition: condition, body: statement);
  }

  Stmt _ifStatement() {
    _consume(TokenType.leftParen, 'Expect ( after if statement');
    final condition = _expression();
    _consume(TokenType.rightParen, 'Expect ) after if condition');

    Stmt thenBranch = _statement();

    Stmt? elseBranch;

    if (_match([TokenType.tElse])) {
      elseBranch = _statement();
    }

    return IfStmt(
        condition: condition, thenBranch: thenBranch, elseBranch: elseBranch);
  }

  Stmt _printStatement() {
    final expr = _expression();

    _consume(TokenType.semicolon, 'Expect \';\' after value;');

    return PrintStmt(expression: expr);
  }

  Stmt _expressionStatement() {
    final expr = _expression();

    _consume(TokenType.semicolon, 'Expect \';\' after value;');

    return ExpressionStmt(expression: expr);
  }

  Stmt _block() {
    final List<Stmt> statements = [];

    while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
      statements.add(_declaration());
    }

    _consume(TokenType.rightBrace, 'Expect } after block.');

    return BlockStmt(statements: statements);
  }

  Expr _expression() {
    return _assigment();
  }

  Expr _assigment() {
    final expr = _or();

    if (_match([TokenType.equal])) {
      final equals = _previous();

      final value = _assigment();

      if (expr is VariableExpr) {
        final name = expr.name;
        return AssignExpr(name: name, value: value);
      }

      error(equals, 'Invalid assignment target.');
    }

    return expr;
  }

  Expr _or() {
    Expr expr = _and();

    while (_match([TokenType.or])) {
      final operator = _previous();
      Expr right = _and();

      expr = LogicalExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _and() {
    Expr expr = _equality();

    while (_match([TokenType.and])) {
      final operator = _previous();
      Expr right = _equality();

      expr = LogicalExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _equality() {
    Expr expr = _comparison();

    while (_match([TokenType.bangEqual, TokenType.equalEqual])) {
      final Token operator = _previous();
      final Expr right = _comparison();
      expr = BinaryExpr(left: expr, operator: operator, right: right);
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
      expr = BinaryExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _term() {
    Expr expr = _factor();

    while (_match([TokenType.minus, TokenType.plus])) {
      final Token operator = _previous();
      final Expr right = _factor();
      expr = BinaryExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _factor() {
    Expr expr = _unary();

    while (_match([TokenType.slash, TokenType.star])) {
      final Token operator = _previous();
      final Expr right = _unary();
      expr = BinaryExpr(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([TokenType.bang, TokenType.minus])) {
      final Token operator = _previous();
      final Expr right = _unary();
      return UnaryExpr(operator: operator, right: right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.tFalse])) return LiteralExpr(value: false);
    if (_match([TokenType.tTrue])) return LiteralExpr(value: true);
    if (_match([TokenType.nil])) return LiteralExpr(value: null);
    if (_match([TokenType.number, TokenType.string])) {
      return LiteralExpr(value: _previous().literal);
    }

    if (_match([TokenType.identifier])) return VariableExpr(name: _previous());

    if (_match([TokenType.leftParen])) {
      final expr = _expression();
      _consume(TokenType.rightParen, 'Expect \')\' after expression.');
      return GroupingExpr(expression: expr);
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
