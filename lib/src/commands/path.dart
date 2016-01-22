part of dslink.dql.query;

class SinglePathQueryProcessor extends QueryProcessor {
  final QueryContext context;

  String path;

  SinglePathQueryProcessor(this.context);

  @override
  void init(QueryStatement statement) {
    path = statement.argument;
  }

  @override
  Stream<QueryUpdate> process(Stream<QueryUpdate> stream) {
    return new Stream.fromIterable([
      new QueryUpdate({
        "path": path
      })
    ]);
  }
}
