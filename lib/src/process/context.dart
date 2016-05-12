part of dslink.dql.query.process;

abstract class QueryContext {
  QueryStream query(String input);

  StreamSubscription subscribe(String path, callback(ValueUpdate update), [int qos = 0]);
  Stream<RequesterListUpdate> list(String path);

  Future<RemoteNode> getRemoteNode(String path);

  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params);
}

class WrappedQueryContext extends QueryContext {
  final QueryContext innerContext;

  WrappedQueryContext(this.innerContext);

  @override
  Future<RemoteNode> getRemoteNode(String path) {
    return getRemoteNode(resolveRealPath(path)).then((RemoteNode node) {
      node.remotePath;
    });
  }

  @override
  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params) {
    return innerContext.invoke(resolveRealPath(actionPath), params);
  }

  @override
  Stream<RequesterListUpdate> list(String path) {
    return innerContext.list(resolveRealPath(path));
  }

  @override
  QueryStream query(String input) {
    throw new QueryException(
      "Wrapped Query Contexts can not execute queries. (Query: '${input}')"
    );
  }

  @override
  StreamSubscription subscribe(String path, callback(ValueUpdate update), [int qos = 0]) {
    return innerContext.subscribe(resolveRealPath(path), callback, qos);
  }

  String resolveRealPath(String path) => path;
}

abstract class QueryStatisticManager {
  void reportStart(String id);
  void reportEnd(String id);
}
