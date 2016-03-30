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
  QueryStream process(QueryStream stream) {
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
          var v = doExecuteScript(ex, result.values);
          if (v != null) {
            result.values[key] = v;
          } else if (!result.values.containsKey(key)) {
            result.values[key] = null;
          }
        }
      }

      return result;
    });
  }

  @override
  void calculateColumnSet(Set<String> columns) {
    columns.addAll(expressions.keys);
  }

  @override
  String toString() {
    return "Expressions ${expressions}";
  }
}
