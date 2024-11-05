import 'dart:io';

Future<void> main(List<String> args) async {
  await defineAst('./lib', 'Expr', [
    'Binary : Expr left, Token operator, Expr right',
    'Grouping : Expr expression',
    'Literal : Object? value',
    'Unary: Token operator, Expr right',
    'Variable: Token name',
  ]);

  await defineAst('./lib', 'Stmt', [
    'Expression: Expr expression',
    'Print: Expr expression',
    'Var: Token name, Expr? initializer'
  ]);
}

Future<void> defineAst(
    String outputDir, String baseName, List<String> types) async {
  final path = '$outputDir/${baseName.toLowerCase()}.dart';

  final newFile = File(path);

  final sink = newFile.openWrite();

  sink.write('import \'package:dlox/token.dart\';');

  sink.write('''
    sealed class $baseName<T> {
      T accept(${baseName}Visitor<T> visitor);
    }\n
  ''');

  sink.write('''
    abstract class ${baseName}Visitor<T> {
  ''');

  for (final type in types) {
    final className = type.split(':').first.trim();

    sink.write('''
      T visit$className$baseName($className$baseName ${baseName.toLowerCase()});\n
    ''');
  }

  sink.write('''
    }
  ''');

  for (final type in types) {
    final className = type.split(':').first.trim();
    final fields = type.split(':')[1].trim();

    await defineType(sink, baseName, className, fields);
  }

  await sink.close();
}

Future<void> defineType(
    IOSink sink, String baseName, String className, String fieldList) async {
  sink.write('''
      class $className$baseName<T> extends $baseName<T> {\n
      ''');

  final fields = fieldList.split(', ');

  for (final field in fields) {
    final type = field.split(' ').first;
    final name = field.split(' ')[1];

    sink.write('''
        final $type $name;\n
      ''');
  }

  sink.write('''
      $className$baseName({
    ''');

  for (final field in fields) {
    final name = field.split(' ')[1];

    sink.write('''
    required this.$name,
    ''');
  }

  sink.write('});\n');

  sink.write('''
      @override
      T accept(${baseName}Visitor<T> visitor) {
        return visitor.visit$className$baseName(this);
      }\n
    ''');

  sink.write('}');
}
