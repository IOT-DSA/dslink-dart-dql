part of dslink.dql.query;

class AttributeSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) =>
    key.startsWith("@") ||
      key.startsWith(r"$") ||
      key.contains("/@");

  @override
  void process(SubscribeQueryRequest request) {
    var fullPath = joinNodePath(request.path, request.key);
    var name = pathlib.posix.basename(fullPath);
    fullPath = pathlib.posix.dirname(fullPath);

    request.respond(request.context.list(fullPath).map((update) {
      if (name.startsWith("@")) {
        return update.node.attributes[name];
      } else if (name.startsWith(r"$")) {
        return update.node.configs[name];
      }
      return null;
    }));
  }
}

class AttributeNamesSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) => const <String>[
    ":configs",
    ":attributes"
  ].contains(key);

  @override
  void process(SubscribeQueryRequest request) {
    request.respond(request.context.list(request.path).map((update) {
      if (request.key == ":attributes") {
        return update.node.attributes.keys.toList();
      } else if (request.key == ":configs") {
        return update.node.configs.keys.toList();
      } else {
        return [];
      }
    }));
  }
}
