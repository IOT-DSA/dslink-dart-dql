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

  Map<String, String> childs;

  SubscribeQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    childs = QuerySubscribeParser.doParse(statement.argument);
    if (childs.isEmpty) {
      childs = {
        "value": "value"
      };
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

          for (String target in childs.keys) {
            String rkey = childs[target];

            String targetPath = path;

            if (target.startsWith("../")) {
              targetPath = pathlib.normalize(
                pathlib.join(path, target)
              );
            } else {
              if (!target.startsWith("/")) {
                targetPath += "/";
              }
              targetPath += target;
            }

            out.values[rkey] = holder.values[rkey] = null;
            var parts = pathlib.split(target);

            if (parts.last.startsWith("@") || parts.last.startsWith(r"$")) {
              var trp = pathlib.normalize(
                pathlib.join(
                  path,
                  parts.sublist(0, parts.length - 1).join("/")
                )
              );

              String tra = parts.last;

              holder.subs[rkey] = context.list(trp).listen(
                (RequesterListUpdate update) {
                if (holder.values[rkey] != update.node.get(tra)) {
                  holder.values[rkey] = update.node.get(tra);
                  controller.add(holder.build());
                }
              });
            } else if (target == "value") {
              holder.subs[rkey] =
                context.subscribe(path, (ValueUpdate update) {
                  holder.values[rkey] = update.value;
                  controller.add(holder.build());
                });
            } else if (target == "value.timestamp") {
              holder.subs[rkey] = context.subscribe(path,
                (ValueUpdate update) {
                holder.values[rkey] = update.ts;
                controller.add(holder.build());
              });
            } else if (target == ":name") {
              holder.subs[rkey] = new Stream.fromIterable([
                path
              ]).listen((a) {
                holder.values[rkey] = new Path(a).name;
                controller.add(holder.build());
              });
            } else if (target == ":displayName") {
              holder.subs[rkey] = context.list(path).listen(
                (RequesterListUpdate update) {
                String name;
                if (update.node.configs[r"$name"] is String) {
                  name = update.node.configs[r"$name"];
                } else {
                  name = new Path(path).name;
                }

                if (name != holder.values[rkey]) {
                  holder.values[rkey] = name;
                  controller.add(holder.build());
                }
              });
            } else {
              String rk = target;
              bool ts = false;
              if (rk.endsWith(".timestamp")) {
                String rn = rk.substring(0, rk.length - 10);
                targetPath = targetPath.replaceAll("/${rk}", "/${rn}");
                ts = true;
              }

              holder.subs[rkey] = context.subscribe(targetPath,
                (ValueUpdate update) {
                holder.values[rkey] = ts ? update.ts : update.value;
                controller.add(holder.build());
              });
            }
          }

          controller.add(update.cloneAndStub(childs.values.toList()));

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

  @override
  void calculateColumnSet(Set<String> columns) {
    columns.addAll(childs.values);
  }

  @override
  void handleLeftHandProcessors(List<QueryProcessor> processors) {
    for (QueryProcessor processor in processors) {
      if (processor is SubscribeQueryProcessor) {
        childs.keys.where(
          (String k) => processor.childs[k] == childs[k]
        ).toList().forEach((k) {
          logger.fine("Subscribe: Drop ${k} (duplicate subscribe found)");
          childs.remove(k);
        });
      }
    }
  }

  @override
  String toString() {
    String children = childs == null ? "none" : childs.toString();
    return "Subscribe ${children}";
  }
}
