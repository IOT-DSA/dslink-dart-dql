library dsa.query.parse.filter;

import "package:petitparser/petitparser.dart";

import "package:dql/parsers/query.dart";

const Existent exists = Existent.exists;

abstract class FilterTestVisitor {
  void visit(FilterTest test) {
    if (test is FilterTestCollection) {
      visitTestCollection(test);
    } else if (test is FilterCompareTest) {
      visitCompare(test);
    } else if (test is FilterLogicalTest) {
      visitLogical(test);
    } else if (test is FilterParenthesesTest) {
      visitParentheses(test);
    }
  }

  void visitParentheses(FilterParenthesesTest test) {
    test.visit(this);
  }

  void visitTestCollection(FilterTestCollection collection) {
    collection.visit(this);
  }

  void visitCompare(FilterCompareTest test) {
    test.visit(this);
  }

  void visitLogical(FilterLogicalTest test) {
    test.visit(this);
  }
}

class FilterTestKeyCollector extends FilterTestVisitor {
  static Set<String> collect(FilterTest test) {
    var collector = new FilterTestKeyCollector();
    collector.visit(test);
    return collector.keys;
  }

  final Set<String> keys;

  factory FilterTestKeyCollector() {
    var set = new Set<String>();
    return new FilterTestKeyCollector.forSet(set);
  }

  FilterTestKeyCollector.forSet(this.keys);

  @override
  void visitCompare(FilterCompareTest test) {
    keys.add(test.key);
  }
}

class Existent {
  static const Existent exists = const Existent();

  const Existent();

  @override
  String toString() => "[EXISTS]";
}

abstract class FilterTest {
  bool matches(Map m);
  void visit(FilterTestVisitor visitor);
}

class FilterParenthesesTest extends FilterTest {
  final FilterParenthesesTest expression;

  FilterParenthesesTest(this.expression);

  @override
  bool matches(Map m) {
    return expression.matches(m);
  }

  @override
  String toString() => "Parentheses(${expression})";

  @override
  void visit(FilterTestVisitor visitor) {
    visitor.visit(expression);
  }
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
    } else if (op == "^" || op == "xor") {
      bool a = left.matches(m);
      bool b = right.matches(m);

      if (a == true && b == false) {
        return true;
      } else if (a == false && b == true) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  String toString() => "Logical(${left} ${op} ${right})";

  @override
  void visit(FilterTestVisitor visitor) {
    visitor.visit(left);
    visitor.visit(right);
  }
}

class FilterNotTest extends FilterTest {
  final FilterTest test;

  FilterNotTest(this.test);

  @override
  bool matches(Map m) {
    return !test.matches(m);
  }

  @override
  void visit(FilterTestVisitor visitor) {
    test.visit(visitor);
  }

  @override
  String toString() => "Not(${test})";
}

class FilterTestCollection extends FilterTest {
  final List<FilterTest> tests;

  FilterTestCollection(this.tests);

  @override
  bool matches(Map m) {
    for (FilterTest test in tests) {
      if (!test.matches(m)) {
        return false;
      }
    }

    return true;
  }

  @override
  String toString() {
    return "TestCollection(${tests})";
  }

  @override
  void visit(FilterTestVisitor visitor) {
    for (FilterTest test in tests) {
      visitor.visit(test);
    }
  }
}

class FilterCompareTest extends FilterTest {
  final String key;
  final String operator;
  final dynamic value;

  FilterCompareTest(this.key, {this.operator: "=", this.value}) {
    if (operator == "~" || operator == "like") {
      _regex = new RegExp(value.toString());
    }
  }

  RegExp _regex;

  @override
  bool matches(Map m) {
    bool result = false;
    var v = m[key];

    if (value == exists) {
      result = m.containsKey(key);
    } else if (operator == "=" ||
      operator == "==" ||
      operator == "equals" ||
      operator == "is") {
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
    } else if (operator == "~" || operator == "like") {
      result = _regex.hasMatch(v.toString());
    } else if (operator == "contains") {
      if (v is Iterable) {
        result = v.contains(value);
      } else if (v is String) {
        result = v.contains(value);
      } else {
        result = false;
      }
    } else if (operator == "in") {
      if (value is Iterable) {
        result = value.contains(v);
      } else if (value is String) {
        result = value.contains(v.toString());
      } else {
        result = false;
      }
    }

    return result;
  }

  @override
  String toString() => "Compare(${key} ${operator} ${value})";

  @override
  void visit(FilterTestVisitor visitor) {
  }
}

class FilterGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(expressions).end();

  expressions() => (whitespace().star() & ref(expression).separatedBy(
    whitespace().plus(),
    includeSeparators: false
  ) & whitespace().star()).pick(1);

  expression() =>
    ref(leftHandOperation) |
    ref(logical) |
    ref(compare) |
    ref(parens);

  leftHandLogical() => ref(compare) |
    ref(parens) |
    ref(leftHandOperation);

  logical() => ref(leftHandLogical) &
    (
      whitespace().star() &
      ref(logicalOp) &
      whitespace().star()
    ).pick(1) &
    ref(expression);

  logicalOp() => string("||") |
    string("or") |
    string("&&") |
    string("and") |
    char("^") |
    string("xor");

  leftHandOperation() => (
    ref(leftHandOperator) &
    whitespace().star() &
    ref(expression)
  ).permute(const [0, 2]);

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

  identifier() => pattern("A-Za-z0-9\$@_:./").plus().flatten();

  value() => ref(stringLiteral) |
    ref(nil) |
    ref(number) |
    ref(boolean) |
    ref(valueList);

  parens() => (
    char("(") &
    ref(expression) &
    char(")")
  ).pick(1);

  leftHandOperator() => (
    string("not")
  );

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
    char("<") |
    string("equals") |
    string("is") |
    string("like") |
    string("contains") |
    string("in")
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

class FilterGrammar extends GrammarParser {
  FilterGrammar() : super(new FilterGrammarDefinition());
}

class FilterParserDefinition extends FilterGrammarDefinition {
  @override
  expressions() => super.expressions().map((v) {
    return new FilterTestCollection(v);
  });

  @override
  compare() => super.compare().map((m) {
    String key = m[0];
    String op = "=";
    dynamic val;

    List second = m[1];
    if (second == null) {
      val = exists;
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

  @override
  parens() => super.parens().map((v) {
    return new FilterParenthesesTest(v);
  });

  @override
  leftHandOperation() => super.leftHandOperation().map((v) {
    if (v[0] == "not") {
      return new FilterNotTest(v[1]);
    } else {
      return v[1];
    }
  });

  @override
  valueList() => super.valueList().map((v) {
    return v;
  });
}

class FilterParser extends GrammarParser {
  static final FilterParser instance = new FilterParser();

  static FilterTestCollection doParse(String input) {
    Result result = instance.parse(input);
    if (result.isFailure) {
      result = new PowerParseError(result);
    }
    return result.value;
  }

  FilterParser() : super(new FilterParserDefinition());
}
