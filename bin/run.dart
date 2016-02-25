import "dart:async";

import "package:dslink/dslink.dart";

import "package:dql/query.dart";
import "package:dql/process.dart";

final List<String> POSSIBLE_IDS = [
  "id",
  "path"
];

BasicQueryContext context;

class QueryNode extends SimpleNode {
  QueryNode(String path) : super(path) {
    configs.addAll({
      r"$name": "Query",
      r"$invokable": "read",
      r"$result": "stream",
      r"$params": [
        {
          "name": "query",
          "type": "string",
          "editor": "textarea",
          "placeholder": "list * | subscribe"
        }
      ]
    });
  }

  @override
  onInvoke(Map params) {
    Completer<LiveTable> c = new Completer();
    String input = params["query"];
    LiveTable table;
    Map<String, LiveTableRow> rows = {};

    StreamSubscription sub;

    String lastColumnString = "";

    sub = context.query(input).listen((QueryUpdate update) {
      var forceRefresh = false;
      if (!update.remove) {
        List<String> keys = update.values.keys.toList();
        keys.sort();
        String myColumnString = keys.join(" ");
        if (myColumnString != lastColumnString && table != null) {
          table.columns.clear();
          table.columns.addAll(update.values.keys.map((String key) {
            return new TableColumn(key, "dynamic");
          }));
          forceRefresh = true;
        }
        lastColumnString = myColumnString;
      }

      if (table == null) {
        table = new LiveTable(update.values.keys.map((String key) {
          return new TableColumn(key, "dynamic");
        }).toList());

        table.doOnClose(() {
          if (sub != null) {
            sub.cancel();
          }
        });

        c.complete(table);
      }

      String path = update.id;

      if (!rows.containsKey(path)) {
        if (!update.remove) {
          rows[path] = table.createRow(update.values.values.toList());
        }
      } else {
        if (update.remove) {
          LiveTableRow r = rows.remove(path);
          if (r != null) {
            r.delete();
          }
        } else {
          List<dynamic> vals = update.values.values.toList();
          LiveTableRow row = rows[path];
          for (var i = 0; i < vals.length; i++) {
            row.values[i] = vals[i];
          }
          table.onRowUpdate(row);
        }
      }

      if (forceRefresh) {
        table.refresh();
      }
    });

    return c.future;
  }
}

LinkProvider link;

main(List<String> args) async {
  link = new LinkProvider(
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
  context = new BasicQueryContext(link.requester);
}

