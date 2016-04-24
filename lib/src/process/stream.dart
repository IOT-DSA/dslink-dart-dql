part of dslink.dql.query.process;

abstract class QueryStream extends Stream<QueryUpdate> {
  static bool autoAssembleTable = false;

  QueryStream() {
    if (autoAssembleTable) {
      new Future(() {
        assemble();
      });
    }
  }

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

  QueryTableAssembly assemble() {
    if (_assembly != null) {
      return _assembly;
    }

    return _assembly = new QueryTableAssembly(this);
  }

  QueryTableAssembly _assembly;
}

class WrappedQueryStream extends QueryStream {
  final QueryStream parent;

  Stream<QueryUpdate> _stream;

  WrappedQueryStream(this.parent, Stream<QueryUpdate> stream, {
    bool broadcast: true
  }) : super() {
    _stream = broadcast ? stream.asBroadcastStream() : stream;
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
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError
    );
  }
}
