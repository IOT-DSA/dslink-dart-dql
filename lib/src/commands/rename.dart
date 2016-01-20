part of dslink.dql.query;

class RenameQueryProcessor extends QueryProcessor {
  final QueryContext context;

  Map<String, String> columns;

  RenameQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    columns = parseStringMapInput(statement.argument);
  }

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      QueryUpdate r = update.clone();
      for (String key in columns.keys) {
        String t = columns[key];
        var val = r.values.remove(key);
        r.values[t] = val;
      }

      if (update.values.containsKey("path") && !r.values.containsKey("path")) {
        r.setAttribute("id", update.values["path"]);
      }

      return r;
    });
  }
}
