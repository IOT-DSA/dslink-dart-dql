library dslink.dql.query.process;

import "dart:async";
import "dart:convert";

import "package:dslink/common.dart" show ValueUpdate;
import "package:dslink/requester.dart";
import "package:dslink/utils.dart";

import "package:dql/parsers/query.dart";

const bool debugMode = const bool.fromEnvironment(
  "dql.mode.debug",
  defaultValue: false
);

final List<String> _possibleIdColumns = [
  "path",
  "id"
];

abstract class QueryStream extends Stream<QueryUpdate> {
  QueryStream get parent;

  QueryProcessor processor;
  Map<String, dynamic> attributes = {};

  dynamic getAttribute(String key) {
    if (hasAttribute(key)) {
      return attributes[key];
    } else if (parent != null) {
      return parent.getAttribute(key);
    }
    return null;
  }

  bool hasAttribute(String key, [bool search = false]) {
    bool has = attributes.containsKey(key);
    if (!has && search && parent != null) {
      has = parent.hasAttribute(key);
    }
    return has;
  }

  void setAttribute(String key, dynamic value) {
    attributes[key] = value;
  }

  void removeAttribute(String key) {
    attributes[key] = null;
  }

  @override
  QueryStream map(convert(QueryUpdate event)) {
    return new WrappedQueryStream(
      this,
      super.map(convert)
    );
  }

  @override
  QueryStream where(bool check(QueryUpdate event)) {
    return new WrappedQueryStream(
      this,
      super.where(check)
    );
  }
}

class WrappedQueryStream extends QueryStream {
  final QueryStream parent;
  final Stream<QueryUpdate> stream;

  WrappedQueryStream(this.parent, this.stream) {
    if (parent != null) {
      processor = parent.processor;
    }
  }

  @override
  StreamSubscription<QueryUpdate> listen(void onData(QueryUpdate event), {
    Function onError,
    void onDone(),
    bool cancelOnError
  }) {
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError
    );
  }
}

typedef QueryProcessor QueryProcessorFactory(QueryContext context);

class QueryUpdate {
  final Map values;
  final bool remove;

  String get id {
    if (hasAttribute("id")) {
      return getAttribute("id");
    }

    for (String mik in _possibleIdColumns) {
      if (values[mik] is String) {
        return values[mik];
      }
    }

    if (_id == null) {
      _id = generateBasicId();
    }

    return _id;
  }

  String findNodePath() {
    if (attributes["node"] is RemoteNode) {
      RemoteNode node = attributes["node"];

      return node.remotePath;
    }

    if (attributes["nodePath"] is String) {
      return attributes["nodePath"];
    }

    return values["path"];
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

  QueryUpdate cloneAndStub(List<String> keys, [bool force = false]) {
    QueryUpdate c = clone();
    for (String key in keys) {
      if (!force) {
        if (!c.values.containsKey(key)) {
          c.values[key] = null;
        }
      } else {
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

  QueryStream process(QueryStream stream);

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

abstract class QueryStatisticManager {
  void reportStart(String id);
  void reportEnd(String id);
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

  QueryStream stream = new WrappedQueryStream(
    null,
    new Stream<QueryUpdate>.empty()
  );
  _seqId++;
  int pid = 0;

  for (QueryProcessor processor in processors) {
    var id = ++pid;
    processor.calculateColumnSet(columns);
    stream = processor.bind(stream).map((QueryUpdate update) {
      update.setAttribute("lastProcessor", processor);
      return update;
    });

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

class QueryException {
  final String message;

  QueryException(this.message);

  @override
  String toString() => message;
}
