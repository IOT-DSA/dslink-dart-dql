library dsa.query.functions;

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
};
