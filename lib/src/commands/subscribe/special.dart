part of dslink.dql.query;

class SpecialKeySubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) => const <String>[
    ":name",
    ":displayName"
  ].contains(key);

  @override
  void process(SubscribeQueryRequest request) {
    var thePathName = pathlib.posix.basename(request.path);

    if (request.key == ":name") {
      request.respond(new Stream<String>.fromIterable([thePathName]));
    } else {
      request.respond(request.context.list(request.path).map((update) {
        var node = update.node;

        if (request.key == ":displayName") {
          var displayName = node.configs[r"$name"];

          if (displayName == null) {
            displayName = thePathName;
          }

          return displayName;
        } else if (request.key == ":connectionType") {
          bool isBroker = node.configs[r"$is"] == "dsa/broker";
          bool isLink = node.configs[r"$is"] == "dsa/link";
          String connectionType;

          if (isBroker || isLink) {
            connectionType = pathlib.posix.dirname(request.path);

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
