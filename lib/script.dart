library dslink.dql.script;

import "package:math_expressions/math_expressions.dart" as MathExpressions;

dynamic doExecuteScript(String script, Map variables) {
  MathExpressions.Parser parser = new MathExpressions.Parser();
  MathExpressions.ContextModel model = new MathExpressions.ContextModel();
  for (String key in variables.keys) {
    var val = variables[key];
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

  var expr = parser.parse(script);
  try {
    var rm = expr.evaluate(MathExpressions.EvaluationType.REAL, model);
    return rm;
  } catch (e) {
    return "ERROR: ${e}";
  }
}
