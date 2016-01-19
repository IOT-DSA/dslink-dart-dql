part of dslink.dql.query;

class ChildQueryHolder {
  Map<String, dynamic> values = {};
  Map<String, StreamSubscription> subs = {};
  QueryUpdate lastUpdate;

  void cancel() {
    for (StreamSubscription sub in subs.values) {
      sub.cancel();
    }
    subs.clear();
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

class ChildQueryProcessor extends QueryProcessor {
  final QueryContext context;

  List<String> childs;

  ChildQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    childs = statement.argument.split(" ").map((x) => x.trim()).where((String n) {
      return n.isNotEmpty;
    }).toList();
  }

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    Map<String, ChildQueryHolder> holders = {};
    StreamController<QueryUpdate> controller;
    StreamSubscription sub;
    controller = new StreamController<QueryUpdate>(onListen: () {
      sub = stream.listen((QueryUpdate update) {
        String path = update.values["path"];
        if (update.remove) {
          if (holders.containsKey(path)) {
            holders.remove(path).cancel();
          }
          controller.add(update);
          return;
        }

        if (!holders.containsKey(path)) {
          QueryUpdate out = update.clone();
          var holder = new ChildQueryHolder();
          holder.lastUpdate = update;

          for (String n in childs) {
            String cp = "${path}/${n}";
            out.values[n] = holder.values[n] = null;
            holder.subs[cp] = context.requester.subscribe(cp, (ValueUpdate update) {
              holder.values[n] = update.value;
              controller.add(holder.build());
            });
          }

          controller.add(update.cloneAndStub(childs));

          holders[path] = holder;
        } else {
          holders[path].lastUpdate = update;
          controller.add(update.cloneAndMerge(holders[path].values));
        }
      });
    });

    return controller.stream;
  }
}
