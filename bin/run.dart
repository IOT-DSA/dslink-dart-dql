import "dart:async";
import "package:dslink/dslink.dart";

import "package:dslink_dql/query.dart";

class QueryNode extends SimpleNode {
  static QueryManager query;

  QueryNode(String path) : super(path) {
    configs.addAll({
      r"$name": "Query",
      r"$invokable": "read",
      r"$result": "stream",
      r"$params": [
        {
          "name": "query",
          "type": "string",
          "placeholder": "list * | subscribe"
        }
      ]
    });
  }

  @override
  onInvoke(Map params) {
    Completer<LiveTable> c = new Completer();
    String input = params["query"];
    bool isFirst = true;
    LiveTable table;
    Map<String, LiveTableRow> rows = {};
    StreamSubscription sub;
    sub = query.query(input).listen((Map map) {
      if (isFirst) {
        table = new LiveTable(map.keys.map((x) {
          return new TableColumn(x, "dynamic");
        }));

        c.complete(table);

        table.doOnClose(() {
          sub.cancel();
        });

        isFirst = false;
      }

      String path = map["path"];
      if (!rows.containsKey(path)) {
        rows[path] = table.createRow(map.values.toList());
      } else {
        List<dynamic> vals = map.values.toList();
        for (var i = 0; i < vals.length; i++) {
          rows[path].values[i] = vals[i];
        }

        table.onRowUpdate(rows[path]);
      }
    });

    return c.future;
  }
}

main(List<String> args) async {
  LinkProvider link = new LinkProvider(
    args,
    "DQL-",
    isResponder: true,
    isRequester: true
  );

  (link.provider as SimpleNodeProvider).setNode(
    "/query",
    new QueryNode("/query")
  );

  link.connect();
  await link.onRequesterReady;
  QueryNode.query = new QueryManager(link.requester);
}

