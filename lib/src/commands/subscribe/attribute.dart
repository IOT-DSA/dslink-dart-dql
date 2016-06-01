part of dslink.dql.query;

class AttributeSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) =>
    key.startsWith("@") ||
      key.startsWith(r"$");

  @override
  void process(SubscribeQueryRequest request) {
    request.respond(request.context.list(request.path).map((update) {
      if (request.target.startsWith("@")) {
        return update.node.attributes[request.target];
      } else if (request.target.startsWith(r"$")) {
        return update.node.configs[request.target];
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
      if (request.target == ":attributes") {
        return update.node.attributes.keys.toList();
      } else if (request.target == ":configs") {
        return update.node.configs.keys.toList();
      } else {
        return [];
      }
    }));
  }
}
