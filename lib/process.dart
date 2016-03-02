library dslink.dql.query.process;

import "dart:async";
import "dart:convert";

import "package:dslink/common.dart" show ValueUpdate;
import "package:dslink/requester.dart";
import "package:dslink/utils.dart";

import "parse.dart";

final bool DEBUG = false;

final List<String> POSSIBLE_IDS = [
  "path",
  "id"
];

typedef QueryProcessor QueryProcessorFactory(QueryContext context);

class QueryUpdate {
  final Map values;
  final bool remove;

  String get id {
    if (hasAttribute("id")) {
      return getAttribute("id");
    }

    for (String mik in POSSIBLE_IDS) {
      if (values[mik] is String) {
        return values[mik];
      }
    }

    if (_id == null) {
      _id = generateBasicId();
    }

    return _id;
  }

  String _id;

  QueryUpdate(this.values, {this.remove: false, this.attributes}) {
    if (attributes == null) {
      attributes = {};
    }
  }

  Map<String, dynamic> attributes = {};

  dynamic getAttribute(String key) {
    return attributes[key];
  }

  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }

  void setAttribute(String key, value) {
    attributes[key] = value;
  }

  dynamic removeAttribute(String key) {
    return attributes.remove(key);
  }

  QueryUpdate clone({bool remove}) {
    if (remove == null) {
      remove = this.remove;
    }

    QueryUpdate update = new QueryUpdate(
      new Map.from(values),
      remove: remove,
      attributes: new Map.from(attributes)
    );

    if (_id != null) {
      update._id = _id;
    }

    return update;
  }

  QueryUpdate cloneAndMerge(Map<String, dynamic> m) {
    QueryUpdate c = clone();
    c.values.addAll(m);
    return c;
  }

  QueryUpdate cloneAndDrop(List<String> keys) {
    QueryUpdate c = clone();
    for (String key in keys) {
      c.values.remove(key);
    }
    return c;
  }

  QueryUpdate cloneAndStub(List<String> keys) {
    QueryUpdate c = clone();
    for (String key in keys) {
      if (!c.values.containsKey(key)) {
        c.values[key] = null;
      }
    }
    return c;
  }

  Map toJSON() {
    return {
      "values": values,
      "remove": remove
    };
  }

  @override
  String toString() {
    return const JsonEncoder().convert(toJSON());
  }
}

abstract class QueryProcessor implements StreamTransformer<QueryUpdate, QueryUpdate> {
  void init(QueryStatement statement);

  void calculateColumnSet(Set<String> columns);
  void handleColumnSet(Set<String> columns) {}
  void handleLeftHandProcessors(List<QueryProcessor> processors) {}

  QueryProcessor createDependencyProcessor() {
    return null;
  }

  Stream<QueryUpdate> process(Stream<QueryUpdate> stream);

  @override
  Stream<QueryUpdate> bind(Stream<QueryUpdate> stream) {
    var result = process(stream);
    if (result == null) {
      return stream;
    } else {
      return result;
    }
  }
}

abstract class QueryContext {
  Stream<QueryUpdate> query(String input);

  StreamSubscription subscribe(String path, callback(ValueUpdate update));
  Stream<RequesterListUpdate> list(String path);

  Future<RemoteNode> getRemoteNode(String path);

  Stream<RequesterInvokeUpdate> invoke(String actionPath, Map params);
}

int _seqId = 0;

Stream<QueryUpdate> processQuery(List<QueryProcessor> processors) {
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

  Stream<QueryUpdate> stream = new Stream<QueryUpdate>.empty();
  _seqId++;
  int pid = 0;

  for (QueryProcessor processor in processors) {
    var id = ++pid;
    processor.calculateColumnSet(columns);
    stream = processor.bind(stream).map((QueryUpdate update) {
      update.setAttribute("lastProcessor", processor);
      return update;
    });

    if (DEBUG) {
      stream = stream.map((QueryUpdate u) {
        print("[${_seqId} ${id}] ${processor.runtimeType} => ${u.values}");
        return u;
      });
    }
  }
  return stream;
}

class QueryException {
  final String message;

  QueryException(this.message);

  @override
  String toString() => message;
}
