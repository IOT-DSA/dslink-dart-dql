library dsa.query.parse.key_value;

import "package:petitparser/petitparser.dart";

import "package:dql/parsers/query.dart";

class KeyValueGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(expressions).end();

  expressions() => (whitespace().star() & ref(expression).separatedBy(
    (
      whitespace() |
      char(",")
    ).plus(),
    includeSeparators: false
  ) & whitespace().star()).pick(1);

  expression() => (
    ref(identifier) &
    char("=") &
    ref(value)
  ).permute(const [0, 2]);

  identifier() => pattern("A-Za-z0-9\$@_:./").plus().flatten();

  value() => ref(stringLiteral) |
    ref(nil) |
    ref(number) |
    ref(boolean) |
    ref(valueList);

  stringLiteral() => (
    ref(quote) &
    any().starLazy(ref(quote)).flatten() &
    ref(quote)
  ).pick(1);

  nil() => (
    string("null") |
    string("nil")
  ).flatten();

  number() => pattern("0-9.").plus().flatten();

  boolean() => (
    string("true") |
    string("false")
  ).flatten();

  valueList() => (
    char("[") &
    whitespace().star() &
    ref(value).separatedBy(
      whitespace().star() &
      char(",") &
      whitespace().star(),
      includeSeparators: false
    ) &
    whitespace().star() &
    char("]")
  ).pick(2);

  quote() => char('"') |
    char("'") |
    char('`');
}

class KeyValueGrammar extends GrammarParser {
  KeyValueGrammar() : super(new KeyValueGrammarDefinition());
}

class KeyValueParserDefinition extends KeyValueGrammarDefinition {
  @override
  expressions() => super.expressions().map((table) {
    var out = {};
    for (var row in table) {
      out[row[0]] = row[1];
    }
    return out;
  });

  @override
  boolean() => super.boolean().map((v) {
    return v == "true";
  });

  @override
  nil() => super.nil().map((v) {
    return null;
  });

  @override
  number() => super.number().map((v) {
    return num.parse(v);
  });

  @override
  valueList() => super.valueList().map((v) {
    return v;
  });
}

class KeyValueParser extends GrammarParser {
  static final KeyValueParser instance = new KeyValueParser();

  static Map<String, dynamic> doParse(String input) {
    Result result = instance.parse(input);
    if (result.isFailure) {
      result = new PowerParseError(result);
    }
    return result.value;
  }

  KeyValueParser() : super(new KeyValueParserDefinition());
}
