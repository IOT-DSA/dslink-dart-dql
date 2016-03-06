part of dql.test.query.integration;

class MockResult {
  final List<MockRow> rows;

  MockResult(this.rows);

  @override
  String toString() => rows.map((row) {
    return row.toString();
  }).join("\n");

  void verify(List<Map> rowSpec) {
    expect(rows, hasLength(rowSpec.length));
    var i = 0;
    for (MockRow row in rows) {
      expect(row.values, equals(rowSpec[i]));
      i++;
    }
  }
}

class MockRow {
  final Map<String, dynamic> values;

  MockRow(this.values);

  @override
  String toString() => values.toString();
}
