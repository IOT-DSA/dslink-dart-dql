library dql.test.query.integration;

import "dart:async";

import "package:dql/query.dart";
import "package:dql/process.dart";
import "package:dql/utils.dart";

import "package:dslink/common.dart";
import "package:dslink/requester.dart";

import "package:test/test.dart";

part "helpers/context.dart";
part "helpers/node.dart";
part "helpers/result.dart";

const String _base = "/base";

main() async {
  group("DQL Integration", () {
    mockTests();
  });
}

MockQueryContext createQueryContext(Map input) {
  var ctx = new MockQueryContext(baseQueryCommandSet);
  ctx.root.load(input);
  return ctx;
}

MockQueryContext createSmallQueryContext() {
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

MockQueryContext createDeepQueryContext() {
  var ctx = createQueryContext({
    "base": {
      "a": {
        "x": {
          r"$type": "number",
          "?value": 500
        },
        "y": {
          r"$type": "number",
          "?value": 400
        },
        "z": {
          r"$type": "number",
          "?value": 300
        }
      },
      "b": {
        "x": {
          r"$type": "number",
          "?value": 200
        },
        "y": {
          r"$type": "number",
          "?value": 100
        },
        "z": {
          r"$type": "number",
          "?value": 0
        }
      }
    },
    "sub-broker": {
      r"$is": "dsa/broker",
      "downstream": {
        "LinkA": {
          "metric": {
            r"$type": "string"
          }
        }
      }
    }
  });

  return ctx;
}

MockQueryContext createPCSCQueryContext() {
  var ctx = createQueryContext({
    "downstream": {
      "PCSC Security": {
        "PCSC_ATL110": {
          "Cards": {
            "000000010137": {
              r"$type": "string",
              "?value": "234238"
            },
            "000000010136": {
              r"$type": "string",
              "?value": "234238"
            }
          }
        },
        "PCSC_ATL112": {
          "Cards": {
            "000000010137": {
              r"$type": "string",
              "?value": "234238"
            },
            "000000010136": {
              r"$type": "string",
              "?value": "234238"
            }
          }
        }
      },
      "OtherLink": {
        "metric": {
          r"$type": "string",
          "?value": "Hello World"
        }
      }
    }
  });

  return ctx;
}

mockTests() {
  test("listing a direct path to a node only yields the children", () async {
    var ctx = createDeepQueryContext();

    var result = await ctx.capture(
      "list ${_base}"
    );

    result.verify([
      {
        "path": "${_base}/a"
      },
      {
        "path": "${_base}/b"
      }
    ]);

    ctx.checkListedNodes([
      "/base",
      "/base/a",
      "/base/b"
    ]);
  });

  test("subscriptions send initial values down the pipeline", () async {
    var ctx = createSmallQueryContext();

    var result = await ctx.capture(
      "list ${_base} | filter :metric | subscribe"
    );

    result.verify([
      {
        "path": "${_base}/a",
        "value": 10
      },
      {
        "path": "${_base}/b",
        "value": 20
      }
    ]);

    ctx.checkListedNodes([
      "${_base}",
      "${_base}/a",
      "${_base}/b"
    ]);
  });

  test("subscriptions send updates down the pipeline", () async {
    var ctx = createSmallQueryContext();

    var result = await ctx.capture(
      "list ${_base} | filter :metric | subscribe", work: () {
      ctx.root.findNode("${_base}/a").updateValue(11);
      ctx.root.findNode("${_base}/b").updateValue(21);
    });

    result.verify([
      {
        "path": "${_base}/a",
        "value": 11
      },
      {
        "path": "${_base}/b",
        "value": 21
      }
    ]);

    ctx.checkListedNodes([
      "${_base}",
      "${_base}/a",
      "${_base}/b"
    ]);
  });

  test("subscriptions send updates down the pipeline when there are multiple subscribers", () async {
    var ctx = createSmallQueryContext();

    doWork(int i) async {
      var result = await ctx.capture(
        "list ${_base}${' ' * i} | filter :metric | subscribe value", work: () {
        ctx.root.findNode("${_base}/a").updateValue(11);
        ctx.root.findNode("${_base}/b").updateValue(21);
      });

      result.verify([
        {
          "path": "${_base}/a",
          "value": 11
        },
        {
          "path": "${_base}/b",
          "value": 21
        }
      ]);
    }

    await Future.wait([doWork(1), doWork(2), doWork(3)]);
  });

  test("? queries don't overstep bounds", () async {
    var ctx = createPCSCQueryContext();
    var result = await ctx.capture(
      r"list /downstream/PCSC?/?/Cards"
    );

    result.verify([
      {
        "path": "/downstream/PCSC Security/PCSC_ATL110/Cards"
      },
      {
        "path": "/downstream/PCSC Security/PCSC_ATL112/Cards"
      }
    ]);

    ctx.checkListedNodes([
      "/downstream",
      "/downstream/PCSC Security",
      "/downstream/PCSC Security/PCSC_ATL110",
      "/downstream/PCSC Security/PCSC_ATL112",
      "/downstream/PCSC Security/PCSC_ATL110/Cards",
      "/downstream/PCSC Security/PCSC_ATL112/Cards"
    ]);
  });

  test("sublist works as expected", () async {
    var ctx = createPCSCQueryContext();
    var result = await ctx.capture(
      r"list /downstream/PCSC Security/? | subscribe :name as Node | sublist /Cards/? | subscribe :name as Card"
    );

    result.verify([
      {
        "path": "/downstream/PCSC Security/PCSC_ATL110/Cards/000000010137",
        "Node": "PCSC_ATL110",
        "Card": "000000010137"
      },
      {
        "path": "/downstream/PCSC Security/PCSC_ATL110/Cards/000000010136",
        "Node": "PCSC_ATL110",
        "Card": "000000010136"
      },
      {
        "path": "/downstream/PCSC Security/PCSC_ATL112/Cards/000000010137",
        "Node": "PCSC_ATL112",
        "Card": "000000010137"
      },
      {
        "path": "/downstream/PCSC Security/PCSC_ATL112/Cards/000000010136",
        "Node": "PCSC_ATL112",
        "Card": "000000010136"
      }
    ]);
  });

  test("query traverses broker when a broker is the topmost path", () async {
    var ctx = createDeepQueryContext();
    var result = await ctx.capture("list /sub-broker/*");

    result.verify([
      {
        "path": "/sub-broker/downstream"
      },
      {
        "path": "/sub-broker/downstream/LinkA"
      },
      {
        "path": "/sub-broker/downstream/LinkA/metric"
      }
    ]);

    ctx.checkListedNodes([
      "/sub-broker",
      "/sub-broker/downstream",
      "/sub-broker/downstream/LinkA",
      "/sub-broker/downstream/LinkA/metric"
    ]);
  });
}
