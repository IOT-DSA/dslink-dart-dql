library dslink.dql.query.parse;

import "package:quiver/pattern.dart";

import "package:dslink/requester.dart";
import "package:dslink/common.dart";

import "package:petitparser/petitparser.dart";

import "package:dql/process.dart";
import "package:dql/parsers/filter.dart";

final RegExp _patternModifier = new RegExp(r"(\*|\?)");
final RegExp _patternString = new RegExp(r"""
(?:\'|\")([^\"]*)(?:\'|\")|([^\s\,]+)
""".trim());

final RegExp _patternStringSingle = new RegExp(r"""
([\@\/\.\$A-Za-z0-9]+)=(?:\'|\")([^\"]*)(?:\'|\")
""".trim());

typedef bool NodeFilter(RemoteNode node, QueryUpdate update);

class PathExpression {
  static const List<String> directives = const <String>[
    "brokers"
  ];

  final String topmost;
  final List<String> patternParts;
  final RegExp pattern;
  final int depthLimit;
  final String directive;
  final String secondary;

  bool hasAnyMods = false;

  PathExpression(this.topmost, this.patternParts, this.pattern, this.depthLimit, {
    this.directive,
    this.secondary
  });

  bool matches(String input, {bool isBroker: false}) {
    if (directive == "brokers") {
      return isBroker;
    }

    if (!hasAnyMods && topmost == input) {
      return false;
    }

    Path p = new Path(input);

    if (p.parentPath == topmost && !hasAnyMods) {
      return true;
    }

    List<Match> matches = pattern.allMatches(input).toList();

    if (matches.isEmpty) {
      return false;
    }

    Match match = matches.first;

    if (match.group(0) != input) {
      return false;
    }

    return true;
  }

  bool checkEntrancePath(String childPath) {
    var toMatchPattern = patternParts
      .take(calculatePathPartCount(childPath) + 1)
      .join("/");
    var regex = new RegExp(toMatchPattern);
    return regex.hasMatch(childPath);
  }

  @override
  String toString() => "${pattern.pattern}";
}

class QueryStatement {
  final String command;
  final String argument;

  QueryStatement(this.command, this.argument);

  @override
  String toString() {
    String out = command;

    if (argument != null && argument.isNotEmpty) {
      out += " ${argument}";
    }

    return out;
  }
}

List<String> parseInputParameters(String input) {
  return _patternString.allMatches(input).map((Match match) {
    if (match.group(1) == null) {
      return match.group(2);
    }
    return match.group(1);
  }).toList();
}

Map<String, String> parseStringMapInput(String input) {
  var map = <String, String>{};
  for (Match match in _patternStringSingle.allMatches(input)) {
    map[match.group(1)] = match.group(2);
  }
  return map;
}

FilterTestCollection parseFilterTests(String input) {
  return FilterParser.doParse(input);
}

NodeFilter createNodeFilter(FilterTestCollection test) {
  return (RemoteNode node, QueryUpdate update) {
    if (test.tests.isEmpty) {
      return true;
    }

    Map m = {};
    m.addAll(update.attributes);
    m.addAll(node.save(includeValue: true));
    m.addAll(update.values);
    m = expandNodeDataMap(m);

    return test.matches(m);
  };
}

final RegExp _patternNotEmpty = new RegExp(".+");

