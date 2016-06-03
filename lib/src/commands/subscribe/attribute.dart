part of dslink.dql.query;

class AttributeSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) =>
    key.startsWith("@") ||
      key.startsWith(r"$");

  @override
  void process(SubscribeQueryRequest request) {
    request.respond(request.context.list(request.path).map((update) {
      if (request.key.startsWith("@")) {
        return update.node.attributes[request.key];
      } else if (request.key.startsWith(r"$")) {
        return update.node.configs[request.key];
      }
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
