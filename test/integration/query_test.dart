library dql.test.query.integration;

import "dart:async";

import "package:dql/query.dart";
import "package:dql/process.dart";

import "package:dslink/common.dart";
import "package:dslink/requester.dart";

import "package:test/test.dart";

part "helpers/context.dart";
part "helpers/node.dart";
part "helpers/result.dart";

const String _BASE_PATH = "/base";

main() async {
  group("DQL Integration", () {
    mockTests();
  });
}

MockQueryContext createQueryContext(Map input) {
  var ctx = new MockQueryContext(BASE_QUERY_COMMANDS);
  ctx.root.load(input);
  return ctx;
}

MockQueryContext createSimpleQueryContext() {
  var ctx = createQueryContext({
    "base": {
      "a": {
        r"$type": "number",
        "?value": 10
      },
      "b": {
        r"$type": "number",
        "?value": 20
      }
    }
  });

  return ctx;
}

mockTests() {
  test("subscriptions send initial values down the pipeline", () async {
    var ctx = createSimpleQueryContext();

    var result = await ctx.capture(
      "list ${_BASE_PATH} | filter :metric | subscribe"
    );

    result.verify([
      {
        "path": "${_BASE_PATH}/a",
        "value": 10
      },
      {
        "path": "${_BASE_PATH}/b",
        "value": 20
      }
    ]);
  });

  test("subscriptions send updates down the pipeline", () async {
    var ctx = createSimpleQueryContext();

    var result = await ctx.capture(
      "list ${_BASE_PATH} | filter :metric | subscribe", work: () {
      ctx.root.findNode("${_BASE_PATH}/a").updateValue(11);
      ctx.root.findNode("${_BASE_PATH}/b").updateValue(21);
    });

    result.verify([
      {
        "path": "${_BASE_PATH}/a",
        "value": 11
      },
      {
        "path": "${_BASE_PATH}/b",
        "value": 21
      }
    ]);
  });
}
