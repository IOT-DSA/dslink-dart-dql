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
    Future<QueryUpdate> get() async {
      var node = await context.requester.getRemoteNode(path);
      return new QueryUpdate({
        "path": path
      }, attributes: {
        "node": node
      });
    }
    return new Stream.fromFuture(get());
  }
}
