library dslink.dql.query;

import "dart:async";

import "package:dslink/dslink.dart";

import "process.dart";
import "parse.dart";

part "src/commands/list.dart";
part "src/commands/subscribe.dart";
part "src/commands/filter.dart";

final Map<String, QueryProcessorFactory> QUERY_COMMANDS = {
  "list": (QueryContext context) => new ListNodeQueryProcessor(context),
  "subscribe": (QueryContext context) => new SubscribeNodeQueryProcessor(context),
  "filter": (QueryContext context) => new FilterQueryProcessor(context)
};
