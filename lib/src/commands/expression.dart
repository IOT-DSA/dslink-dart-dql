part of dslink.dql.query;

class ExpressionQueryProcessor extends QueryProcessor {
  final QueryContext context;

  Map<String, String> expressions;

  ExpressionQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    expressions = parseStringMapInput(statement.argument);
  }

  @override
  Stream<QueryUpdate> process(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      if (update.remove) {
        return update;
      }

      if (expressions.isEmpty) {
        return update;
      }

      QueryUpdate result = update.clone();
      for (String key in expressions.keys) {
        var ex = expressions[key];
        if (ex is String) {
          result.values[key] = doExecuteScript(ex, update.values);
        }
      }

      return result;
    });
  }
}
