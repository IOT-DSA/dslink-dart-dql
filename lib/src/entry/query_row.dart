part of dslink.dql.entry;

class QueryTableRow {
  final Map<String, dynamic> values;

  int id;

  QueryTableRow(this.values);
  QueryTableRow.create() : values = {};

  List<dynamic> format(List<String> keys) {
    return keys.map((key) {
      return values[key];
    }).toList();
  }
}
