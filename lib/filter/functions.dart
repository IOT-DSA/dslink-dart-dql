library dsa.query.functions;

import "dart:math" as Math;

import "package:dql/utils.dart";

typedef FilterFunction(List args);

final Map<String, FilterFunction> filterFunctions = {
  "index": (List args) {
    if (args.length == 2) {
      var of = args[0];

      if (of == null) {
        return null;
      }

      var idx = args[1];
      return of[idx];
    }
    return null;
  },
  "random": (List args) {
    int i = 255;
    if (args.length == 1) {
      i = getIntegerFromInput(args[0], 255);
    }
    return new Math.Random().nextInt(i);
  },
  "sin": (List args) {
    if (args.length == 1) {
      return Math.sin(getNumberFromInput(args[0], 1));
    }
    return null;
  },
  "cos": (List args) {
    if (args.length == 1) {
      return Math.cos(getNumberFromInput(args[0], 1));
    }
    return null;
  },
  "tan": (List args) {
    if (args.length == 1) {
      return Math.tan(getNumberFromInput(args[0], 1));
    }
    return null;
  },
  "log": (List args) {
    if (args.length == 1) {
      return Math.log(getNumberFromInput(args[0], 1));
    }
    return null;
  },
  "add": (List args) {
    var i = 0;
    for (var x in args) {
      i += getNumberFromInput(x, 0);
    }
    return i;
  },
  "subtract": (List args) {
    if (args.length >= 2) {
      var n = getNumberFromInput(args[0], 0);
      for (var i = 1; i < args.length; i++) {
        n -= getNumberFromInput(args[i], 0);
      }
      return n;
    }
    return null;
  },
  "multiply": (List args) {
    if (args.length >= 2) {
      var n = getNumberFromInput(args[0], 0);
      for (var i = 1; i < args.length; i++) {
        n *= getNumberFromInput(args[i], 1);
      }
      return n;
    }
    return null;
  },
  "divide": (List args) {
    if (args.length >= 2) {
      var n = getNumberFromInput(args[0], 0);
      for (var i = 1; i < args.length; i++) {
        n /= getNumberFromInput(args[i], 1);
      }
      return n;
    }
    return null;
  },
  "pow": (List args) {
    if (args.length >= 2) {
      var n = getNumberFromInput(args[0], 0);
      for (var i = 1; i < args.length; i++) {
        n = Math.pow(n, getNumberFromInput(args[i], 1));
      }
      return n;
    }
    return null;
  },
  "concat": (List args) {
    return args.fold("", (a, b) => a.toString() + b.toString());
  },
  "join": (List args) {
    if (args.length == 2) {
      var by = args[0].toString();
      var of = args[1];

      if (of is Iterable) {
        return of.join(by);
      }
    }
    return null;
  }
};
