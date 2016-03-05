library dql.test.statement.parser;

import "package:dql/query.dart";
import "package:test/test.dart";

main() async {
  group("Query Parser", () {
    basicQueryTests();
  });
}

basicQueryTests() {
  test("list * | subscribe value", () {
    var r = parse("list * | subscribe value");
    expectListPattern(r[0], "/.*");
    expectSubscribe(r[1], ["value"]);
  });

  test("list * | subscribe value as val", () {
    var r = parse("list * | subscribe value as val");
    expectListPattern(r[0], "/.*");
    expectSubscribe(r[1], {
      "value": "val"
    });
  });
}

parse(String input) {
  var ctx = new BasicQueryContext(null, BASE_QUERY_COMMANDS);

  return ctx.parse(input);
}

expectListPattern(ListNodeQueryProcessor processor, String ptrn) {
  expect(processor.expression.pattern.pattern, equals(ptrn));
}

expectSubscribe(SubscribeQueryProcessor processor, childs) {
  if (childs is Iterable) {
    var map = {};
    for (String child in childs) {
      map[child] = child;
    }
    childs = map;
  }

  expect(processor.childs, equals(childs));
}
