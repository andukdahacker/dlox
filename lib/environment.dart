import 'package:dlox/intepreter.dart';
import 'package:dlox/token.dart';

class Environment {
  final Environment? _enclosingEnv;

  Environment({Environment? enclosing}) : _enclosingEnv = enclosing;

  final Map<String, Object?> values = {};

  void define(String name, Object? value) {
    values[name] = value;
  }

  void assign(Token name, Object? value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }

    if (_enclosingEnv != null) {
      _enclosingEnv.assign(name, value);
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }

  Object getVar(Token name) {
    if (values.containsKey(name.lexeme)) {
      return values[name.lexeme]!;
    }

    if (_enclosingEnv != null) {
      return _enclosingEnv.getVar(name);
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }
}
