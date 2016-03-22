library dql.test.statement.grammar;

import "dart:io";

import "package:yaml/yaml.dart";
import "package:test/test.dart";

import "package:dql/parsers/query.dart";

const String CASE_FILE = "test/parser/cases/statement_grammar.yaml";

main() async {
  File file = new File(Uri.base.resolve(CASE_FILE).toFilePath());
  Map<String, List<List<String>>> cases = loadYaml(await file.readAsString());
  group("Query Grammar", () {
    for (var input in cases.keys) {
      test(input, () {
        var grammar = new QueryStatementGrammar();
        var result = grammar.parse(input).value;

        expect(result, equals(cases[input]));
      });
    }
  });
}
