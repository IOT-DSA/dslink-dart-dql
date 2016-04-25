part of dslink.dql.query;

class QueryInvokeHolder {
  Map<String, dynamic> params = {};
  StreamSubscription sub;
  String actionPath;

  QueryInvokeHolder();
}

class InvokeQueryProcessor extends QueryProcessor {
  final QueryContext context;

  QueryInvokeCall call;

  InvokeQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    call = QueryInvokeParser.doParse(statement.argument);
  }

  @override
  void calculateColumnSet(Set<String> columns) {
  }

  @override
  QueryStream process(QueryStream stream) {
    Map<String, QueryInvokeHolder> holders = {};
    StreamController controller;
    StreamSubscription sub;

    controller = new StreamController<QueryUpdate>.broadcast(onListen: () {
      sub = stream.listen((QueryUpdate update) {
        String path = update.findNodePath();

        if (path is! String) {
          controller.add(update);
          return;
        }

        if (update.remove) {
          var holder = holders.remove(path);
          if (holder != null) {
            if (holder.sub != null) {
              holder.sub.cancel();
              holder.sub = null;
            }
          }
          controller.add(update);
          return;
        }

        QueryInvokeHolder holder = holders[path];
        if (holder == null) {
          holder = holders[path] = new QueryInvokeHolder();
          holder.params.addAll(call.baseParams);
        }

        if (holder.actionPath == null) {
          holder.actionPath = call.resolvePath(path);
        }

        bool doInvokeAgain = call.requiredColumns.isEmpty;
        for (String key in call.requiredColumns.keys) {
          var currentHoldValue = holder.params[key];
          var currentUpdateValue = update.values[call.requiredColumns[key]];
          if (!holder.params.containsKey(key) || (
            currentHoldValue != currentUpdateValue
          )) {
            holder.params[key] = currentUpdateValue;
            doInvokeAgain = true;
          }
        }

        if (doInvokeAgain) {
          if (holder.sub != null) {
            holder.sub.cancel();
            holder.sub = null;
          }

          holder.sub = context.invoke(holder.actionPath, holder.params)
            .listen((inv) {
          });
        }

        controller.add(update);
        return;
      });
    }, onCancel: () {
      for (QueryInvokeHolder holder in holders.values) {
        if (holder.sub != null) {
          holder.sub.cancel();
          holder.sub = null;
        }
      }

      holders.clear();

      if (sub != null) {
        sub.cancel();
      }
    });

    return new WrappedQueryStream(stream, controller.stream);
  }
}
