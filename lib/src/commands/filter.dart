part of dslink.dql.query;

class FilterQueryProcessor extends QueryProcessor {
  final QueryContext context;

  FilterTestCollection test;
  NodeFilter filter;
  Set<String> usedKeys;

  FilterQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    test = parseFilterTests(statement.argument);
    filter = createNodeFilter(test);
    usedKeys = FilterTestKeyCollector.collect(test);
  }

  @override
  Stream<QueryUpdate> process(Stream<QueryUpdate> stream) {
    return stream.where((QueryUpdate update) {
      if (update == null) {
        return false;
      }

      if (update.remove) {
        return true;
      }

      if (!update.hasAttribute("node")) {
        return false;
      } else {
        RemoteNode node = update.getAttribute("node");

        return filter(node, update);
      }
    });
  }

  @override
  void calculateColumnSet(Set<String> columns) {
  }

  @override
  void handleColumnSet(Set<String> columns) {
    toAutoSubscribe = usedKeys.difference(columns).where((String x) {
      return !x.startsWith("@") &&
        !x.startsWith(r"$") &&
        !x.startsWith(":");
    }).toList();
  }

  @override
  QueryProcessor createDependencyProcessor() {
    if (toAutoSubscribe != null && toAutoSubscribe.isNotEmpty) {
      SubscribeQueryProcessor processor = new SubscribeQueryProcessor(context);
      QueryStatement statement = new QueryStatement(
        "subscribe",
        toAutoSubscribe.join(" ")
      );
      processor.init(statement);

      return processor;
    }
    return null;
  }

  List<String> toAutoSubscribe;

  @override
  String toString() {
    return "Filter ${test == null ? 'none' : test}";
  }
}
