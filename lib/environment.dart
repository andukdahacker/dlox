import 'package:dlox/intepreter.dart';
import 'package:dlox/token.dart';

class Environment {
  final Environment? _enclosingEnv;

  Environment({Environment? enclosing}) : _enclosingEnv = enclosing;

  final Map<String, Object?> values = {};

  void define(Token name, Object? value) {
    values[name.lexeme] = value ?? UninitializedError(name);
  }

  void assign(Token name, Object? value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }

    if (_enclosingEnv != null) {
      _enclosingEnv.assign(name, value);
      return;
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }

  Object? getVar(Token name) {
    if (values.containsKey(name.lexeme)) {
      final value = values[name.lexeme];

      if (value is UninitializedError) {
        throw value;
      }

      return values[name.lexeme];
    }

    if (_enclosingEnv != null) {
      return _enclosingEnv.getVar(name);
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }
}

class UninitializedError implements Exception {
  final Token token;

  UninitializedError(this.token);
}
