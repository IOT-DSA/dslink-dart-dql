part of dql.test.query.integration;

class MockNode {
  static const String ROOT = "/";
  static const String CONFIG_BEGIN = r"$";
  static const String ATTRIBUTE_BEGIN = "@";
  static const String VALUE_KEY = "?value";

  final String name;

  factory MockNode.rootNode() {
    return new MockNode(null, "");
  }

  MockNode(this.parent, this.name);

  MockNode parent;
  Map<String, MockNode> children = {};

  Map<String, dynamic> configs = {};
  Map<String, dynamic> attributes = {};

  String get path {
    if (parent == null) {
      return ROOT;
    }

    var parts = <String>[];
    var current = this;

    while (current != null) {
      parts.add(current.name);

      current = current.parent;
    }

    return parts.reversed.join("/");
  }

  MockNode findNode(String path) {
    var parts = path.split("/");

    var node = this;
    for (String part in parts) {
      if (part.isEmpty) {
        continue;
      }

      if (node == null) {
        return null;
      }

      node = node.children[part];
    }

    return node;
  }

  MockNode get root {
    if (parent == null) {
      return this;
    }

    var current = this;

    while (current.parent != null) {
      current = current.parent;
    }

    return current;
  }

  StreamController<String> listController =
    new StreamController<String>.broadcast();

  StreamController<ValueUpdate> values =
    new StreamController<ValueUpdate>.broadcast();

  ValueUpdate lastValueUpdate = new ValueUpdate(null);

  void updateValue(value) {
    ValueUpdate update;

    if (value is ValueUpdate) {
      update = value;
    } else {
      update = new ValueUpdate(value);
    }

    lastValueUpdate = update;
    values.add(update);
  }

  RemoteNode asRemoteNode() {
    var node = new RemoteNode(path);

    for (String key in children.keys) {
      node.children[key] = children[key].asRemoteNode();
    }

    node.configs = configs;
    node.attributes = attributes;

    return node;
  }

  void load(Map<String, dynamic> input) {
    for (String key in input.keys) {
      var value = input[key];
      if (key[0] == CONFIG_BEGIN) {
        configs[key] = value;
      } else if (key[0] == ATTRIBUTE_BEGIN) {
        attributes[key] = value;
      } else if (key == VALUE_KEY) {
        lastValueUpdate = new ValueUpdate(value);
      } else if (value is Map) {
        var child = children[key] = new MockNode(this, key);
        child.load(value);
      }
    }
  }
}
