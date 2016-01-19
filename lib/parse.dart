library dslink.dql.query.parse;

import "package:dslink/requester.dart";
import "package:quiver/pattern.dart";

final RegExp PATTERN_MODIFIER = new RegExp(r"(\*|\?)");
final RegExp PATTERN_PIPE = new RegExp(r"(\s?)\|(\s?)");
final RegExp PATTERN_FILTER = new RegExp(r"""
([\@\.\$A-Za-z0-9]+)(?:(\=|\!\=|\=\=|\<\=|\>\=|\<|\>)((?:(?:\"|\')(.*)(?:\"|\'))|(?:true|false)|(?:[0-9\.]+)))?
""".trim());

final Object _EXISTS = new Object();

typedef bool NodeFilter(RemoteNode node);

class PathExpression {
  final String topmost;
  final RegExp pattern;

  PathExpression(this.topmost, this.pattern);

  bool matches(String input) {
    List<Match> matches = pattern.allMatches(input);

    if (matches.isEmpty) {
      return false;
    }

    Match match = matches.first;

    if (match.group(0) != input) {
      return false;
    }

    return true;
  }
}

class QueryStatement {
  final String command;
  final String argument;

  QueryStatement(this.command, this.argument);

  @override
  String toString() {
    String out = command;

    if (argument != null) {
      out += " ${argument}";
    }

    return out;
  }
}

class QueryFilterTest {
  final String key;
  final String operator;
  final dynamic value;

  QueryFilterTest(this.key, {this.operator, this.value});

  bool matches(Map m) {
    bool result = false;
    var v = m[key];

    if (value == _EXISTS) {
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
    }

    return result;
  }
}

NodeFilter parseFilterInput(String input) {
  List<Match> matches = PATTERN_FILTER.allMatches(input).toList();
  List<QueryFilterTest> tests = [];
  for (Match match in matches) {
    String k = match.group(1);
    dynamic value;
    String op = "=";
    if (match.groupCount == 1) {
      value = _EXISTS;
    } else if (match.groupCount == 3) {
      value = match.group(3);
      op = match.group(2);
    } else {
      value = match.group(4);
      op = match.group(2);
    }

    if (value == null) {
      value = _EXISTS;
    }

    tests.add(new QueryFilterTest(
      k,
      value: value,
      operator: op
    ));
  }

  return (RemoteNode node) {
    if (tests.isEmpty) {
      return true;
    }

    Map m = createRealMap(node.save());

    for (QueryFilterTest test in tests) {
      if (!test.matches(m)) {
        return false;
      }
    }

    return true;
  };
}

PathExpression parseExpressionInput(String input) {
  input = input.trim();

  if (!input.startsWith("/")) {
    input = "/${input}";
  }
  List<String> parts = input.split(PATTERN_MODIFIER);
  String ptrn = input.splitMapJoin(PATTERN_MODIFIER, onMatch: (Match match) {
    String mod = match.group(1);
    if (mod == "?") {
      return r"[^\/]+";
    } else if (mod == "*") {
      return r".*";
    }
    return match.group(0);
  }, onNonMatch: (String str) {
    return escapeRegex(str);
  });

  String topmost = parts.first;
  if (topmost.endsWith("/")) {
    topmost = topmost.substring(0, topmost.length - 1);
  }

  if (topmost.isEmpty) {
    topmost = "/";
  }

  return new PathExpression(topmost, new RegExp(ptrn));
}

List<QueryStatement> parseQueryInput(String input) {
  input = input.trim();
  List<String> cmds = input.split(PATTERN_PIPE);
  List<QueryStatement> parts = [];

  for (String part in cmds) {
    int idx = part.indexOf(" ");
    String cmd;
    String argument = "";
    if (idx != -1) {
      cmd = part.substring(0, idx);
      argument = part.substring(idx + 1);
    } else {
      cmd = part;
    }

    parts.add(new QueryStatement(cmd, argument));
  }

  return parts;
}

Map createRealMap(Map m) {
  if (m.containsKey("?value")) {
    m["value"] = m.remove("?value");
  }

  if (m.containsKey("?value_timestamp")) {
    m["value.timestamp"] = m.remove("?value_timestamp");
  }

  return m;
}