PathExpression parseExpressionInput(String input) {
  input = input.trim();

  var expressionParts = input
    .split(",")
    .map((p) => p.trim())
    .where((String x) => x.isNotEmpty)
    .toList();

  String secondary;

  if (expressionParts.length > 1) {
    secondary = expressionParts.skip(1).join(",");
    input = expressionParts[0];
  }

  if (!input.startsWith("/")) {
    var lower = input.toLowerCase();

    if (PathExpression.directives.contains(lower)) {
      return new PathExpression(
        "/",
        [],
        _patternNotEmpty,
        0,
        directive: lower,
        secondary: secondary
      );
    } else {
      input = "/${input}";
    }
  }
  List<String> parts = input.split(_patternModifier);
  var count = 0;
  var questionCount = 0;
  var starCount = 0;

  var sections = input.split("/");
  var patternPartials = sections.map((section) {
    return section.splitMapJoin(_patternModifier, onMatch: (Match match) {
      String mod = match.group(1);
      String part = "";
      if (mod == "?") {
        count++;
        questionCount++;
        part = r"[^\/]+";
      } else if (mod == "*") {
        count++;
        starCount++;
        part = r".*";
      } else {
        part = match.group(0);
      }

      return part;
    }, onNonMatch: (String str) {
      return escapeRegex(str);
    });
  }).toList();

  String ptrn = patternPartials.join("/");

  String topmost = input.split("/")
    .takeWhile(
    (String part) => !_patternModifier.hasMatch(part)
  ).join("/");

  if (count == 0) {
    topmost = input;
  }

  if (topmost.endsWith("/")) {
    topmost = topmost.substring(0, topmost.length - 1);
  }

  if (topmost.isEmpty) {
    topmost = "/";
  }

  var slashesAfter = parts
    .skip(1)
    .join()
    .codeUnits
    .where((unit) => unit == 47).length;
  var recurseLimit = -1;

  if (questionCount > 0 && starCount == 0) {
    recurseLimit = slashesAfter + 1;
  }

  if (input == topmost) {
    recurseLimit = 1;
  }

  var e = new PathExpression(
    topmost,
    patternPartials,
    new RegExp(ptrn),
    recurseLimit,
    secondary: secondary
  );
  if (count != 0) {
    e.hasAnyMods = true;
  }
  return e;
}

int calculatePathPartCount(String input) {
  if (input.endsWith("/")) {
    input = input.substring(0, input.length - 1);
  }

  return input
    .split("/")
    .skip(1)
    .length;
}

RegExp parseSimpleRegEx(String input) {
  return new RegExp("^" + input.splitMapJoin("*", onMatch: (Match m) {
    return ".*";
  }, onNonMatch: (String m) {
    return escapeRegex(m);
  }) + r"$");
}

List<QueryStatement> parseQueryInput(String input) {
  return QueryStatementParser.doParse(input);
}

Map<String, dynamic> expandNodeDataMap(Map<String, dynamic> m) {
  if (m.containsKey("?value")) {
    m["value"] = m.remove("?value");
  }

  if (m.containsKey("?value_timestamp")) {
    m["value.timestamp"] = m.remove("?value_timestamp");
  }

  if (m[r"$type"] == null && m[r"$invokable"] == null) {
    m[":node"] = true;
  }

  if (m[r"$type"] is String) {
    m[":metric"] = true;
  }

  if (m["path"] is String) {
    m[":path"] = m["path"];
  }

  return m;
}

class QueryStatementGrammarDefinition extends GrammarDefinition {
  @override
  start() => ref(statements).end();

  statements() => (
    whitespace().star() &
    ref(statement).separatedBy(
      ref(separator),
      includeSeparators: false
    ) &
    whitespace().star()
  ).pick(1);

  separator() => (whitespace().star() & (
    char("|")
  ) & whitespace().star()).pick(1);

  statement() => ref(command).trim() & (
    ref(argument)
  );

  command() => pattern("A-Za-z").plus().flatten();
  argument() => (
    whitespace().star() &
    (
      string("||") |
      anyOf("|").neg()
    ).plus() &
    whitespace().star()
  ).pick(1).flatten().optional("").map((out) => out.toString().trim());
}

class QueryStatementGrammar extends GrammarParser {
  QueryStatementGrammar() : super(new QueryStatementGrammarDefinition());
}

class QueryStatementParserDefinition extends QueryStatementGrammarDefinition {
  @override
  statement() => super.statement().map((v) {
    String cmd = v[0];
    String arg = v[1].toString().trim();
    QueryStatement statement = new QueryStatement(
      cmd,
      arg
    );

    return statement;
  });
}

class QueryStatementParser extends GrammarParser {
  static final QueryStatementParser instance = new QueryStatementParser();

  static List<QueryStatement> doParse(String input) {
    Result result = instance.parse(input);
    if (result.isFailure) {
      result = new PowerParseError(result);
    }
    return result.value;
  }

  QueryStatementParser() : super(new QueryStatementParserDefinition());
}

class PowerParseError extends Failure {
  PowerParseError(Failure f) : super(f.buffer, f.position, f.message);

  @override
  String toPositionString() {
    String x = super.toPositionString();

    try {
      String nears = buffer.toString();
      int a = position - 30;
      int b = position + 30;

      if (a < 0) {
        a = 0;
      }

      if (b >= nears.length) {
        b = nears.length;
      }

      nears = nears.substring(a, b);
      int idx = position - a;

      x += "\n${nears}\n${' ' * idx}^";
    } catch (e) {
    }

    return x;
  }
}
