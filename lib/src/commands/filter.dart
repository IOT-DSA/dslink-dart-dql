part of dslink.dql.query;

class FilterQueryProcessor extends QueryProcessor {
  static const Iterable<QueryUpdate> emptyIterable =
    const EmptyIterable<QueryUpdate>();

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
  QueryStream process(QueryStream stream) {
    Set<String> visited = new Set<String>();

    return stream.expand((QueryUpdate update) {
      if (update == null) {
        return emptyIterable;
      }

      if (update.remove) {
        return [update];
      }

      if (!update.hasAttribute("node")) {
        return emptyIterable;
      } else {
        RemoteNode node = update.getAttribute("node");

        bool matches = filter(node, update);
        if (matches) {
          if (!visited.contains(update.id)) {
            visited.add(update.id);
          }
        } else if (visited.contains(update.id)) {
          visited.remove(update.id);
          QueryUpdate u = update.clone(remove: true);
          return [u];
        } else {
          return emptyIterable;
        }

        return [update];
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
