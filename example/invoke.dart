import "dart:io";

import "package:dql/invoke.dart";

main() {
  test('hello(param=1)');
  test('hello(param=%name)');
  test('hello(param=name)');
  test('hello-goodbye(param=fi)');

  if (hasAnyError) {
    exit(1);
  }
}

test(input) {
  if (input is List) {
    for (var x in input) {
      test(x);
    }
    return;
  }

  input = input.toString();

  print("================================================");
  print("Input: ${input.replaceAll('\n', '\\n').replaceAll('\t', '\\t')}");

  var x = QueryInvokeParser.doParse(input);
  print("Result: ${x}");
}

bool hasAnyError = false;
