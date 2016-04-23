part of dslink.dql.query.process;

class QueryUpdate {
  final Map values;
  final bool remove;

  String get id {
    if (hasAttribute("id")) {
      return getAttribute("id");
    }

    for (String mik in _possibleIdColumns) {
      if (values[mik] is String) {
        return values[mik];
      }
    }

    if (_id == null) {
      _id = generateBasicId();
    }

    return _id;
  }

  String findNodePath() {
    if (attributes["node"] is RemoteNode) {
      RemoteNode node = attributes["node"];

      return node.remotePath;
    }

    if (attributes["nodePath"] is String) {
      return attributes["nodePath"];
    }

    return values["path"];
  }

  String _id;

  QueryUpdate(this.values, {this.remove: false, this.attributes}) {
    if (attributes == null) {
      attributes = {};
    }
  }

  Map<String, dynamic> attributes = {};

  dynamic getAttribute(String key) {
    return attributes[key];
  }

  bool hasAttribute(String key) {
    return attributes.containsKey(key);
  }

  void setAttribute(String key, value) {
    attributes[key] = value;
  }

  dynamic removeAttribute(String key) {
    return attributes.remove(key);
  }

  QueryUpdate clone({bool remove}) {
    if (remove == null) {
      remove = this.remove;
    }

    QueryUpdate update = new QueryUpdate(
      new Map.from(values),
      remove: remove,
      attributes: new Map.from(attributes)
    );

    if (_id != null) {
      update._id = _id;
    }

    return update;
  }

  QueryUpdate cloneAndMerge(Map<String, dynamic> m) {
    QueryUpdate c = clone();
    c.values.addAll(m);
    return c;
  }

  QueryUpdate cloneAndDrop(List<String> keys) {
    QueryUpdate c = clone();
    for (String key in keys) {
      c.values.remove(key);
    }
    return c;
  }

  QueryUpdate cloneAndStub(List<String> keys, [bool force = false]) {
    QueryUpdate c = clone();
    for (String key in keys) {
      if (!force) {
        if (!c.values.containsKey(key)) {
          c.values[key] = null;
        }
      } else {
        c.values[key] = null;
      }
    }
    return c;
  }

  Map toJSON() {
    return {
      "values": values,
      "remove": remove
    };
  }

  @override
  String toString() {
    return const JsonEncoder().convert(toJSON());
  }
}
