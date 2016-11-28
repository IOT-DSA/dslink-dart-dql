part of dslink.dql.query;

typedef void OnStatisticUpdated(String id, int count);

class BasicQueryContext extends QueryContext implements QueryStatisticManager {
  final Map<String, QueryProcessorFactory> processors;
  final Requester requester;

  BasicQueryContext(this.requester, this.processors);

  @override
  QueryStream query(String input) {
    logger.fine("Run Query: ${input}");

    var processors = parse(input);
    return processQuery(processors);
  }

  List<QueryProcessor> parse(String input) {
    List<QueryStatement> statements = parseQueryInput(input);

    logger.fine("Parse Query: ${statements}");

    List<QueryProcessor> proc = statements.map(
      (QueryStatement statement) {
      if (!processors.containsKey(statement.command)) {
        throw new QueryException(
          "Failed to parse query: unknown command '${statement.command}'"
        );
      }

      QueryProcessor processor = processors[statement.command](this);
      processor.init(statement);
      return processor;
    }).toList();

    return proc;
  }

  @override
  Stream<RequesterListUpdate> list(String path) async* {
    var node = requester.nodeCache.getRemoteNode(path);
    if (node != null && node.isSelfUpdated()) {
      var allDataChanges = <String>[];
      allDataChanges.addAll(node.configs.keys);
      allDataChanges.addAll(node.children.keys);
      allDataChanges.addAll(node.attributes.keys);
      yield new RequesterListUpdate(node, allDataChanges, "open");
    }
    yield* requester.list(path);
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

  @override
  void reportEnd(String id) {
    int count = 0;
    if (_stats[id] is int) {
      count = _stats[id] - 1;
      if (count < 0) {
        count = 0;
      }
    }

    _stats[id] = count;

    for (OnStatisticUpdated handler in _statWatchers) {
      handler(id, count);
    }
  }

  @override
  void reportStart(String id) {
    int count = _stats[id];
    if (count == null || count < 0) {
      count = 0;
    }

    count++;

    _stats[id] = count;

    for (OnStatisticUpdated handler in _statWatchers) {
      handler(id, count);
    }
  }

  Map<String, int> _stats = {};

  int getStatistic(String id) {
    if (_stats[id] is int) {
      return _stats[id];
    } else {
      return 0;
    }
  }

  List<OnStatisticUpdated> _statWatchers = [];

  void registerStatisticHandler(OnStatisticUpdated handler) {
    if (!_statWatchers.contains(handler)) {
      _statWatchers.add(handler);
    }
  }

  void unregisterStatisticHandler(OnStatisticUpdated handler) {
    _statWatchers.remove(handler);
  }
}
