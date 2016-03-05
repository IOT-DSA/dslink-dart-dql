part of dslink.dql.entry;

class QueryManager {
  Map<String, OngoingQuery> queries = {};

  void runQuery(String input, InvokeResponse response) {
    logger.fine("Query Manager - Run Query: ${input}");
    OngoingQuery query = getOrCreateQuery(input);
    query.addResponse(response);
  }

  OngoingQuery getOrCreateQuery(String input) {
    if (hasQuery(input)) {
      logger.fine("Query Manager - Found attachable query: ${input}");
      return getQuery(input);
    }

    logger.fine("Query Manager - Creating query: ${input}");
    var stream = context.query(input);
    var query = queries[input] = new OngoingQuery(input, this, stream);

    return query;
  }

  OngoingQuery getQuery(String input) {
    return queries[input];
  }

  bool hasQuery(String input) {
    return queries[input] is OngoingQuery;
  }

  void destroyQuery(String input, [bool isFromQuery = false]) {
    var query = queries.remove(input);
    if (query != null && !isFromQuery) {
      query.destroy();
    }

    logger.fine("Query Manager - Query destroyed: ${input}");
  }
}
