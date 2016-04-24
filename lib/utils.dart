library dslink.dql.utils;

import "dart:async";

Future pumpEventQueue([int times = 20]) {
  if (times == 0) {
    return new Future.value();
  }

  return new Future.delayed(Duration.ZERO, () => pumpEventQueue(times - 1));
}

class EmptyIterable<T> extends Iterable<T> {
  const EmptyIterable();

  @override
  Iterator get iterator => new EmptyIterator<T>();
}

class EmptyIterator<T> extends Iterator<T> {
  EmptyIterator();

  @override
  bool moveNext() => false;
  T current = null;
}
