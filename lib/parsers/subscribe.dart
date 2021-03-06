library dsa.query.parse.subscribe;

import "package:petitparser/petitparser.dart";

import "package:dql/parsers/query.dart";

class QuerySubscribeGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(expressions).optional().end();

  expressions() => ref(expression).separatedBy(
    (
      whitespace().star() &
      char(",") &
      whitespace().star()
    ) | whitespace().plus(),
    includeSeparators: false
  );

  expression() => ref(mstring) & (
    whitespace().plus() &
    ref(op) &
    whitespace().plus() &
    ref(mstring)
  ).permute(const [1, 3]).optional();

  mstring() => ref(identifier) | ref(stringLiteral);

  identifier() => (
    pattern("A-Za-z0-9\$@_:./") |
    anyIn(const ["-"])
  ).plus().flatten();

  stringLiteral() => (
    ref(quote) &
    any().starLazy(ref(quote)).flatten() &
    ref(quote)
  ).pick(1);

  op() => (
    string("as")
  ).flatten();

  quote() => char('"') |
    char("'") |
    char('`');
}

class QuerySubscribeGrammar extends GrammarParser {
  QuerySubscribeGrammar() : super(new QuerySubscribeGrammarDefinition());
}

class QuerySubscribeParserDefinition extends QuerySubscribeGrammarDefinition {
  @override
  start() => super.start().map((v) {
    if (v == null) {
      return {};
    }

    Map<String, String> m = <String, String>{};

    for (List list in v) {
      String target = list[0];
      String name = list[1] == null ? target : list[1][1];

      if (target == null) {
        continue;
      }

      m[target] = name;
    }

    return m;
  });
}

class QuerySubscribeParser extends GrammarParser {
  static final QuerySubscribeParser instance = new QuerySubscribeParser();

  static Map<String, String> doParse(String input) {
    Result result = instance.parse(input);
    if (result.isFailure) {
      result = new PowerParseError(result);
    }
    return result.value;
  }

  QuerySubscribeParser() : super(new QuerySubscribeParserDefinition());
}
