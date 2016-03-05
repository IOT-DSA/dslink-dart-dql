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

  link.addNode("/currentUniqueQueryCount", {
    r"$name": "Current Unique Query Count",
    r"$type": "number",
    "?value": 0
  });

  link.addNode("/currentTotalQueryCount", {
    r"$name": "Current Total Query Count",
    r"$type": "number",
    "?value": 0
  });

  link.connect();
  await link.onRequesterReady;
  context = new BasicQueryContext(link.requester, BASE_QUERY_COMMANDS);
}
