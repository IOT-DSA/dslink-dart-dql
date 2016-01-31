library dslink.dql.query;

import "dart:async";

import "package:dslink/dslink.dart";

import "package:dslink_dql/script.dart";

import "process.dart";
import "parse.dart";
import "filter.dart";

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
  "rename": (QueryContext context) => new RenameQueryProcessor(context)
};
