library dslink.dql.query.parse;

import "package:dslink/requester.dart";
import "package:quiver/pattern.dart";

final RegExp PATTERN_MODIFIER = new RegExp(r"(\*|\?)");
final RegExp PATTERN_PIPE = new RegExp(r"(\s?)\|(\s?)");
final RegExp PATTERN_FILTER = new RegExp(r"""
((?:\@|\$)[A-Za-z0-9]+)(?:\=((?:(?:\"|\')(.*)(?:\"|\'))|(?:true|false)|(?:[0-9\.]+)))?
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

NodeFilter parseFilterInput(String input) {
  List<Match> matches = PATTERN_FILTER.allMatches(input).toList();
  Map<String, dynamic> tests = {};
  for (Match match in matches) {
    if (match.groupCount == 1) {
      tests[match.group(1)] = _EXISTS;
    } else if (match.groupCount == 3) {
      tests[match.group(1)] = match.group(3);
    } else {
      tests[match.group(1)] = match.group(2);
    }
  }

  return (RemoteNode node) {
    if (tests.isEmpty) {
      return true;
    }

    for (String key in tests.keys) {
      if (tests[key] == _EXISTS) {
        if (!(node.configs.containsKey(key) ||
          node.attributes.containsKey(key))) {
          return false;
        }
      } else if (node.get(key) != tests[key]) {
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
    String argument;
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
