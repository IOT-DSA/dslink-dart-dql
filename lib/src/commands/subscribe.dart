part of dslink.dql.query;

class SubscribeQueryHolder {
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

class SubscribeQueryProcessor extends QueryProcessor {
  final QueryContext context;

  List<String> childs;

  SubscribeQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    childs = parseInputParameters(statement.argument);
    if (childs.isEmpty) {
      childs = ["value"];
    }
  }

  @override
  Stream<QueryUpdate> process(Stream<QueryUpdate> stream) {
    Map<String, SubscribeQueryHolder> holders = {};
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
          var holder = new SubscribeQueryHolder();
          holder.lastUpdate = update;

          for (String n in childs) {
            String cp = path;
            if (!n.startsWith("/")) {
              cp += "/";
            }
            cp += n;
            out.values[n] = holder.values[n] = null;
            if (n.startsWith("@") || n.startsWith(r"$")) {
              holder.subs[n] = context.requester.list(path).listen((
                RequesterListUpdate update) {
                if (holder.values[n] != update.node.get(n)) {
                  holder.values[n] = update.node.get(n);
                  controller.add(holder.build());
                }
              });
            } else if (n == "value") {
              holder.subs[n] =
                context.requester.subscribe(path, (ValueUpdate update) {
                  holder.values[n] = update.value;
                  controller.add(holder.build());
                });
            } else if (n == "value.timestamp") {
              holder.subs[n] =
                  context.requester.subscribe(path, (ValueUpdate update) {
                    holder.values[n] = update.ts;
                    controller.add(holder.build());
                  });
            } else if (n == ":name") {
              holder.subs[n] = new Stream.fromIterable([
                path
              ]).listen((a) {
                holder.values[n] = new Path(a).name;
                controller.add(holder.build());
              });
            } else if (n == ":displayName") {
              holder.subs[n] = context.requester.list(path).listen((
                  RequesterListUpdate update) {
                String name;
                if (update.node.configs[r"$name"] is String) {
                  name = update.node.configs[r"$name"];
                } else {
                  name = new Path(path).name;
                }

                if (name != holder.values[n]) {
                  holder.values[n] = name;
                  controller.add(holder.build());
                }
              });
            } else {
              String rk = n;
              bool ts = false;
              if (rk.endsWith(".timestamp")) {
                String rn = rk.substring(0, rk.length - 10);
                cp = cp.replaceAll("/${rk}", "/${rn}");
                ts = true;
              }

              holder.subs[n] = context.requester.subscribe(cp, (ValueUpdate update) {
                holder.values[n] = ts ? update.ts : update.value;
                controller.add(holder.build());
              });
            }
          }

          controller.add(update.cloneAndStub(childs));

          holders[path] = holder;
        } else {
          holders[path].lastUpdate = update;
          controller.add(update.cloneAndMerge(holders[path].values));
        }
      });
    }, onCancel: () {
      for (SubscribeQueryHolder holder in holders.values) {
        holder.cancel();
      }

      holders.clear();

      if (sub != null) {
        sub.cancel();
      }
    });

    return controller.stream;
  }
}
