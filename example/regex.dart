import "package:dql/parse.dart";

main() {
  test("*Hello*", [
    "Hello World",
    "!Goodbye World"
  ]);

  test("* World", [
    "Hello World",
    "Goodbye World",
    "!Test",
    "!MatchWorld"
  ]);
}

test(String ptrn, List<String> checks) {
  print("=============================================");
  print("Pattern: ${ptrn}");
  RegExp regex = parseSimpleRegEx(ptrn);

  for (String x in checks) {
    bool invert = x.startsWith("!");

    if (invert) {
      x = x.substring(1);
    }

    bool matches = regex.hasMatch(x);
    String status = matches ? (
      invert ? "Fail" : "Pass"
    ) : (
      invert ? "Pass" : "Fail"
    );

    print("${status}: ${x}");
  }
}
