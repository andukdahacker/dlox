import 'package:dlox/intepreter.dart';
import 'package:dlox/token.dart';

class Environment {
  final Environment? enclosingEnv;

  Environment({Environment? enclosing}) : enclosingEnv = enclosing;

  final Map<String, Object?> values = {};

  Object? getAt(int distance, String name) {
    return _ancestor(distance).values[name];
  }

  Environment _ancestor(int distance) {
    Environment environment = this;

    for (int i = 0; i < distance; i++) {
      if (environment.enclosingEnv == null) {
        throw Exception(
            'Cannot find enclosing environment. Variable is not defined');
      }
      environment = environment.enclosingEnv!;
    }

    return environment;
  }

  void define(Token name, Object? value) {
    values[name.lexeme] = value ?? UninitializedError(name);
  }

  void assignAt(int distance, Token name, Object? value) {
    _ancestor(distance).values.addAll({name.lexeme: value});
  }

  void assign(Token name, Object? value) {
    if (values.containsKey(name.lexeme)) {
      values[name.lexeme] = value;
      return;
    }

    if (enclosingEnv != null) {
      enclosingEnv!.assign(name, value);
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

    if (enclosingEnv != null) {
      return enclosingEnv!.getVar(name);
    }

    throw RuntimeError(
        token: name, message: 'Undefined variable ${name.lexeme}.');
  }
}

class UninitializedError implements Exception {
  final Token token;

  UninitializedError(this.token);
}
