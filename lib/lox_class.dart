import 'package:dlox/intepreter.dart';
import 'package:dlox/lox_callable.dart';
import 'package:dlox/lox_function.dart';
import 'package:dlox/lox_instance.dart';

class LoxClass implements LoxCallable {
  final String name;
  final Map<String, LoxFunction> methods;

  LoxClass({required this.name, required this.methods});

  @override
  String toString() {
    return name;
  }

  @override
  int arity() {
    final initializer = findMethod('init');
    if (initializer == null) return 0;
    return initializer.arity();
  }

  LoxFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name];
    }

    return null;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    final instance = LoxInstance(loxClass: this);

    final initializer = findMethod('init');

    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }

    return instance;
  }
}
