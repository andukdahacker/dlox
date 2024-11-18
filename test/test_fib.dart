void main() {
  final before = DateTime.now().millisecondsSinceEpoch;

  final result = fib(40);

  final after = DateTime.now().millisecondsSinceEpoch;

  print(result);

  print('Took ${after - before}');
}

int fib(int n) {
  if (n < 2) return n;

  return fib(n - 2) + fib(n - 1);
}
