import 'dart:convert';
import 'dart:io';

import 'package:dlox/scanner.dart';
import 'package:dlox/token.dart';

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

  for (final token in tokens) {
    print('token: ${token.type}');
  }
}

class LoxErrorHandler {
  LoxErrorHandler._();

  static final LoxErrorHandler instance = LoxErrorHandler._();

  bool hadError = false;

  void error({required int line, required String message, String? where}) {
    print('[line $line] Error: ${where ?? ''}: $message');
  }
}
