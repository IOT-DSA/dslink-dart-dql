import "package:dslink_dql/filter.dart";

main() {
  test('"hi"="bye"');
  test('hi="bye"');
  test('latitude!=nil');
  test('@assetApplicable @assetType="Engine Core Stand        "');
  test('@assetApplicable or @assetType');
  test('@name="name" or @fi="bye"');
}

test(String filter) {
  var p = new FilterParser();
  print(p.parse(filter).value);
}
