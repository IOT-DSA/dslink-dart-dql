part of dslink.dql.query;

class ValueSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) {
    return true;
  }

  @override
  void process(SubscribeQueryRequest request) {
    String key = request.key;
    bool isTimestamp = false;
    if (key.endsWith(".timestamp")) {
      key = key.substring(0, key.length - 10);
      isTimestamp = true;
    }
    var targetPath = joinNodePath(request.path, key);

    if (key == "value") {
      targetPath = request.path;
    }

    request.respond(request.context
      .getValueUpdates(targetPath, request.qos)
      .map((ValueUpdate update) {
      return isTimestamp ? update.ts : update.value;
    }));
  }
}
