part of dslink.dql.query.process;

class QueryException {
  final String message;

  QueryException(this.message);

  @override
  String toString() => message;
}
