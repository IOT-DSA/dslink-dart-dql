library dslink.dql.utils;

import "dart:async";
import "dart:typed_data";

import "package:path/path.dart" as pathlib;

typedef OnReferenceSet<T>(T value);

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

class Reference<T> {
  final OnReferenceSet _callback;

  T _value;
  T get value => _value;

  Reference({OnReferenceSet handler}) : _callback = handler;

  void set(T value) {
    _value = value;

    if (_callback != null) {
      _callback(_value);
    }
  }
}

String joinNodePath(String a, String b) {
  var ctx = new pathlib.Context(style: pathlib.Style.posix, current: a);
  return ctx.normalize(ctx.absolute(b));
}

String typeOf(input) {
  if (input is int) {
    return "integer";
  } else if (input is num) {
    return "number";
  } else if (input is String) {
    return "string";
  } else if (input is Map) {
    return "map";
  } else if (input is List) {
    return "list";
  } else if (input is ByteData) {
    return "binary";
  } else {
    return "unknown";
  }
}

int getIntegerFromInput(input, [def]) {
  if (input is String) {
    return num.parse(input, (source) => def).toInt();
  } else if (input is num) {
    return input.toInt();
  }
  return def;
}

int getNumberFromInput(input, [def]) {
  if (input is String) {
    return num.parse(input, (source) => def);
  } else if (input is num) {
    return input;
  }
  return def;
}
