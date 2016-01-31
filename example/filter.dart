import "package:dslink_dql/filter.dart";

main() {
  test('"hi"="bye"');
  test('hi="bye"');
  test('latitude!=nil');
  test('@assetType="Spare Part               " @assetApplicable="VOR DME                           "');
}

test(String filter) {
  var p = new FilterParser();
  print(p.parse(filter).value);
}
