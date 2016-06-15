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
  ].contains(key) || (
    key.endsWith("/:configs") ||
    key.endsWith("/:attributes") ||
    key.endsWith("/:children")
  );

  @override
  void process(SubscribeQueryRequest request) {
    var fullPath = joinNodePath(request.path, request.key);
    var name = pathlib.posix.basename(fullPath);
    fullPath = pathlib.posix.dirname(fullPath);

    request.respond(request.context.list(fullPath).map((update) {
      if (name == ":attributes") {
        return update.node.attributes.keys.toList();
      } else if (name == ":configs") {
        return update.node.configs.keys.toList();
      } else if (name == ":children") {
        return update.node.children.keys.toList();
      } else {
        return [];
      }
    }));
  }
}
