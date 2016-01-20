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
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    return stream.map((QueryUpdate update) {
      if (update.remove) {
        return update;
      }

      if (expressions.isEmpty) {
        return update;
      }

      QueryUpdate result = update.clone();
      MathExpressions.Parser parser = new MathExpressions.Parser();
      MathExpressions.ContextModel model = new MathExpressions.ContextModel();
      for (String key in update.values.keys) {
        var val = update.values[key];
        if (val is num) {
          try {
            var variable = new MathExpressions.Variable(key);
            model.bindVariable(variable, new MathExpressions.Number(val));
          } catch (e) {}

          if (key == "value") {
            var variable = new MathExpressions.Variable("val");
            model.bindVariable(variable, new MathExpressions.Number(val));
          }
        }
      }

      for (String key in expressions.keys) {
        var ex = expressions[key];
        if (ex is String) {
          var expr = parser.parse(ex);
          try {
            var rm = expr.evaluate(MathExpressions.EvaluationType.REAL, model);
            result.values[key] = rm;
          } catch (e) {
            result.values[key] = "ERROR: ${e}";
          }
        }
      }

      return result;
    });
  }
}
