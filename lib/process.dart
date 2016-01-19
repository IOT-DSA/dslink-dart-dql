library dslink.dql.query.process;

import "dart:async";

import "package:dslink/requester.dart";

import "parse.dart";

typedef QueryProcessor QueryProcessorFactory(QueryContext context);

class QueryUpdate {
  final Map values;
  final bool remove;

  QueryUpdate(this.values, {this.remove: false, this.attributes});

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
}

abstract class QueryProcessor implements StreamTransformer<QueryUpdate, QueryUpdate> {
  void init(QueryStatement statement);
}

abstract class QueryContext {
  Requester get requester;
  Stream<QueryUpdate> query(String input);
}

Stream<QueryUpdate> processQuery(List<QueryProcessor> processors) {
  Stream<QueryUpdate> stream = new Stream<QueryUpdate>.empty();
  for (QueryProcessor processor in processors) {
    stream = processor.bind(stream);
  }
  return stream;
}

class QueryException {
  final String message;

  QueryException(this.message);

  @override
  String toString() => message;
}
