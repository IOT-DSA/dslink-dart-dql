import "dart:io";

import "package:dql/subscribe.dart";

main() {
  test('level as BatteryLevel, estimate as TimeEstimate');
  test('level name test :hi name as Hello name is goodbye');
  test('CommandPosition FeedBack_Axis_ActualPosition FeedBack_Axis_ActualPosition.timestamp CommandVelocity');

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

  var x = QuerySubscribeParser.doParse(input);
  print("Result: ${x}");
}

bool hasAnyError = false;
