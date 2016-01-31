library dslink.dql.query.parse;

import "package:dslink/requester.dart";
import "package:quiver/pattern.dart";

import "package:dslink/dslink.dart";

import "process.dart";
import "filter.dart";

final RegExp PATTERN_MODIFIER = new RegExp(r"(\*|\?)");
final RegExp PATTERN_PIPE = new RegExp(r"""
(?:\s?)(?:\|)(?:\s?)(?=(?:[^"]*"[^"]*")*[^"]*$)
""".trim());

final RegExp PATTERN_STRING = new RegExp(r"""
(?:\'|\")([^\"]*)(?:\'|\")|([^\s\,]+)
""".trim());

final RegExp PATTERN_STRING_SINGLE = new RegExp(r"""
([\@\/\.\$A-Za-z0-9]+)=(?:\'|\")([^\"]*)(?:\'|\")
""".trim());

final Object _EXISTS = new Object();

typedef bool NodeFilter(RemoteNode node, QueryUpdate update);

class PathExpression {
  final String topmost;
  final RegExp pattern;

  bool hasAnyMods = false;

  PathExpression(this.topmost, this.pattern);

  bool matches(String input) {
    if (!hasAnyMods && topmost == input) {
      return true;
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
  return PATTERN_STRING.allMatches(input).map((Match match) {
    if (match.group(1) == null) {
      return match.group(2);
    }
    return match.group(1);
  }).toList();
}

Map<String, String> parseStringMapInput(String input) {
  var map = <String, String>{};
  for (Match match in PATTERN_STRING_SINGLE.allMatches(input)) {
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
    m = createRealMap(m);

    return test.matches(m);
  };
}

PathExpression parseExpressionInput(String input) {
  input = input.trim();

  if (!input.startsWith("/")) {
    input = "/${input}";
  }
  List<String> parts = input.split(PATTERN_MODIFIER);
  var count = 0;
  String ptrn = input.splitMapJoin(PATTERN_MODIFIER, onMatch: (Match match) {
    String mod = match.group(1);
    if (mod == "?") {
      count++;
      return r"[^\/]+";
    } else if (mod == "*") {
      count++;
      return r".*";
    }
    return match.group(0);
  }, onNonMatch: (String str) {
    return escapeRegex(str);
  });

  String topmost = parts.first;
  if (count == 0) {
    topmost = input;
  }

  if (topmost.endsWith("/")) {
    topmost = topmost.substring(0, topmost.length - 1);
  }

  if (topmost.isEmpty) {
    topmost = "/";
  }

  var e = new PathExpression(topmost, new RegExp(ptrn));
  if (count != 0) {
    e.hasAnyMods = true;
  }
  return e;
}

RegExp parseSimpleRegEx(String input) {
  return new RegExp(input.splitMapJoin("*", onMatch: (Match m) {
    return ".*";
  }, onNonMatch: (String m) {
    return escapeRegex(m);
  }));
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

  if (m[r"$type"] == null && m[r"$invokable"] == null) {
    m[":node"] = true;
  }

  if (m[r"$type"] is String) {
    m[":metric"] = true;
  }

  return m;
}
