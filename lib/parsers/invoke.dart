library dsa.query.parse.invoke;

import "package:dslink/common.dart" show Path;

import "package:petitparser/petitparser.dart";

import "package:dql/parsers/query.dart";

class QueryInvokeColumnRef {
  final String name;

  QueryInvokeColumnRef(this.name);

  @override
  String toString() => "ColumnReference(${name})";
}

class QueryInvokeCall {
  final String action;
  final Map<String, dynamic> params;

  Map<String, String> requiredColumns = {};
  Map<String, dynamic> baseParams = {};

  QueryInvokeCall(this.action, this.params) {
    for (String key in params.keys) {
      if (params[key] is QueryInvokeColumnRef) {
        requiredColumns[key] = (params[key] as QueryInvokeColumnRef).name;
      }
    }

    for (String key in params.keys) {
      if (params[key] is! QueryInvokeColumnRef) {
        baseParams[key] = params[key];
      }
    }
  }

  String resolvePath(String base) {
    return new Path(base).child(action).path;
  }

  @override
  String toString() => "Invoke ${action} with ${params}";
}

class QueryInvokeGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(actionInvoke).end();

  actionInvoke() => ref(identifier) &
    ref(call);

  call() =>
    (
      char("(") &
      (
        ref(param).separatedBy(
          whitespace().star() &
          char(",") &
          whitespace().star(),
          includeSeparators: false
        )
      ) & char(")")
    ).pick(1);

  param() => (
    ref(identifier) &
    whitespace().star() &
    char("=") &
    whitespace().star() &
    ref(value)
  ).permute(const [0, 4]);

  identifier() => (
    pattern("A-Za-z0-9\$@_:./") |
    char('-')
  ).plus().flatten();

  value() => ref(stringLiteral) |
    ref(nil) |
    ref(number) |
    ref(boolean) |
    ref(valueList) |
    ref(variableReference);

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

  variableReference() => (char("%").optional() & ref(identifier)).pick(1);

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

class QueryInvokeGrammar extends GrammarParser {
  QueryInvokeGrammar() : super(new QueryInvokeGrammarDefinition());
}

class QueryInvokeParserDefinition extends QueryInvokeGrammarDefinition {
  @override
  start() => super.start().map((v) {
    return v;
  });

  @override
  actionInvoke() => super.actionInvoke().map((v) {
    return new QueryInvokeCall(v[0], v[1]);
  });

  @override
  call() => super.call().map((v) {
    var m = {};
    for (Map param in v) {
      m.addAll(param);
    }
    return m;
  });

  @override
  param() => super.param().map((v) {
    return {
      v[0]: v[1]
    };
  });

  @override
  variableReference() => super.variableReference().map((v) {
    return new QueryInvokeColumnRef(v);
  });
}

class QueryInvokeParser extends GrammarParser {
  static final QueryInvokeParser instance = new QueryInvokeParser();

  static QueryInvokeCall doParse(String input) {
    Result result = instance.parse(input);
    if (result.isFailure) {
      result = new PowerParseError(result);
    }
    return result.value;
  }

  QueryInvokeParser() : super(new QueryInvokeParserDefinition());
}
