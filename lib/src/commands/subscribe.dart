part of dslink.dql.query;

class SubscribeQueryProcessor extends QueryProcessor {
  static final List<SubscribeProvider> subscribeProviders = <SubscribeProvider>[
    new AttributeNamesSubscribeProvider(),
    new SpecialKeySubscribeProvider(),
    new ValueSubscribeProvider()
  ];

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
      int qos = stream.getIntAttribute("qos", 0);

      if (qos < 0) {
        qos = 0;
      }

      if (qos > 3) {
        qos = 3;
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
          String  key = childs[target];

          holder.values[key] = null;
          out.values[key] = null;

          var request = new SubscribeQueryRequest(
            path,
            key,
            target,
            context,
            holder,
            qos,
            controller
          );

          providerLoop: for (SubscribeProvider provider in subscribeProviders) {
            if (provider.canHandle(key)) {
              provider.process(request);
              break providerLoop;
            }
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
