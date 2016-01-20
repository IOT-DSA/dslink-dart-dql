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
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      var result = update.cloneAndDrop(columns);
      if (columns.contains("path") && update.values.containsKey("path")) {
        result.setAttribute("id", update.values["path"]);
      }
      return result;
    });
  }
}
