import "dart:async";
import "package:dslink/dslink.dart";
import "package:quiver/pattern.dart";

final RegExp PATTERN_MODIFIER = new RegExp(r"(\*|\?)");
final RegExp PATTERN_PIPE = new RegExp(r"(\s?)\|(\s?)");
final RegExp PATTERN_FILTER = new RegExp(r"""
((?:\@|\$)[A-Za-z0-9]+)\=((?:(?:\"|\')(.*)(?:\"|\'))|(true|false)|[0-9\.]+)
""");

class SubscribeUpdate {
  final RemoteNode node;
  final ValueUpdate update;

  SubscribeUpdate(this.node, this.update);

  Map toMap() {
    return {
      "path": node.remotePath,
      "timestamp": update.ts,
      "value": update.value
    };
  }
}

class QueryException {
  final String message;

  QueryException(this.message);

  @override
  String toString() => message;
}

class ExpressionParseResult {
  String topmost;
  RegExp pattern;

  ExpressionParseResult(this.topmost, this.pattern);
}

ExpressionParseResult parseExpressionInput(String input) {
  input = input.trim();

  if (!input.startsWith("/")) {
    input = "/${input}";
  }
  List<String> parts = input.split(PATTERN_MODIFIER);
  String ptrn = input.splitMapJoin(PATTERN_MODIFIER, onMatch: (Match match) {
    if (match.group(0) != input) {
      return "";
    }

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

  return new ExpressionParseResult(topmost, new RegExp(ptrn));
}

Function parseFilterInput(String input) {
  List<Match> matches = PATTERN_FILTER.allMatches(input).toList();
  Map<String, dynamic> tests = {};
  for (Match match in matches) {
    if (match.groupCount == 3) {
      tests[match.group(1)] = match.group(3);
    } else {
      tests[match.group(1)] = match.group(2);
    }
  }

  return (RemoteNode node) {
    for (String key in tests.keys) {
      if (node.get(key) != tests[key]) {
        return false;
      }
    }
  };
}

class QueryManager {
  Requester requester;

  QueryManager(this.requester);

  Stream<RequesterListUpdate> recursiveList(String path, {bool filter(RemoteNode node)}) {
    var subs = <String, StreamSubscription>{};
    Set<String> uids = new Set<String>();
    StreamController<RequesterListUpdate> controller;
    controller = new StreamController<RequesterListUpdate>(onListen: () {
      void handle(String path) {
        Path p = new Path(path);

        String uid;
        if (subs[path] is! StreamSubscription) {
          subs[path] = requester.list(path).listen((RequesterListUpdate update) {
            if (filter != null && !filter(update.node)) {
              if (subs.containsKey(update.node.remotePath)) {
                subs.remove(update.node.remotePath).cancel();
              }
              return;
            }

            if (p.parentPath.endsWith("/upstream") && update.node.configs[r"$uid"] == null) {
              subs[path].cancel();
              subs.remove(path);
              return;
            }

            if (update.node.configs[r"$uid"] is String) {
              uid = update.node.configs[r"$uid"];
              if (uids.contains(uid)) {
                subs[path].cancel();
                subs.remove(path);
                return;
              }
              uids.add(uid);
            }
            for (RemoteNode child in update.node.children.values) {
              handle(child.remotePath);
            }
            controller.add(update);
          }, onDone: () {
            print(path);
            if (uid != null) {
              uids.remove(uid);
            }

            subs.remove(path);
          });
        }
      }

      handle(path);
    }, onCancel: () {
      for (var sub in subs.values) {
        sub.cancel();
      }
      subs.clear();
      uids.clear();
    });
    return controller.stream;
  }

  Stream<SubscribeUpdate> recursiveSubscribe(String path, {bool filter(RemoteNode node)}) {
    Map<String, StreamSubscription> subs = {};
    StreamController<SubscribeUpdate> controller;
    StreamSubscription sub;
    controller = new StreamController<SubscribeUpdate>(onListen: () {
      sub = recursiveList(path).listen((RequesterListUpdate update) {
        String rp = update.node.remotePath;
        Path p = new Path(rp);

        for (String cn in update.changes.where((x) => !x.startsWith(r"$") && !x.startsWith("@"))) {
          String cp = p.child(cn).path;
          if (!update.node.children.containsKey(cn) && subs[cp] is StreamSubscription) {
            subs[cp].cancel();
            subs.remove(cp);
          }
        }

        if (filter != null && !filter(update.node)) {
          if (subs.containsKey(rp)) {
            subs.remove(rp).cancel();
          }
          return;
        }

        if (update.node.configs[r"$type"] is String && !subs.containsKey(rp)) {
          subs[rp] = requester.subscribe(rp, (ValueUpdate val) {
            controller.add(new SubscribeUpdate(update.node, val));
          });
        }

        if (subs.containsKey(rp) && update.node.configs[r"$type"] is! String) {
          subs.remove(rp).cancel();
        }
      });
    }, onCancel: () {
      for (var sub in subs.values) {
        sub.cancel();
      }

      if (sub != null) {
        sub.cancel();
      }

      subs.clear();
    });

    return controller.stream;
  }

  Stream<SubscribeUpdate> querySubscribe(String expression, {bool filter(RemoteNode node)}) {
    ExpressionParseResult parse = parseExpressionInput(expression);
    return recursiveSubscribe(parse.topmost, filter: (RemoteNode node) {
      print(parse.pattern.pattern);
      if (!parse.pattern.hasMatch(node.remotePath)) {
        return false;
      }

      if (filter != null) {
        return filter(node);
      }

      return true;
    });
  }

  Stream<Map> query(String input) {
    List<QueryParsedPart> pipes = parseQueryInput(input);
    if (pipes.length == 2 &&
      pipes[0].command == "list" &&
      pipes[1].command == "subscribe") {
      return querySubscribe(pipes[0].argument).map((s) {
        return s.toMap();
      });
    } else if (pipes.length == 3 &&
      pipes[0].command == "list" &&
      pipes[1].command == "filter" &&
      pipes[2].command == "subscribe") {
      String filterString = pipes[1].argument;

      return querySubscribe(pipes[0].argument, filter: parseFilterInput(filterString)).map((s) {
        return s.toMap();
      });
    } else {
      throw new QueryException("Unsupported Query: ${pipes}");
    }
  }
}

class QueryParsedPart {
  final String command;
  final String argument;

  QueryParsedPart(this.command, this.argument);

  @override
  String toString() {
    String out = command;

    if (argument != null) {
      out += " ${argument}";
    }

    return out;
  }
}

List<QueryParsedPart> parseQueryInput(String input) {
  input = input.trim();
  List<String> cmds = input.split(PATTERN_PIPE);
  List<QueryParsedPart> parts = [];

  for (String part in cmds) {
    int idx = part.indexOf(" ");
    String cmd;
    String argument;
    if (idx != -1) {
      cmd = part.substring(0, idx);
      argument = part.substring(idx);
    } else {
      cmd = part;
    }

    parts.add(new QueryParsedPart(cmd, argument));
  }

  return parts;
}

class QueryNode extends SimpleNode {
  static QueryManager query;

  QueryNode(String path) : super(path) {
    configs.addAll({
      r"$name": "Query",
      r"$invokable": "read",
      r"$result": "stream",
      r"$params": [
        {
          "name": "query",
          "type": "string",
          "placeholder": "list * | subscribe"
        }
      ]
    });
  }

  @override
  onInvoke(Map params) {
    Completer<LiveTable> c = new Completer();
    String input = params["query"];
    bool isFirst = true;
    LiveTable table;
    Map<String, LiveTableRow> rows = {};
    StreamSubscription sub;
    sub = query.query(input).listen((Map map) {
      if (isFirst) {
        table = new LiveTable(map.keys.map((x) {
          return new TableColumn(x, "dynamic");
        }));

        c.complete(table);

        table.doOnClose(() {
          sub.cancel();
        });

        isFirst = false;
      }

      String path = map["path"];
      if (!rows.containsKey(path)) {
        rows[path] = table.createRow(map.values.toList());
      } else {
        List<dynamic> vals = map.values.toList();
        for (var i = 0; i < vals.length; i++) {
          rows[path].values[i] = vals[i];
        }

        table.onRowUpdate(rows[path]);
      }
    });

    return c.future;
  }
}

main(List<String> args) async {
  LinkProvider link = new LinkProvider(
    args,
    "DQL-",
    isResponder: true,
    isRequester: true
  );

  (link.provider as SimpleNodeProvider).setNode("/query", new QueryNode("/query"));

  link.connect();
  await link.onRequesterReady;
  QueryNode.query = new QueryManager(link.requester);
}

