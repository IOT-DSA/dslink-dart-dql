part of dslink.dql.query.process;

typedef QueryProcessor QueryProcessorFactory(QueryContext context);

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
