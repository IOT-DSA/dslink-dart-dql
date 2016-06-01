part of dslink.dql.query;

class OptionQueryProcessor extends QueryProcessor {
  final QueryContext context;

  Map<String, dynamic> options;

  OptionQueryProcessor(this.context);

  @override
  void calculateColumnSet(Set<String> columns) {
  }

  @override
  void init(QueryStatement statement) {
    options = KeyValueParser.doParse(statement.argument);
  }

  @override
  QueryStream process(QueryStream stream) {
    QueryStream out = stream.map((QueryUpdate update) {
      return update;
    });

    options.forEach((a, b) {
      out.setAttribute("option:${a}", b);
    });

    return out;
  }

  @override
  String toString() => "Option ${options}";
}
