import 'package:dlox/environment.dart';
import 'package:dlox/intepreter.dart';
import 'package:dlox/lox_callable.dart';
import 'package:dlox/lox_instance.dart';
import 'package:dlox/stmt.dart';
import 'package:dlox/token.dart';
import 'package:dlox/token_type_enum.dart';

import 'return.dart';

class LoxFunction implements LoxCallable {
  final FunctionStmt _declaration;
  final Environment _closure;
  final bool _isInitializer;

  LoxFunction({
    required FunctionStmt declaration,
    required Environment closure,
    required bool isInitializer,
  })  : _declaration = declaration,
        _isInitializer = isInitializer,
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
      if (_isInitializer) return _closure.getAt(0, 'this');
      return e.value;
    }

    if (_isInitializer) return _closure.getAt(0, 'this');

    return null;
  }

  LoxFunction bind(LoxInstance instance) {
    final environment = Environment(enclosing: _closure);

    environment.define(
        Token(type: TokenType.tThis, lexeme: 'this', line: -1), instance);

    return LoxFunction(
      declaration: _declaration,
      closure: environment,
      isInitializer: _isInitializer,
    );
  }

  @override
  String toString() {
    return '<fun ${_declaration.name.lexeme}>';
  }
}
