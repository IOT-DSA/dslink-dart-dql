library dsa.query.parse.filter;

import "package:petitparser/petitparser.dart";

final Existent EXISTS = Existent.EXISTS;

abstract class FilterTest {
  bool matches(Map m);
}

class Existent {
  static const Existent EXISTS = const Existent();

  const Existent();

  @override
  String toString() => "[EXISTS]";
}

class FilterLogicalTest extends FilterTest {
  final FilterTest left;
  final FilterTest right;
  final String op;

  FilterLogicalTest(this.left, this.right, this.op);

  @override
  bool matches(Map m) {
    if (op == "||" || op == "or") {
      bool a = left.matches(m);
      if (a) {
        return true;
      }
      return right.matches(m);
    } else if (op == "&&" || op == "and") {
      bool a = left.matches(m);
      if (!a) {
        return false;
      }
      return right.matches(m);
    } else {
      return false;
    }
  }

  @override
  String toString() => "Logical(${left} ${op} ${right})";
}

class FilterCompareTest extends FilterTest {
  final String key;
  final String operator;
  final dynamic value;

  FilterCompareTest(this.key, {this.operator: "=", this.value}) {
    if (operator == "~") {
      _regex = new RegExp(value.toString());
    }
  }

  RegExp _regex;

  bool matches(Map m) {
    bool result = false;
    var v = m[key];

    if (value is bool && v is String) {
      v = v.toString().toLowerCase() == "true";
    }

    if (value == EXISTS) {
      result = m.containsKey(key);
    } else if (operator == "=" || operator == "==") {
      result = v == value;
    } else if (operator == "!=") {
      result = v != value;
    } else if (operator == ">") {
      result = v > value;
    } else if (operator == "<") {
      result = v < value;
    } else if (operator == "<=") {
      result = v <= value;
    } else if (operator == ">=") {
      result = v = value;
    } else if (operator == "~") {
      result = _regex.hasMatch(v.toString());
    }

    return result;
  }

  @override
  String toString() => "Compare(${key}${operator}${value})";
}

class FilterGrammarDefinition extends GrammarDefinition {
  @override
  Parser start() => ref(expressions).end();

  expressions() => (whitespace().star() & ref(expression).separatedBy(
    whitespace().plus(),
    includeSeparators: false
  ) & whitespace().star()).pick(1);

  expression() => ref(logical) |
    ref(compare);

  logical() => ref(compare) &
    (
      whitespace().star() &
      ref(logicalOp) &
      whitespace().star()
    ).pick(1) &
    ref(compare);

  logicalOp() => string("||") |
    string("or") |
    string("&&") |
    string("and");

  compare() => (
    ref(identifier) | ref(stringLiteral)
  ) & (
    (
      whitespace().star() &
      ref(op) &
      whitespace().star()
    ).pick(1) &
    ref(value)
  ).optional();

  identifier() => pattern("A-Za-z0-9\$@").plus().flatten();
  value() => ref(stringLiteral) | ref(nil) | ref(number);

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

  op() => (
    char("=") |
    string("==") |
    string("!=") |
    char("~") |
    string("<=") |
    string(">=") |
    char(">") |
    char("<")
  ).flatten();
  quote() => char('"') | char("'") | char('`');
}

class FilterGrammar extends GrammarParser {
  FilterGrammar() : super(new FilterGrammarDefinition());
}

class FilterParserDefinition extends FilterGrammarDefinition {
  @override
  compare() => super.compare().map((m) {
    String key = m[0];
    String op = "=";
    dynamic val;

    List second = m[1];
    if (second == null) {
      val = EXISTS;
    } else {
      op = second[0];
      val = second[1];
    }

    return new FilterCompareTest(key, operator: op, value: val);
  });

  @override
  logical() => super.logical().map((m) {
    var a = m[0];
    var b = m[1];
    var c = m[2];

    return new FilterLogicalTest(a, c, b);
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
}

class FilterParser extends GrammarParser {
  static final FilterParser INSTANCE = new FilterParser();

  static dynamic doParse(String input) {
    return INSTANCE.parse(input).value;
  }

  FilterParser() : super(new FilterParserDefinition());
}
