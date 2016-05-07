part of dslink.dql.query.process;

abstract class QueryContext {
  QueryStream query(String input);

  StreamSubscription subscribe(String path, callback(ValueUpdate update), [int qos = 0]);
  Stream<RequesterListUpdate> list(String path);

  Future<RemoteNode> getRemoteNode(String path);

  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params);
}

abstract class QueryStatisticManager {
  void reportStart(String id);
  void reportEnd(String id);
}
