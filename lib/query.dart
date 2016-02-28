library dslink.dql.query;

import "dart:async";

import "package:dslink/common.dart";
import "package:dslink/requester.dart";

import "package:dslink/utils.dart" show logger;

import "process.dart";
import "parse.dart";
import "filter.dart";
import "subscribe.dart";
import "script.dart";

part "src/commands/list.dart";
part "src/commands/subscribe.dart";
part "src/commands/filter.dart";
part "src/commands/path.dart";
part "src/commands/drop.dart";
part "src/commands/expression.dart";
part "src/commands/rename.dart";

final Map<String, QueryProcessorFactory> QUERY_COMMANDS = {
  "list": (QueryContext context) => new ListNodeQueryProcessor(context),
  "subscribe": (QueryContext context) => new SubscribeQueryProcessor(context),
  "filter": (QueryContext context) => new FilterQueryProcessor(context),
  "child": (QueryContext context) => new SubscribeQueryProcessor(context),
  "path": (QueryContext context) => new SinglePathQueryProcessor(context),
  "drop": (QueryContext context) => new DropQueryProcessor(context),
  "expression": (QueryContext context) => new ExpressionQueryProcessor(context),
  "rename": (QueryContext context) => new RenameQueryProcessor(context),
  "where": (QueryContext context) => new FilterQueryProcessor(context)
};

class BasicQueryContext extends QueryContext {
  final Requester requester;

  BasicQueryContext(this.requester);

  @override
  Stream<QueryUpdate> query(String input) {
    var processors = parse(input);
    return processQuery(processors);
  }

  List<QueryProcessor> parse(String input) {
    logger.fine("Run Query: ${input}");

    List<QueryStatement> statements = parseQueryInput(input);

    logger.fine("Parse Query: ${statements}");

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

    return processors;
  }

  @override
  Stream<RequesterListUpdate> list(String path) {
    return requester.list(path);
  }

  @override
  StreamSubscription subscribe(String path, callback(ValueUpdate update)) {
    return requester.subscribe(path, callback);
  }

  @override
  Future<RemoteNode> getRemoteNode(String path) {
    return requester.getRemoteNode(path);
  }
}
