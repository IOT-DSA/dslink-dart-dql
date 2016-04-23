part of dslink.dql.query.process;

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

  QueryTableAssembly assemble() {
    return new QueryTableAssembly(this);
  }
}

class WrappedQueryStream extends QueryStream {
  final QueryStream parent;

  Stream<QueryUpdate> _stream;

  WrappedQueryStream(this.parent, Stream<QueryUpdate> stream) {
    _stream = stream;
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
