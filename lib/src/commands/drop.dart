part of dslink.dql.query;

class DropQueryProcessor extends QueryProcessor {
  final QueryContext context;

  List<String> columns;

  DropQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    columns = parseInputParameters(statement.argument);
  }

  @override
  Stream<QueryUpdate> process(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      return update.cloneAndDrop(columns);
    });
  }

  @override
  void calculateColumnSet(Set<String> set) {
    set.removeAll(columns);
  }

  @override
  String toString() {
    String col = columns == null ? "" : columns.join(", ");

    return "Drop columns ${col}";
  }
}
