part of dslink.dql.entry;

class QueryNode extends SimpleNode {
  QueryNode(String path) : super(path) {
    configs.addAll({
      r"$name": "Query",
      r"$invokable": "read",
      r"$result": "stream",
      r"$params": [
        {
          "name": "query",
          "type": "string",
          "editor": "textarea",
          "placeholder": "list * | subscribe"
        }
      ]
    });
  }

  @override
  InvokeResponse invoke(Map params, Responder responder,
    InvokeResponse response, LocalNode parentNode,
    [int maxPermission = Permission.CONFIG]) {
    String input = params["query"];

    if (input is! String) {
      var err = new DSError(
        "invokeError",
        msg: "Expected 'input' to be a string."
      );
      response.close(err);
      return response;
    }

    input = input.trim();

    try {
      queryManager.runQuery(input, response);
    } catch (e, stack) {
      var err = new DSError(
        "invokeError",
        msg: e.toString(),
        detail: stack.toString()
      );
      response.close(err);
    }

    return response;
  }
}
