part of dslink.dql.query;

class BasicQueryContext extends QueryContext {
  final Requester requester;

  BasicQueryContext(this.requester);

  @override
  Stream<QueryUpdate> query(String input) {
    logger.fine("Run Query: ${input}");

    var processors = parse(input);
    return processQuery(processors);
  }

  List<QueryProcessor> parse(String input) {
    List<QueryStatement> statements = parseQueryInput(input);

    logger.fine("Parse Query: ${statements}");

    List<QueryProcessor> processors = statements.map(
      (QueryStatement statement) {
      if (!QUERY_COMMANDS.containsKey(statement.command)) {
        throw new QueryException(
          "Failed to parse query: unknown command '${statement.command}'"
        );
      }

      QueryProcessor processor = QUERY_COMMANDS[statement.command](this);
      processor.init(statement);
      return processor;
    }).toList();

    return processors;
  }

  @override
  Stream<RequesterListUpdate> list(String path) {
    return requester.list(path);
  }

  @override
  StreamSubscription subscribe(String path, callback(ValueUpdate update), [
    int qos = 0
  ]) {
    return requester.subscribe(path, callback, qos);
  }

  @override
  Future<RemoteNode> getRemoteNode(String path) {
    return requester.getRemoteNode(path);
  }

  @override
  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params) {
    return requester.invoke(actionPath, params);
  }
}
