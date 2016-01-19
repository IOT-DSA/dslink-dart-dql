import "dart:async";
import "package:dslink/dslink.dart";

import "package:dslink_dql/query.dart";
import "package:dslink_dql/process.dart";
import "package:dslink_dql/parse.dart";

class BasicQueryContext extends QueryContext {
  @override
  Requester get requester => link.requester;

  @override
  Stream<QueryUpdate> query(String input) {
    List<QueryStatement> statements = parseQueryInput(input);
    List<QueryProcessor> processors = statements.map((QueryStatement statement) {
      if (!QUERY_COMMANDS.containsKey(statement.command)) {
        throw new QueryException(
          "Failed to parse query: unknown command '${statement.command}'"
        );
      }

      QueryProcessor processor = QUERY_COMMANDS[statement.command](this);
      processor.init(statement);
      return processor;
    }).toList();

    return processQuery(processors);
  }
}

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

    sub = context.query(input).listen((QueryUpdate update) {
      if (table == null) {
        table = new LiveTable(update.values.keys.map((String key) {
          return new TableColumn(key, "dynamic");
        }));

        table.doOnClose(() {
          if (sub != null) {
            sub.cancel();
          }
        });

        c.complete(table);
      }

      String path = update.values["path"];

      if (!rows.containsKey(path)) {
        if (!update.remove) {
          rows[path] = table.createRow(update.values.values.toList());
        }
      } else {
        if (update.remove) {
          rows.remove(path).delete();
        } else {
          List<dynamic> vals = update.values.values.toList();
          LiveTableRow row = rows[path];
          for (var i = 0; i < vals.length; i++) {
            row.values[i] = vals[i];
          }
          table.onRowUpdate(row);
        }
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
  context = new BasicQueryContext();
}

