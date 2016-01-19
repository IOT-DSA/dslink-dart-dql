part of dslink.dql.query;

class SubscribeNodeQueryProcessor extends QueryProcessor {
  final QueryContext context;

  SubscribeNodeQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
  }

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    Map<String, StreamSubscription> subs = {};
    StreamController<QueryUpdate> controller;
    StreamSubscription sub;
    controller = new StreamController<QueryUpdate>(onListen: () {
      sub = stream.listen((QueryUpdate update) {
        String path = update.values["path"];
        if (update.remove) {
          if (subs.containsKey(path)) {
            subs.remove(path).cancel();
            controller.add(update);
          }
          return;
        }

        RemoteNode node = update.getAttribute("node");

        if (node != null) {
          if (node.configs[r"$type"] is String && !subs.containsKey(path)) {
            subs[path] = context.requester.subscribe(path, (ValueUpdate val) {
              QueryUpdate u = new QueryUpdate({
                "path": path,
                "value": val.value,
                "timestamp": val.ts
              });

              controller.add(u);
            });
          }
        }
      });
    }, onCancel: () {
      for (var sub in subs.values) {
        sub.cancel();
      }

      if (sub != null) {
        sub.cancel();
      }

      subs.clear();
    });
    return controller.stream;
  }
}
