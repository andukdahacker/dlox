import 'dart:convert';
import 'dart:io';

import 'package:dlox/intepreter.dart';
import 'package:dlox/parser.dart';
import 'package:dlox/scanner.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

final interpreter = Interpreter();

Future<void> runFile(String path) async {
  final file = File(path);

  final chars = await file.readAsString(encoding: utf8);

  run(chars);
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
  try {
    final scanner = Scanner(source);

    final List<Token> tokens = scanner.scanTokens();

    final Parser parser = Parser(tokens: tokens);

    final stmts = parser.parse();

    if (LoxErrorHandler.instance.hadError) return;

    interpreter.interpret(stmts);
  } catch (e) {
    return;
  }
}

class LoxErrorHandler {
  LoxErrorHandler._();

  static final LoxErrorHandler instance = LoxErrorHandler._();

  bool hadError = false;
  bool hadRuntimeError = false;

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

  void runtimeError(RuntimeError error) {
    print('${error.message}\n[line ${error.token.line}]');
    hadRuntimeError = true;
  }
}
