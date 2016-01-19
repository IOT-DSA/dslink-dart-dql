library dslink.dql.query;

import "dart:async";

import "package:dslink/dslink.dart";

import "process.dart";
import "parse.dart";

part "src/commands/list.dart";
part "src/commands/subscribe.dart";
part "src/commands/filter.dart";
part "src/commands/child.dart";
part "src/commands/path.dart";
part "src/commands/drop.dart";

final Map<String, QueryProcessorFactory> QUERY_COMMANDS = {
  "list": (QueryContext context) => new ListNodeQueryProcessor(context),
  "subscribe": (QueryContext context) => new SubscribeNodeQueryProcessor(context),
  "filter": (QueryContext context) => new FilterQueryProcessor(context),
  "child": (QueryContext context) => new ChildQueryProcessor(context),
  "path": (QueryContext context) => new SinglePathQueryProcessor(context),
  "drop": (QueryContext context) => new DropQueryProcessor(context)
};
