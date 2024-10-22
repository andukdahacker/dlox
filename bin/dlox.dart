import 'package:dlox/dlox.dart' as dlox;

void main(List<String> args) {
  if (args.length > 1) {
    throw Exception('Usage: [script]');
  } else if (args.length == 1) {
    dlox.runFile(args.first);
  } else {
    dlox.runPrompt();
  }
}
