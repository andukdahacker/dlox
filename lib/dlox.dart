import 'dart:convert';
import 'dart:io';

import 'package:dlox/ast_printer.dart';
import 'package:dlox/expr.dart';
import 'package:dlox/parser.dart';
import 'package:dlox/scanner.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

Future<void> runFile(String path) async {
  final file = File(path);

  final chars = await file.readAsString(encoding: utf8);

  run(chars);

  if (LoxErrorHandler.instance.hadError) {
    throw Exception('Had an error');
  }
}

void runPrompt() {
  for (;;) {
    stdout.write('> ');
    final input = stdin.readLineSync(encoding: utf8);

    if (input == null) {
      break;
    }

    run(input);
    LoxErrorHandler.instance.hadError = false;
  }
}

void run(String source) {
  final scanner = Scanner(source);

  final List<Token> tokens = scanner.scanTokens();

  // for (final token in tokens) {
  //   print('token ${token.type}');
  // }

  final Parser parser = Parser(tokens: tokens);

  final Expr? expr = parser.parse();

  if (LoxErrorHandler.instance.hadError) return;

  if (expr != null) {
    print(AstPrinter().printAst(expr));
  }
}

class LoxErrorHandler {
  LoxErrorHandler._();

  static final LoxErrorHandler instance = LoxErrorHandler._();

  bool hadError = false;

  void report({required int line, required String message, String? where}) {
    print('[line $line] Error: ${where ?? ''}: $message');
  }

  void error(Token token, String message) {
    if (token.type == TokenType.eof) {
      report(line: token.line, where: ' at end', message: message);
    } else {
      report(
          line: token.line, where: ' at \'${token.lexeme}\'', message: message);
    }
  }
}
