part of dslink.dql.query;

class SublistHolder {
  final String path;

  SublistHolder(this.path);

  SublistListQueryProcessor listProcessor;
  StreamSubscription<QueryUpdate> listSub;
  List<String> _handles = <String>[];

  Iterable<String> destroy() {
    if (listSub != null) {
      listSub.cancel();
      listSub = null;
    }

    return _handles;
  }

  Stream<QueryUpdate> create(SublistQueryProcessor sublist) {
    listProcessor = new SublistListQueryProcessor(path, sublist.context);
    listProcessor.init(new QueryStatement("list", sublist.expression));

    return processQuery([listProcessor]).map((QueryUpdate update) {
      var np = update.findNodePath();
      var rp = path;
      if (rp.endsWith("/")) {
        rp = rp.substring(0, rp.length - 1);
      }
      rp += np;

      if (update.remove) {
        _handles.remove(rp);
      } else if (!_handles.contains(rp)) {
        _handles.add(rp);
      }

      return update.cloneAndMerge({
        "path": rp
      });
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
            controller.add(new QueryUpdate({
              "path": path
            }, remove: true));
          }
        }
      } else {
        // We don't care about updates. Paths don't really change.
        if (holders.containsKey(path)) {
          return;
        }

        var holder = new SublistHolder(path);
        holder.listSub = holder.create(this).listen((QueryUpdate update) {
          controller.add(update);
        });

        holders[path] = holder;
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

