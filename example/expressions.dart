import "package:dslink_dql/parse.dart";

main() async {
  test("*");
  test("/*");
  test("/downstream/*");
  test("/downstream/System/?");
  test("/downstream/etsdb/*Alarm");
}

test(String input) {
  var result = parseExpressionInput(input);
  print("=============================");
  print("Input: ${input}");
  print("Topmost: ${result.topmost}");
  print("Pattern: ${result.pattern.pattern}");
}
