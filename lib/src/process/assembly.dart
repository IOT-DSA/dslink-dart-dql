part of dslink.dql.query.process;

class QueryTableAssembly {
  final QueryStream stream;

  StreamSubscription<QueryUpdate> _sub;
  Map<String, QueryTableAssemblyRow> _rows = {};

  Map<String, QueryTableAssemblyRow> get rows =>
    new Map<String, QueryTableAssemblyRow>.from(_rows);

  QueryTableAssembly(this.stream) {
    _init();
  }

  bool _closed = false;
  bool get isClosed => _closed;

  void _init() {
    _sub = stream.listen((QueryUpdate update) {
      if (update == null) {
        return;
      }

      String id = update.id;

      if (_rows.containsKey(id)) {
        QueryTableAssemblyRow row = _rows[id];
        if (update.remove) {
          row._removing = true;
          row._onUpdateController.add(null);
          _rows.remove(id);
          new Future(() {
            row._close();
          });
        } else {
          row._values.addAll(update.values);
          row._onUpdateController.add(null);
        }
      } else {
        QueryTableAssemblyRow row =_rows[id] = new QueryTableAssemblyRow(this);
        row._values.addAll(update.values);
        _onRowAddedController.add(row);
      }
    });
  }

  StreamController<QueryTableAssemblyRow> _onRowAddedController =
    new StreamController<QueryTableAssemblyRow>.broadcast();

  Stream<QueryTableAssemblyRow> get onRowAdded => _onRowAddedController.stream;

  void close() {
    if (_sub != null) {
      _sub.cancel();
    }

    for (String key in _rows.keys) {
      QueryTableAssemblyRow row = _rows[key];
      row._close();
    }

    _onRowAddedController.close();

    _closed = true;
  }
}

class QueryTableAssemblyRow {
  final QueryTableAssembly table;

  QueryTableAssemblyRow(this.table);

  Map<String, dynamic> _values = {};

  bool _removing = false;

  bool get isDeleted => _removing;

  StreamController _onUpdateController = new StreamController.broadcast();
  Stream get onUpdate => _onUpdateController.stream;

  Iterable<String> get keys => _values.keys;
  dynamic getValue(String key) => _values[key];

  Map<String, dynamic> get values =>
    new Map<String, dynamic>.from(_values);

  void _close() {
    _onUpdateController.close();
  }
}
