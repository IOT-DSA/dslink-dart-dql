part of dslink.dql.entry;

class GetQueriesNode extends SimpleNode {
  GetQueriesNode(String path) : super(path) {
    configs[r"$name"] = "Get Running Queries";
    configs[r"$invokable"] = "read";
    configs[r"$columns"] = [
      {
        "name": "query",
        "type": "string"
      },
      {
        "name": "listeners",
        "type": "number"
      }
    ];
    configs[r"$result"] = "table";
  }

  @override
  onInvoke(Map<String, dynamic> params) {
    return queryManager.queries.keys.map(((String input) {
      return [
        input,
        queryManager.queries[input].listenCount
      ];
    })).toList();
  }
}
