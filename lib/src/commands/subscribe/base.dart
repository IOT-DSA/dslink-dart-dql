part of dslink.dql.query;

class SubscribeQueryHolder {
  final QueryContext context;

  SubscribeQueryHolder(this.context);

  Map<String, dynamic> values = {};
  Map<String, StreamSubscription> subs = {};
  QueryUpdate lastUpdate;

  void setup() {
    if (context is QueryStatisticManager) {
      (context as QueryStatisticManager).reportStart("vsubscribe");
    }
  }

  void cancel() {
    for (StreamSubscription sub in subs.values) {
      sub.cancel();
    }
    subs.clear();

    if (context is QueryStatisticManager) {
      (context as QueryStatisticManager).reportEnd("vsubscribe");
    }
  }

  QueryUpdate build() {
    QueryUpdate u = lastUpdate;
    if (u == null) {
      u = new QueryUpdate({});
    }

    u.values.addAll(values);

    return u;
  }
}

class SubscribeQueryRequest {
  final String path;
  final String column;
  final String key;
  final QueryContext context;
  final SubscribeQueryHolder holder;
  final int qos;
  final StreamController<QueryUpdate> controller;

  SubscribeQueryRequest(
    this.path,
    this.key,
    this.column,
    this.context,
    this.holder,
    this.qos,
    this.controller);

  void respond(Stream<dynamic> input) {
    holder.subs[column] = input.listen((value) {
      holder.values[column] = value;
      controller.add(holder.build());
    });
  }
}

abstract class SubscribeProvider {
  bool canHandle(String key);
  void process(SubscribeQueryRequest request);
}
