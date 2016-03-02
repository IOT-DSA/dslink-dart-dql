library dslink.dql.query;

import "dart:async";

import "package:dslink/common.dart";
import "package:dslink/requester.dart";

import "package:path/path.dart" as pathlib;

import "package:dslink/utils.dart" show logger;

import "process.dart";
import "parse.dart";
import "filter.dart";
import "subscribe.dart";
import "script.dart";
import "invoke.dart";

part "src/commands/list.dart";
part "src/commands/subscribe.dart";
part "src/commands/filter.dart";
part "src/commands/path.dart";
part "src/commands/drop.dart";
part "src/commands/expression.dart";
part "src/commands/rename.dart";
part "src/commands/invoke.dart";

part "src/query/basic_context.dart";

final Map<String, QueryProcessorFactory> BASE_QUERY_COMMANDS = {
  "list": (QueryContext context) => new ListNodeQueryProcessor(context),
  "subscribe": (QueryContext context) => new SubscribeQueryProcessor(context),
  "filter": (QueryContext context) => new FilterQueryProcessor(context),
  "child": (QueryContext context) => new SubscribeQueryProcessor(context),
  "path": (QueryContext context) => new SinglePathQueryProcessor(context),
  "drop": (QueryContext context) => new DropQueryProcessor(context),
  "expression": (QueryContext context) => new ExpressionQueryProcessor(context),
  "rename": (QueryContext context) => new RenameQueryProcessor(context),
  "where": (QueryContext context) => new FilterQueryProcessor(context),
  "invoke": (QueryContext context) => new InvokeQueryProcessor(context)
};
