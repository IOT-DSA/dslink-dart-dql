part of dslink.dql.query.process;

typedef ValueUpdateCallback(ValueUpdate update);

abstract class QueryContext {
  QueryStream query(String input);
  StreamSubscription subscribe(
    String path,
    ValueUpdateCallback callback,
    [int qos = 0]);
  Stream<RequesterListUpdate> list(String path);
  Future<RemoteNode> getRemoteNode(String path);
  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params);

  Stream<ValueUpdate> getValueUpdates(String path, [int qos = 0]) {
    var controller = new StreamController<ValueUpdate>();
    var sub = subscribe(path, (ValueUpdate update) {
      controller.add(update);
    });
    controller.done.then((_) => sub.cancel());
    return controller.stream;
  }
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
  StreamSubscription subscribe(
    String path,
    ValueUpdateCallback callback,
    [int qos = 0]) {
    return innerContext.subscribe(resolveRealPath(path), callback, qos);
  }

  @override
  Stream<ValueUpdate> getValueUpdates(String path, [int qos = 0]) {
    return innerContext.getValueUpdates(resolveRealPath(path), qos);
  }

  String resolveRealPath(String path) => path;
}

abstract class QueryStatisticManager {
  void reportStart(String id);
  void reportEnd(String id);
}
