import "package:dql/parsers/filter.dart";

final List<String> inputs = <String>[];
final List<String> slows = <String>[];

main() {
  test('"hi"="bye"');
  test('hi="bye"');
  test('latitude!=nil');
  test('@assetApplicable @assetType="Engine Core Stand"');
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
  test('(@car is true) and (@truck is false or @always is true)');
  test('(../@car is true) and (../../@truck is false or @always is true)');
  test('@names contains "Alex"');
  test('@name in ["Alex", "Emily"]');
  test(r'not $disconnectedTs');
  test(r'not not $disconnectedTs');
  test(r'(not $a) and (not $b) or $c');
  test(r'not $disconnectedTs');
  test(r'@name like "%Boat%"');
  test(r'@name like "%Goat%"');
  test(r'@type like "float%"');
  test(r'not @type like "%goat"');
  test(r'@list anyContains "ak"');
  test(r'@list anyContains "ac"');
  test(r'@test == "HelloX"');
  test(r'index(@map, "vehicle") is "Car"');
  test(r'index(@map, "vehicle") is "Truck"');
  test(r'index(@map, "vehicle") is "Truck"');

  benchmark();
}

test(String input) {
  inputs.add(input);
}

String formatTime(Duration duration) {
  return "${duration.inMicroseconds} μs (${duration.inMicroseconds / 1000} ms)";
}

benchmark() {
  // Warmup.
  for (var input in inputs) {
    for (var i = 1; i <= 50; i++) {
      FilterParser.doParse(input);
    }
  }

  for (var input in inputs) {
    var watch = new Stopwatch();
    watch.start();
    for (var i = 1; i <= 50000; i++) {
      FilterParser.doParse(input);
    }
    watch.stop();
    var avg = watch.elapsedMicroseconds / 50000;
    print("===========================================");
    print("Filter Input: ${input}");
    print("50,000 Run Total: ${formatTime(watch.elapsed)}");
    print("50,000 Run Average: ${formatTime(new Duration(microseconds: avg.toInt()))}");

    if (avg > 1000) {
      print("[WARNING] Filter '${input}' took a long time to parse.");
    }
  }
}
