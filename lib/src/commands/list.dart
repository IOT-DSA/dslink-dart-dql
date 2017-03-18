part of dslink.dql.query;

class ListNodeHolder {
  final StreamSubscription sub;

  ListNodeHolder(this.sub);

  Function onDone;
}

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
    var holders = <String, ListNodeHolder>{};
    var uids = <String, String>{};
    var rescanUidPaths = <String, String>{};
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

      if (holders[path] is! ListNodeHolder) {
        var ourRealPath = resolveRealPath(path);

        var onDone = (String reason, [bool isUidSame = false, bool skipChildren = false]) {
          logger.finest("List Done ${path} (${reason})");

          if (!isUidSame && uid != null) {
            uids.remove(uid);
          }

          if (holders.containsKey(path)) {
            ListNodeHolder holder = holders.remove(path);
            if (holder != null) {
              holder.sub.cancel();
            }

            if (currentPaths.contains(path)) {
              QueryUpdate update = new QueryUpdate({
                "path": path
              }, attributes: {
                "id": ourRealPath
              }, remove: true);
              controller.add(update);
              currentPaths.remove(path);
            }

            if (!skipChildren) {
              var pathSlash = "${path}/";
              var functions = <Function>[];

              holders.forEach((String a, ListNodeHolder b) {
                if (a.startsWith(pathSlash) && b.onDone is Function) {
                  functions.add(b.onDone);
                }
              });

              for (var func in functions) {
                func("Parent was canceled.", false, true);
              }
            }

            if (context is QueryStatisticManager) {
              (context as QueryStatisticManager).reportEnd("vlist");
            }
          }

          if (!isUidSame && uid != null && rescanUidPaths[uid] != null) {
            handle(rescanUidPaths.remove(uid));
          }
        };

        if (context is QueryStatisticManager) {
          (context as QueryStatisticManager).reportStart("vlist");
        }

        logger.finest("List ${path}");

        var handleListUpdate = (RequesterListUpdate update) {
          if (update.node.configs.containsKey(r"$invokable") &&
            !enableActions) {
            onDone("Action not enabled.");
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
              var cholder = holders[cp];
              if (cholder is ListNodeHolder) {
                cholder.onDone("Child '${change}' was removed from the parent.");
                continue;
              }
            }
          }

          if (update.node.configs[r"$uid"] is String) {
            uid = update.node.configs[r"$uid"];

            var existing = uids[uid];
            if (existing != null) {
              if (existing != path) {
                var currentSlashCount = calculatePathPartCount(existing);
                var thisSlashCount = calculatePathPartCount(path);

                if (currentSlashCount > thisSlashCount) {
                  holders[existing].onDone(
                    "A node with the same UID of ${uid} (${path}) is shorter.",
                    true
                  );
                  rescanUidPaths[uid] = existing;
                } else if ((currentSlashCount == thisSlashCount) ||
                  (thisSlashCount > currentSlashCount)) {
                  onDone("A node with the same UID of ${uid} (${existing}) is present.", true);
                  return;
                }
              }
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
          bool isOffline = update.node.configs[r"$disconnectedTs"] is String;

          if (!isOffline && expression.matches(path, isBroker: isBroker)) {
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
          } else if (isOffline && currentPaths.contains(path)) {
            QueryUpdate event = new QueryUpdate({
              "path": path
            }, attributes: {
              "id": ourRealPath
            }, remove: true);
            controller.add(event);
            currentPaths.remove(path);
            logger.finest("List Offline ${path}");
            uids.remove(uid);
            if (uid != null && rescanUidPaths[uid] != null) {
              handle(rescanUidPaths.remove(uid));
            }
            return;
          } else if (currentPaths.contains(path)) {
            onDone("No longer matches expression.");
            return;
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

              if (stream.getBooleanAttribute("option:brokersIncludeQuarantine", false)) {
                handle("${ourFakePath}/sys/quarantine", depth + 1);
              }
            } else if (path.endsWith("/downstream") ||
              path.endsWith("/upstream") ||
              path.endsWith("/sys/quarantine")) {
              for (RemoteNode child in update.node.children.values) {
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

        ListNodeHolder holder;
        holder = new ListNodeHolder(context.list(ourRealPath).listen(handleListUpdate, onDone: () {
          if (holder != null && holder.onDone is Function) {
            holder.onDone("List stream closed.");
          }
        }));

        holder.onDone = onDone;
        holders[path] = holder;
      }
    }

    controller = new StreamController<QueryUpdate>.broadcast(onListen: () {
      handle(expression.topmost);
    }, onCancel: () async {
      if (passthrough != null) {
        passthrough.cancel();
      }

      for (ListNodeHolder holder in holders.values.toList()) {
        holder.onDone("Query Canceled.");
        await holder.sub.cancel();
      }

      holders.clear();
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

  @override
  String toString() {
    super.createDependencyProcessor();
    return "List ${expression == null ? 'none' : expression}";
  }
}
