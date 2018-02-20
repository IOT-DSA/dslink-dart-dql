part of dslink.dql.query;

const bool enableNewNodeTracker = false;

typedef void OnStatisticUpdated(String id, int count);

class BasicQueryContext extends QueryContext implements QueryStatisticManager {
  final Map<String, QueryProcessorFactory> processors;
  final Requester requester;

  Set<String> nodePathsSeen = enableNewNodeTracker ? new Set<String>() : null;

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

  Stream<RequesterListUpdate> _listCacheHit(RemoteNode node, String path) async* {
    var allDataChanges = <String>[];
    allDataChanges.addAll(node.configs.keys);
    allDataChanges.addAll(node.children.keys);
    allDataChanges.addAll(node.attributes.keys);
    yield new RequesterListUpdate(node, allDataChanges, "open");
    yield* requester.list(path);
  }

  @override
  Stream<RequesterListUpdate> list(String path, {
    bool enableCache: false
  }) {
    _reportNodeSeen(path);

    if (enableCache) {
      var node = requester.nodeCache.getRemoteNode(path);
      if (node != null && node.isSelfUpdated()) {
        return _listCacheHit(node, path);
      }
    }

    return requester.list(path);
  }

  @override
  StreamSubscription subscribe(String path, callback(ValueUpdate update), [
    int qos = 0
  ]) {
    _reportNodeSeen(path);

    return requester.subscribe(path, callback, qos);
  }

  @override
  Future<RemoteNode> getRemoteNode(String path) {
    _reportNodeSeen(path);

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

    reportStatistic(id, count);
  }

  @override
  void reportStart(String id) {
    int count = _stats[id];
    if (count == null || count < 0) {
      count = 0;
    }

    count++;

    _stats[id] = count;

    reportStatistic(id, count);
  }

  void reportStatistic(String id, int value) {
    for (OnStatisticUpdated handler in _statWatchers) {
      handler(id, value);
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

  void updateGenericStatistics({bool reportCachedNodes: false}) {
    reportStatistic("requests", requester.openRequestCount);
    reportStatistic("subscriptions", requester.subscriptionCount);

    if (reportCachedNodes) {
      reportStatistic("cached-nodes", requester.nodeCache.cachedNodePaths.length);
    }
  }

  void _reportNodeSeen(String path) {
    if (enableNewNodeTracker) {
      if (!nodePathsSeen.contains(path)) {
        nodePathsSeen.add(path);
        print("[DQL] ${nodePathsSeen.length} paths seen (${path})");
      }
    }
  }
}
