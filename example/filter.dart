import "package:dslink_dql/parse.dart";

main() {
  test('"hi"="bye"');
  test('hi="bye"');
  test('my=1');
}

test(String filter) {
  print("===========");
  var matches = PATTERN_FILTER.allMatches(filter);
  for (var match in matches) {
    print(match.groups(new List<int>.generate(match.groupCount + 1, (i) => i)));
  }
  print("===========");
}
