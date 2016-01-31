import "package:dslink_dql/filter.dart";

main() {
  test('"hi"="bye"');
  test('hi="bye"');
  test('latitude!=nil');
  test('@assetApplicable @assetType="Engine Core Stand        "');
  test('@assetApplicable or @assetType');
  test('@name="name" or @fi="bye"');
  test('@assetApplicable and @assetType');
  test('@name="name" and @fi="bye"');
  test('@assetApplicable xor @assetType');
  test('@name="name" xor @fi="bye"');

  test('@name="name" || @fi="bye"');
  test('@assetApplicable && @assetType');
  test('@name="name" && @fi="bye"');
  test('@assetApplicable ^ @assetType');
  test('@name="name" ^ @fi="bye"');

  test('@car=true');
  test('@car is true and @truck is false');
  test('@name="name" or @fi="bye" or @peace or @not or @n');
  test('@car is true and @track is false or @name is true');
  test('(@car is true) and (@truck is false or @truck is true)');
}

test(String filter) {
  var p = new FilterParser();
  print(p.parse(filter).value);
}
