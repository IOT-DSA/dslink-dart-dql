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
  QueryStream process(QueryStream stream) {
    Map<String, SubscribeQueryHolder> holders = {};
    StreamController<QueryUpdate> controller;
    StreamSubscription sub;

    var handleUpdate = (QueryUpdate update) {
      int qos;

      {
        qos = stream.getIntAttribute("qos", 0);

        if (qos < 0) {
          qos = 0;
        }

        if (qos > 3) {
          qos = 3;
        }
      }

      String path = update.findNodePath();

      if (update.remove) {
        if (holders.containsKey(path)) {
          holders.remove(path).cancel();
        }
        controller.add(update);
        return;
      }

      if (!holders.containsKey(path)) {
        controller.add(update.cloneAndStub(childs.values.toList(), true));

        QueryUpdate out = update.clone();
        var holder = new SubscribeQueryHolder(context);
        holder.setup();
        holder.lastUpdate = update;

        for (String target in childs.keys) {
          String rkey = childs[target];

          holder.values[rkey] = null;

          String targetPath = path;

          if (target.startsWith("../")) {
            targetPath = pathlib.posix.normalize(
              pathlib.posix.join(path, target)
            );
          } else {
            if (!target.startsWith("/")) {
              targetPath += "/";
            }
            targetPath += target;
          }

          if (targetPath.startsWith("//")) {
            targetPath = targetPath.substring(1);
          }

          out.values[rkey] = holder.values[rkey] = null;
          var parts = pathlib.posix.split(target);

          if (parts.last.startsWith("@") || parts.last.startsWith(r"$")) {
            var trp = pathlib.posix.normalize(
              pathlib.posix.join(
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
            holder.subs[rkey] = context.subscribe(path, (ValueUpdate update) {
              holder.values[rkey] = update.value;
              controller.add(holder.build());
            }, qos);
          } else if (target == "value.timestamp") {
            holder.subs[rkey] = context.subscribe(path, (ValueUpdate update) {
              holder.values[rkey] = update.ts;
              controller.add(holder.build());
            }, qos);
          } else if (parts.last == ":name") {
            var trp = pathlib.posix.normalize(
              pathlib.posix.join(
                path,
                parts.sublist(0, parts.length - 1).join("/")
              )
            );

            holder.subs[rkey] = new Stream.fromIterable([
              trp
            ]).listen((a) {
              holder.values[rkey] = new Path(a).name;
              controller.add(holder.build());
            });
          } else if (parts.last == ":connectionType") {
            var trp = pathlib.posix.normalize(
              pathlib.posix.join(
                path,
                parts.sublist(0, parts.length - 1).join("/")
              )
            );

            var p = new Path(trp);

            holder.subs[rkey] = context.list(trp).listen((RequesterListUpdate update) {
              bool isBroker = update.node.configs[r"$is"] == "dsa/broker";
              bool isLink = update.node.configs[r"$is"] == "dsa/link";
              String connectionType;

              if (isBroker || isLink) {
                connectionType = p.parent.name;

                if (connectionType.isEmpty) {
                  connectionType = "root";
                }
              }

              holder.values[rkey] = connectionType;
              controller.add(holder.build());
            });
          } else if (parts.last == ":displayName") {
            var trp = pathlib.posix.normalize(
              pathlib.posix.join(
                path,
                parts.sublist(0, parts.length - 1).join("/")
              )
            );

            holder.subs[rkey] = context.list(trp).listen(
              (RequesterListUpdate update) {
              String name;
              if (update.node.configs[r"$name"] is String) {
                name = update.node.configs[r"$name"];
              } else {
                name = new Path(trp).name;
              }

              if (name != holder.values[rkey]) {
                holder.values[rkey] = name;
                controller.add(holder.build());
              }
            });
          } else if (parts.last == ":attributes") {
            var trp = pathlib.posix.normalize(
              pathlib.posix.join(
                path,
                parts.sublist(0, parts.length - 1).join("/")
              )
            );

            holder.subs[rkey] = context.list(trp).listen((RequesterListUpdate update) {
              var attributeNames = update.node.attributes.keys.toList();

              if (attributeNames != holder.values[rkey]) {
                holder.values[rkey] = attributeNames;
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

            holder.subs[rkey] = context.subscribe(targetPath, (ValueUpdate update) {
              holder.values[rkey] = ts ? update.ts : update.value;
              controller.add(holder.build());
            }, qos);
          }
        }

        holders[path] = holder;
      } else {
        holders[path].lastUpdate = update;
        controller.add(update.cloneAndMerge(holders[path].values));
      }
    };

    controller = new StreamController<QueryUpdate>.broadcast(onListen: () {
      sub = stream.listen(handleUpdate);
    }, onCancel: () {
      for (SubscribeQueryHolder holder in holders.values) {
        holder.cancel();
      }

      holders.clear();

      if (sub != null) {
        sub.cancel();
      }
    });

    return new WrappedQueryStream(stream, controller.stream);
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
