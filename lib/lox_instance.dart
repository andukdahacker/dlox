import 'package:dlox/intepreter.dart';
import 'package:dlox/lox_class.dart';

import 'token.dart';

class LoxInstance {
  final LoxClass loxClass;
  final Map<String, Object?> fields = {};

  LoxInstance({required this.loxClass});

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    final method = loxClass.findMethod(name.lexeme);

    if (method != null) return method.bind(this);

    throw RuntimeError(
        token: name, message: 'Undefined property ${name.lexeme}');
  }

  void set(Token name, Object? value) {
    fields[name.lexeme] = value;
  }

  @override
  String toString() {
    return '${loxClass.name} instance';
  }
}
