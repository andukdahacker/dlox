import 'package:dlox/intepreter.dart';
import 'package:dlox/token.dart';

class Environment {
  final Map<String, Object?> values = {};

  void define(String name, Object? value) {
    values[name] = value;
  }

  Object getVar(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme]!;
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }
}
