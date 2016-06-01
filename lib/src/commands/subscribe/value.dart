part of dslink.dql.query;

class ValueSubscribeProvider extends SubscribeProvider {
  @override
  bool canHandle(String key) {
    return true;
  }

  @override
  void process(SubscribeQueryRequest request) {
    String target = request.target;
    bool isTimestamp = false;
    if (target.endsWith(".timestamp")) {
      target = target.substring(0, target.length - 10);
      isTimestamp = true;
    }
    var targetPath = joinNodePath(request.path, target);

    if (target == "value") {
      targetPath = request.path;
    }

    request.respond(request.context
      .getValueUpdates(targetPath, request.qos)
      .map((ValueUpdate update) {
      return isTimestamp ? update.ts : update.value;
    }));
  }
}
