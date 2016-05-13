part of dslink.dql.query;

class ListNodeQueryProcessor extends QueryProcessor {
  final QueryContext context;

  ListNodeQueryProcessor(this.context);

  String commandUsed;
  PathExpression expression;
  bool allowActions = false;

  @override
  void init(QueryStatement statement) {
    commandUsed = statement.command;
    allowActions = statement.command == "lista";
    expression = parseExpressionInput(statement.argument);
  }

  @override
  QueryStream process(QueryStream stream) {
    StreamSubscription passthrough;
    var subs = <String, StreamSubscription>{};
    var dones = <String, Function>{};
    var uids = new Map<String, String>();
    var currentPaths = <String>[];
    StreamController<QueryUpdate> controller;

    var traverseBrokers = false;
    var enableActions = allowActions;

    if (stream.getAttribute("option:traverseBrokers") == true) {
      traverseBrokers = true;
    }

    if (stream.getAttribute("option:listActions") == true) {
      enableActions = true;
    }

    void handle(String path, [int depth = 1]) {
      Path p = new Path(path);

      String uid;
      if (subs[path] is! StreamSubscription) {
        var onDone = ([bool isUidSame = false]) {
          logger.finer("List Done ${path}");

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

        var ourRealPath = resolveRealPath(path);

        var handleListUpdate = (RequesterListUpdate update) {
          if (update.node.configs.containsKey(r"$invokable") &&
            !enableActions) {
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
            var existing = uids[uid];
            if (existing != null && existing != path) {
              onDone(true);
              return;
            }

            if (update.changes.contains(r"$uid")) {
              var drops = [];

              for (String id in uids.keys) {
                if (id != uid && uids[id] == path) {
                  drops.add(id);
                }
              }

              for (String id in drops) {
                uids.remove(id);
              }
            }

            uids[uid] = path;
          }

          bool isBroker = update.node.configs[r"$is"] == "dsa/broker";
          bool isLink = update.node.configs[r"$is"] == "dsa/link";

          if (expression.matches(path, isBroker: isBroker)) {
            if (!currentPaths.contains(path)) {
              currentPaths.add(path);
            }

            String displayName = update.node.configs[r"$name"];
            if (displayName == null) {
              displayName = update.node.name;
            }

            var values = <String, dynamic>{
              "path": path
            };

            QueryUpdate event = new QueryUpdate(values, attributes: {
              "node": update.node,
              ":name": update.node.name,
              ":displayName": displayName,
              "id": ourRealPath,
              "nodePath": path
            });
            controller.add(event);
          } else if (currentPaths.contains(path)) {
            QueryUpdate event = new QueryUpdate({
              "path": path
            }, attributes: {
              "id": ourRealPath
            }, remove: true);
            controller.add(event);
            currentPaths.remove(path);
          }

          bool handleChildren = expression.depthLimit < 0 ||
            depth <= expression.depthLimit;

          bool isSubBroker = isBroker;

          if (p.isRoot) {
            isSubBroker = false;
          }

          if (isSubBroker && traverseBrokers == false) {
            handleChildren = false;
          }

          var ourFakePath = reverseResolvePath(ourRealPath);
          if (ourFakePath == "/") {
            ourFakePath = "";
          }

          if (expression.directive == "brokers") {
            if (isBroker) {
              handle("${ourFakePath}/downstream", depth + 1);
              handle("${ourFakePath}/upstream", depth + 1);

              if (stream.getBooleanAttribute("brokersIncludeQuarantine", false)) {
                handle("${ourFakePath}/sys/quarantine", depth + 1);
              }
            } else if (path.endsWith("/downstream") ||
              path.endsWith("/upstream") ||
              path.endsWith("/sys/quarantine")) {
              for (RemoteNode child in update.node.children.values) {
                if (child.getConfig(r"$is") != "dsa/broker") {
                  continue;
                }

                var childPath = "${ourFakePath}/${child.name}";
                handle(childPath, depth + 1);
              }
            }
          } else if (handleChildren) {
            for (String key in update.node.children.keys) {
              var child = update.node.children[key];
              if (child.getConfig(r"$invokable") != null && !allowActions) {
                continue;
              }

              handle("${ourFakePath}/${key}", depth + 1);
            }
          }
        };

        subs[path] = context.list(ourRealPath).listen(handleListUpdate, onDone: () {
          if (dones.containsKey(path)) {
            dones[path]();
          }
        });
      }
    }

    controller = new StreamController<QueryUpdate>.broadcast(onListen: () {
      handle(expression.topmost);
    }, onCancel: () {
      if (passthrough != null) {
        passthrough.cancel();
      }

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
    }, onDone: controller.close, onError: controller.addError);

    return new WrappedQueryStream(stream, controller.stream);
  }

  @override
  void calculateColumnSet(Set<String> columns) {
    columns.add("path");
  }

  @override
  String toString() {
    super.createDependencyProcessor();
    return "List ${expression == null ? 'none' : expression}";
  }

  bool _hasAddedProcessor = false;

  @override
  QueryProcessor createDependencyProcessor() {
    if (!_hasAddedProcessor &&
      expression != null &&
      expression.secondary != null &&
      expression.secondary.isNotEmpty) {
      var proc = new ListNodeQueryProcessor(context);
      proc.init(new QueryStatement(commandUsed, expression.secondary));
      _hasAddedProcessor = true;
      return proc;
    }
    return null;
  }

  String reverseResolvePath(String path) {
    return path;
  }

  String resolveRealPath(String path) {
    return path;
  }
}
