import "package:dslink_dql/parse.dart";

main() async {
  test("list | print");
  test(r"list * | subscribe $type");
}

test(String input) {
  var results = parseQueryInput(input);
  print("=============================");
  print("Input: ${input}");
  for (var result in results) {
    print("Command: ${result.command}");
    if (result.argument != null && result.argument.isNotEmpty) {
      print("Argument: ${result.argument}");
    }
  }
}
