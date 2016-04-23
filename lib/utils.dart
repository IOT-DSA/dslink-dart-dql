library dslink.dql.utils;

import "dart:async";

Future pumpEventQueue([int times = 20]) {
  if (times == 0) {
    return new Future.value();
  }

  return new Future.delayed(Duration.ZERO, () => pumpEventQueue(times - 1));
}
