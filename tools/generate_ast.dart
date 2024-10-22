import 'dart:io';

Future<void> main(List<String> args) async {
  await defineAst('./lib', 'Expr', [
    'Binary : Expr left, Token operator, Expr right',
    'Grouping : Expr expression',
    'Literal : Object value',
    'Unary: Token operator, Expr right',
  ]);
}

Future<void> defineAst(
    String outputDir, String baseName, List<String> types) async {
  final path = '$outputDir/${baseName.toLowerCase()}.dart';

  final newFile = File(path);

  final sink = newFile.openWrite();

  sink.write('import \'package:dlox/token.dart\';');

  sink.write('''
    sealed class $baseName {}\n
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
      class $className extends $baseName {\n
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
      $className({
    ''');

  for (final field in fields) {
    final name = field.split(' ')[1];

    sink.write('''
    required this.$name,
    ''');
  }

  sink.write('});\n');

  sink.write('}');
}
