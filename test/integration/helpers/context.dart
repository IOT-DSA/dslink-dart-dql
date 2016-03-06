part of dql.test.query.integration;

class MockQueryContext extends BasicQueryContext {
  static const String DISCONNECTED_CONFIG = r"$disconnectedTs";

  MockNode root = new MockNode.rootNode();

  MockQueryContext(Map<String, QueryProcessorFactory> processors) :
      super(null, processors);

  @override
  Stream<RequesterListUpdate> list(String path) {
    var node = root.findNode(path);
    var controller = new StreamController<RequesterListUpdate>();

    if (node == null) {
      var remoteNode = _createDisconnectedRemoteNode(path);

      var update = new RequesterListUpdate(
        remoteNode,
        [],
        StreamStatus.open
      );

      controller.add(update);
    } else {
      var remoteNode = node.asRemoteNode();
      var update = new RequesterListUpdate(
        remoteNode,
        [],
        StreamStatus.open
      );

      controller.add(update);

      node.listController.stream.listen((String change) {
        remoteNode = node.asRemoteNode();
        var update = new RequesterListUpdate(
          remoteNode,
          [change],
          StreamStatus.open
        );

        controller.add(update);
      });
    }

    return controller.stream;
  }

  @override
  StreamSubscription subscribe(
    String path,
    callback(ValueUpdate update),
    [int qos = 0]) {
    var node = root.findNode(path);
    if (node == null) {
      return new Stream.fromIterable([
        null
      ]).listen(callback);
    } else {
      callback(node.lastValueUpdate);

      return node.values.stream.listen((update) {
        callback(update);
      });
    }
  }

  Future<MockResult> capture(String input, {
    Function work,
    int time: 10
  }) async {
    var updates = <QueryUpdate>[];
    var sub = query(input).listen((QueryUpdate update) {
      updates.add(update);
    });

    if (work != null) {
      work();
    }

    await new Future.delayed(new Duration(milliseconds: time));

    if (sub != null) {
      sub.cancel();
    }

    var rows = <MockRow>[];
    var map = <String, Map<String, dynamic>>{};

    for (QueryUpdate update in updates) {
      if (update.remove) {
        map.remove(update.id);
      } else {
        if (map.containsKey(update.id)) {
          map[update.id].addAll(update.values);
        } else {
          map[update.id] = update.values;
        }
      }
    }

    for (String key in map.keys) {
      rows.add(new MockRow(map[key]));
    }

    return new MockResult(rows);
  }

  @override
  Future<RemoteNode> getRemoteNode(String path) async {
    var node = root.findNode(path);

    if (node == null) {
      return _createDisconnectedRemoteNode(path);
    } else {
      return node.asRemoteNode();
    }
  }

  @override
  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params) {
    return new Stream.empty();
  }

  RemoteNode _createDisconnectedRemoteNode(String path) {
    var remoteNode = new RemoteNode(path);
    remoteNode.configs[DISCONNECTED_CONFIG] = ValueUpdate.getTs();
    return remoteNode;
  }
}
