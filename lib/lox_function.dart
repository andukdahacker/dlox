import 'package:dlox/environment.dart';
import 'package:dlox/intepreter.dart';
import 'package:dlox/lox_callable.dart';
import 'package:dlox/stmt.dart';

import 'return.dart';

class LoxFunction implements LoxCallable {
  final FunctionStmt _declaration;
  final Environment _closure;

  LoxFunction({
    required FunctionStmt declaration,
    required Environment closure,
  })  : _declaration = declaration,
        _closure = closure;

  @override
  int arity() {
    return _declaration.parameters?.length ?? 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    final environment = Environment(enclosing: _closure);

    for (var i = 0; i < (_declaration.parameters?.length ?? 0); i++) {
      environment.define(_declaration.parameters![i], arguments[i]);
    }

    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on Return catch (e) {
      return e.value;
    }

    return null;
  }

  @override
  String toString() {
    return '<fun ${_declaration.name.lexeme}>';
  }
}
