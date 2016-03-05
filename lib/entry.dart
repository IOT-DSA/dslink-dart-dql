library dslink.dql.entry;

import "dart:async";

import "package:dslink/dslink.dart";

import "package:dql/query.dart";
import "package:dql/process.dart";

BasicQueryContext context;

class QueryTableRow {
  final Map<String, dynamic> values;
  int id;

  QueryTableRow(this.values);
  QueryTableRow.create() : values = {};

  List<dynamic> format(List<String> keys) {
    return keys.map((key) {
      return values[key];
    }).toList();
  }
}

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
  InvokeResponse invoke(Map params, Responder responder,
    InvokeResponse response, LocalNode parentNode,
    [int maxPermission = Permission.CONFIG]) {
    new Future(() async {
      String input = params["query"];
      Map<String, QueryTableRow> rows = {};

      StreamSubscription sub;

      List<String> knownColumns = <String>[];

      response.onClose = (_) {
        if (sub != null) {
          sub.cancel();
        }
      };

      sub = context.query(input).listen((QueryUpdate update) {
        var forceRefresh = false;
        if (!update.remove) {
          List<String> keys = update.values.keys.toList();
          var added = keys.where((x) => !knownColumns.contains(x)).toList();

          for (String key in added) {
            knownColumns.add(key);
          }

          if (added.isNotEmpty) {
            response.updateStream(
              [],
              columns: knownColumns
                .map((name) => new TableColumn(name, "dynamic"))
                .toList()
            );
          }
        }

        String path = update.id;

        if (!rows.containsKey(path)) {
          if (!update.remove) {
            var row = rows[path] = new QueryTableRow(update.values);
            row.id = rows.length - 1;

            response.updateStream(
              [row.format(knownColumns)],
              meta: {
                "mode": "append"
              }
            );
          }
        } else {
          if (update.remove) {
            QueryTableRow row = rows.remove(path);
            for (QueryTableRow m in rows.values) {
              if (m.id > row.id) {
                m.id--;
              }
            }

            forceRefresh = true;
          } else {
            QueryTableRow row = rows[path];
            row.values.addAll(update.values);
            response.updateStream(
              [row.format(knownColumns)],
              meta: {
                "modify": "replace ${row.id}-${row.id}"
              }
            );
          }
        }

        if (forceRefresh) {
          response.updateStream(
            rows.values
              .map((row) => row.format(knownColumns))
              .toList(),
            columns: knownColumns
              .map((name) => new TableColumn(name, "dynamic"))
              .toList(),
            meta: {
              "mode": "refresh"
            }
          );
        }
      });
    }).catchError((e, stack) {
      var err = new DSError(
        "invokeError",
        msg: e.toString(),
        detail: stack.toString()
      );
      response.close(err);
    });

    response.updateStream([], meta: {
      "mode": "refresh"
    });

    return response;
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
  context = new BasicQueryContext(link.requester, BASE_QUERY_COMMANDS);
}

