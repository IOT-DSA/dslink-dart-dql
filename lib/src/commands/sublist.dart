part of dslink.dql.query;

class SublistHolder {
  final String path;

  QueryUpdate oldUpdate;

  SublistHolder(this.path);

  SublistListQueryProcessor listProcessor;
  StreamController<QueryUpdate> controller;

  StreamSubscription<QueryUpdate> listSub;
  Map<String, QueryUpdate> _handles = <String, QueryUpdate>{};

  Iterable<String> destroy() {
    if (listSub != null) {
      listSub.cancel();
      listSub = null;
    }

    if (controller != null) {
      controller.close();
      controller = null;
    }

    return _handles.keys;
  }

  void onOldUpdate(QueryUpdate update) {
    if (update == null) {
      return;
    }
    oldUpdate = update;

    for (String key in _handles.keys.toList()) {
      var lastToSend = _handles[key];
      var newUpdateToSend = lastToSend.cloneAndMerge(oldUpdate.values);
      newUpdateToSend.values["path"] = lastToSend.values["path"];
      controller.add(newUpdateToSend);
      _handles[key] = newUpdateToSend;
    }
  }

  QueryStream create(SublistQueryProcessor sublist) {
    listProcessor = new SublistListQueryProcessor(path, sublist.context);
    listProcessor.init(new QueryStatement("list", sublist.expression));

    return processQuery([listProcessor]).map((QueryUpdate update) {
      var np = update.findNodePath();
      var rp = path;
      if (rp.endsWith("/")) {
        rp = rp.substring(0, rp.length - 1);
      }
      rp += np;

      var out = update;

      if (oldUpdate != null) {
        out = out.cloneAndMerge(oldUpdate.values);
      }

      out = out.cloneAndMerge({
        "path": rp
      });

      out.setAttribute("nodePath", rp);

      if (update.remove) {
        _handles.remove(rp);
      } else if (!_handles.containsKey(rp)) {
        _handles[rp] = out;
      }

      return out;
    });
  }
}

class SublistListQueryProcessor extends ListNodeQueryProcessor {
  String _basePath;
  String _basePathS;

  SublistListQueryProcessor(String base, QueryContext context) : super(context) {
    _basePath = base;
    if (_basePath.endsWith("/")) {
      _basePath = _basePath.substring(0, _basePath.length - 1);
    }

    _basePathS = _basePath + "/";
  }

  @override
  String reverseResolvePath(String path) {
    if (path.startsWith(_basePathS)) {
      var result = path.substring(_basePath.length);
      return result;
    } else {
      return path;
    }
  }

  @override
  String resolveRealPath(String path) {
    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    var result = "${_basePathS}${path}";
    return result;
  }
}

class SublistQueryProcessor extends QueryProcessor {
  final QueryContext context;

  String expression;

  SublistQueryProcessor(this.context);

  QueryStream process(QueryStream stream) {
    StreamController<QueryUpdate> controller;
    StreamSubscription parentStreamSub;

    var holders = <String, SublistHolder>{};

    var handleUpdate = (QueryUpdate update) {
      String path = update.findNodePath();

      if (path == null) {
        return;
      }

      if (update.remove) {
        if (holders.containsKey(path)) {
          SublistHolder holder = holders.remove(path);
          var toDrop = holder.destroy();
          for (String toDropPath in toDrop) {
            if (!controller.isClosed) {
              controller.add(new QueryUpdate({
                "path": path
              }, remove: true));
            }
          }
        }
      } else {
        SublistHolder holder = holders[path];

        if (holder == null) {
          holder = new SublistHolder(path);

          holder.listSub = holder.create(this).listen((QueryUpdate update) {
            if (!controller.isClosed) {
              controller.add(update);
            }
          });

          holder.controller = controller;
          holders[path] = holder;
        }
        holder.onOldUpdate(update);
      }
    };

    controller = new StreamController<QueryUpdate>(onListen: () {
      parentStreamSub = stream.listen(handleUpdate);
    }, onCancel: () {
      if (parentStreamSub != null) {
        parentStreamSub.cancel();
        parentStreamSub = null;
      }

      for (SublistHolder holder in holders.values) {
        holder.destroy();
      }
      holders.clear();
    });
    return new WrappedQueryStream(stream, controller.stream);
  }

  @override
  void calculateColumnSet(Set<String> columns) {
    columns.add("path");
  }

  @override
  void init(QueryStatement statement) {
    expression = statement.argument;
  }
}
