part of dslink.dql.query;

class ListNodeQueryProcessor extends QueryProcessor {
  final QueryContext context;

  ListNodeQueryProcessor(this.context);

  PathExpression expression;
  bool allowActions = false;

  @override
  void init(QueryStatement statement) {
    allowActions = statement.command == "lista";
    expression = parseExpressionInput(statement.argument);
  }

  @override
  QueryStream process(QueryStream stream) {
    StreamSubscription passthrough;
    var subs = <String, StreamSubscription>{};
    var dones = <String, Function>{};
    Set<String> uids = new Set<String>();
    StreamController<QueryUpdate> controller;

    var traverseBrokers = false;

    if (stream.getAttribute("option:traverseBrokers") == true) {
      traverseBrokers = true;
    }

    controller = new StreamController<QueryUpdate>(onListen: () {
      void handle(String path, [int depth = 1]) {
        Path p = new Path(path);

        String uid;
        if (subs[path] is! StreamSubscription) {
          var onDone = ([bool isUidSame = false]) {
            if (!isUidSame && uid != null) {
              uids.remove(uid);
            }

            if (subs.containsKey(path)) {
              StreamSubscription sub = subs.remove(path);
              if (sub != null) {
                sub.cancel();
              }

              dones.remove(path);

              if (!isUidSame && expression.matches(path)) {
                QueryUpdate update = new QueryUpdate({
                  "path": path
                }, remove: true);
                controller.add(update);
              }

              subs.keys.where((p) => p.startsWith("${path}/")).toList().forEach((key) {
                if (dones[key] is Function) {
                  dones[key]();
                }
              });

              if (context is QueryStatisticManager) {
                (context as QueryStatisticManager).reportEnd("vlist");
              }
            }
          };

          dones[path] = onDone;

          if (context is QueryStatisticManager) {
            (context as QueryStatisticManager).reportStart("vlist");
          }

          logger.finer("List ${path}");

          subs[path] = context.list(path).listen((RequesterListUpdate update) {
            if (p.parentPath.endsWith("/upstream") &&
              update.node.configs[r"$uid"] == null) {
              onDone();
              return;
            }

            if (update.node.configs.containsKey(r"$invokable") &&
              !allowActions) {
              onDone();
              return;
            }

            for (String change in update.changes) {
              if (change.startsWith(r"$") || change.startsWith("@")) {
                continue;
              }

              if (!update.node.children.containsKey(change)) {
                String cp = path;
                if (!cp.endsWith("/")) {
                  cp += "/";
                }
                cp += change;
                if (dones.containsKey(cp)) {
                  dones[cp]();
                  continue;
                }
              }
            }

            if (update.node.configs[r"$uid"] is String) {
              uid = update.node.configs[r"$uid"];
              if (uids.contains(uid)) {
                onDone(true);
                return;
              }
              uids.add(uid);
            }

            if (expression.matches(path)) {
              String displayName = update.node.configs[r"$name"];
              if (displayName == null) {
                displayName = update.node.name;
              }

              QueryUpdate event = new QueryUpdate({
                "path": path
              }, attributes: {
                "node": update.node,
                ":name": update.node.name,
                ":displayName": displayName,
                "id": path
              });
              controller.add(event);
            }

            bool isBroker = update.node.configs[r"$is"] == "dsa/broker";
            bool handleChildren = expression.depthLimit <0 ||
              depth <= expression.depthLimit;

            if (p.isRoot) {
              isBroker = false;
            }

            if (isBroker && traverseBrokers == false) {
              handleChildren = false;
            }

            if (handleChildren) {
              for (RemoteNode child in update.node.children.values) {
                handle(child.remotePath, depth + 1);
              }
            }
          }, onDone: () {
            if (dones.containsKey(path)) {
              dones[path]();
            }
          });
        }
      }

      handle(expression.topmost);
    }, onCancel: () {
      for (Function onDone in dones.values.toList()) {
        onDone();
      }

      for (var sub in subs.values) {
        sub.cancel();
      }

      subs.clear();
      uids.clear();
    });

    passthrough = stream.listen((QueryUpdate update) {
      controller.add(update);
    }, onError: controller.addError);

    return new WrappedQueryStream(stream, controller.stream);
  }

  @override
  void calculateColumnSet(Set<String> columns) {
    columns.add("path");
  }

  @override
  String toString() {
    return "List ${expression == null ? 'none' : expression}";
  }
}
