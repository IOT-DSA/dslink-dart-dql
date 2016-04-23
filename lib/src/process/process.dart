part of dslink.dql.query.process;

int _seqId = 0;

QueryStream processQuery(List<QueryProcessor> processors) {
  logger.fine("Process Query: ${processors}");

  Set<String> columns = new Set<String>();
  List<QueryProcessor> stage = new List<QueryProcessor>.from(processors);

  for (QueryProcessor processor in processors) {
    processor.handleColumnSet(columns);
    processor.calculateColumnSet(columns);
  }

  int pidx = 0;
  for (QueryProcessor processor in processors) {
    List<QueryProcessor> leftHand = processors.sublist(0, pidx);
    processor.handleLeftHandProcessors(leftHand);
    QueryProcessor p = processor.createDependencyProcessor();
    if (p != null) {
      stage.insert(stage.indexOf(processor), p);
    }
    pidx++;
  }

  if (stage.length != processors.length) {
    return processQuery(stage);
  }

  processors.clear();
  processors = stage;

  logger.fine("Process Final Query: ${processors}");

  StreamCompleter<QueryUpdate> completer = new StreamCompleter<QueryUpdate>();

  QueryStream stream = new WrappedQueryStream(
    null,
    completer.stream
  );
  _seqId++;
  int pid = 0;

  for (QueryProcessor processor in processors) {
    var id = ++pid;
    processor.calculateColumnSet(columns);
    var s = processor.bind(stream);

    if (s is! QueryStream) {
      s = new WrappedQueryStream(stream, s);
    }
    stream = s;

    stream.processor = processor;

    if (debugMode) {
      stream = stream.map((QueryUpdate u) {
        print("[${_seqId} ${id}] ${processor.runtimeType} => ${u.values}");
        return u;
      });

      stream.processor = processor;
    }
  }
  return stream;
}
