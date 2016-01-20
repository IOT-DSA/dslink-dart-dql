import "package:dslink_dql/parse.dart";

main() async {
  test("*");
  test("/*");
  test("/downstream/*");
  test("/downstream/System/?");
  test("/downstream/etsdb/*Alarm");
  test("/downstream/System", [
    "-/downstream/System/A/B"
  ]);
}

test(String input, [List<String> tests]) {
  var result = parseExpressionInput(input);
  print("=============================");
  print("Input: ${input}");
  print("Topmost: ${result.topmost}");
  print("Pattern: ${result.pattern.pattern}");
  
  if (tests != null) {
    for (String t in tests) {
      bool isFalse = t.startsWith("-");
      if (t.startsWith("-")) {
        t = t.substring(1);
      }
      
      if (result.matches(t)) {
        if (isFalse) {
          throw new Exception("${t} should not match ${input}");
        }
      } else if (!isFalse) {
        throw new Exception("${t} should match ${input}");
      }
    }
  }
}
