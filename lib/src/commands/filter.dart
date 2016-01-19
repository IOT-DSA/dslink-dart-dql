part of dslink.dql.query;

class FilterQueryProcessor extends QueryProcessor {
  final QueryContext context;

  NodeFilter filter;

  FilterQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    filter = parseFilterInput(statement.argument);
  }

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    return stream.where((QueryUpdate update) {
      if (update.remove) {
        return true;
      }

      if (!update.hasAttribute("node")) {
        return false;
      } else {
        RemoteNode node = update.getAttribute("node");

        return filter(node);
      }
    });
  }
}
