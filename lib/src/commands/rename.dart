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
  QueryStream process(QueryStream stream) {
    return stream.map((QueryUpdate update) {
      QueryUpdate r = update.clone();
      for (String key in columns.keys) {
        String t = columns[key];
        var val = r.values.remove(key);
        r.values[t] = val;
      }

      if (update.values.containsKey("path") && !r.values.containsKey("path")) {
        r.setAttribute("nodePath", update.values["path"]);
      }

      return r;
    });
  }

  @override
  void calculateColumnSet(Set<String> set) {
    set.removeAll(columns.keys);
    set.addAll(columns.values);
  }

  @override
  String toString() {
    return "Rename ${columns == null ? 'none' : columns}";
  }
}
