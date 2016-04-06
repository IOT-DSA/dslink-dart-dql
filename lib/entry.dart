library dslink.dql.entry;

import "dart:async";

import "package:dslink/dslink.dart";
import "package:dslink/utils.dart" show logger;

import "package:dql/query.dart";
import "package:dql/process.dart";

part "src/entry/ongoing_query.dart";
part "src/entry/query_manager.dart";
part "src/entry/query_node.dart";
part "src/entry/query_row.dart";

BasicQueryContext context;
QueryManager queryManager;
LinkProvider link;

main(List<String> args) async {
  link = new LinkProvider(
    args,
    "DQL-",
    isResponder: true,
    isRequester: true
  );

  queryManager = new QueryManager();

  (link.provider as SimpleNodeProvider).setNode(
    "/query",
    new QueryNode("/query")
  );

  (link.provider as SimpleNodeProvider).setNode(
    "/getRunningQueries",
    new GetQueriesNode("/getRunningQueries")
  );

  SimpleNode node;

  node = link.addNode("/uniqueQueryCount", {
    r"$name": "Unique Query Count",
    r"$type": "number",
    "?value": 0
  });

  node.serializable = false;

  node = link.addNode("/totalQueryCount", {
    r"$name": "Total Query Count",
    r"$type": "number",
    "?value": 0
  });

  node.serializable = false;

  try {
    link.removeNode("/currentUniqueQueryCount");
    link.removeNode("/currentTotalQueryCount");
  } catch (e) {}

  SimpleNode virtualListCount = link.addNode("/virtualListCount", {
    r"$name": "Virtual List Count",
    r"$type": "number",
    "?value": 0
  });

  SimpleNode virtualSubscribeCount = link.addNode("/virtualSubscribeCount", {
    r"$name": "Virtual Subscribe Count",
    r"$type": "number",
    "?value": 0
  });

  virtualListCount.serializable = false;
  virtualSubscribeCount.serializable = false;

  link.connect();
  await link.onRequesterReady;
  context = new BasicQueryContext(link.requester, baseQueryCommandSet);

  context.registerStatisticHandler((id, count) {
    if (id == "vlist") {
      virtualListCount.updateValue(count);
    } else if (id == "vsubscribe") {
      virtualSubscribeCount.updateValue(count);
    }
  });
}

class GetQueriesNode extends SimpleNode {
  GetQueriesNode(String path) : super(path) {
    configs[r"$name"] = "Get Running Queries";
    configs[r"$invokable"] = "read";
    configs[r"$columns"] = [
      {
        "name": "query",
        "type": "string"
      },
      {
        "name": "listeners",
        "type": "number"
      }
    ];
    configs[r"$result"] = "table";
  }

  @override
  onInvoke(Map<String, dynamic> params) {
    return queryManager.queries.keys.map(((String input) {
      return [
        input,
        queryManager.queries[input].listenCount
      ];
    })).toList();
  }
}
