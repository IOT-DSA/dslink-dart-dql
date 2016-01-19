part of dslink.dql.query;

class DropQueryProcessor extends QueryProcessor {
  final QueryContext context;

  List<String> columns;

  DropQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    columns = statement.argument.split(" ").map((x) => x.trim()).where((String n) {
      return n.isNotEmpty;
    }).toList();
  }

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      return update.cloneAndDrop(columns);
    });
  }
}
