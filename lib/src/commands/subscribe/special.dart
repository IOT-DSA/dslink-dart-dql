part of dslink.dql.query;

class SpecialKeySubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) => const <String>[
    ":name",
    ":displayName"
  ].contains(key) || (
    key.endsWith("/:name") ||
    key.endsWith("/:displayName")
  );

  @override
  void process(SubscribeQueryRequest request) {
    var fullPath = joinNodePath(request.path, request.key);
    var key = pathlib.posix.basename(fullPath);
    fullPath = pathlib.posix.dirname(fullPath);
    var pathName = pathlib.posix.basename(fullPath);

    if (request.key == ":name") {
      request.respond(new Stream<String>.fromIterable([pathName]));
    } else {
      request.respond(request.context.list(fullPath).map((update) {
        var node = update.node;

        if (key == ":displayName") {
          var displayName = node.configs[r"$name"];

          if (displayName == null) {
            displayName = pathName;
          }

          return displayName;
        } else if (key == ":connectionType") {
          bool isBroker = node.configs[r"$is"] == "dsa/broker";
          bool isLink = node.configs[r"$is"] == "dsa/link";
          String connectionType;

          if (isBroker || isLink) {
            connectionType = pathlib.posix.dirname(fullPath);

            if (connectionType.isEmpty) {
              connectionType = "root";
            }
          }

          return connectionType;
        }

        return null;
      }));
    }
  }
}
