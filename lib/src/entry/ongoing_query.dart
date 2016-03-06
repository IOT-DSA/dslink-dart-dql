part of dslink.dql.entry;

class OngoingQuery {
  final String input;
  final QueryManager manager;
  final Stream<QueryUpdate> stream;

  StreamSubscription sub;
  List<InvokeResponse> _responses = [];
  List<String> knownColumns = [];
  Map<String, QueryTableRow> rows = {};

  OngoingQuery(this.input, this.manager, this.stream) {
    init();
  }

  void forEachResponse(handler(InvokeResponse response)) {
    _responses.forEach(handler);
  }

  void init() {
    sub = stream.listen((QueryUpdate update) {
      var forceRefresh = false;
      if (!update.remove) {
        List<String> keys = update.values.keys.toList();
        var added = keys.where((x) => !knownColumns.contains(x)).toList();

        for (String key in added) {
          knownColumns.add(key);
        }

        if (added.isNotEmpty) {
          forEachResponse((response) {
            response.updateStream(
              [],
              columns: knownColumns
                .map((name) => new TableColumn(name, "dynamic"))
                .toList()
            );
          });
        }
      }

      String path = update.id;

      if (!rows.containsKey(path)) {
        if (!update.remove) {
          var row = rows[path] = new QueryTableRow(update.values);
          row.id = rows.length - 1;

          forEachResponse((response) {
            response.updateStream(
              [row.format(knownColumns)],
              meta: {
                "mode": "append"
              }
            );
          });
        }
      } else {
        if (update.remove) {
          QueryTableRow row = rows.remove(path);
          for (QueryTableRow m in rows.values) {
            if (m.id > row.id) {
              m.id--;
            }
          }

          forEachResponse((response) {
            response.updateStream(
              rows.values.where((r) {
                return r.id >= row.id;
              }).map((row) => row.format(knownColumns)).toList(),
              meta: {
                "modify": "replace ${row.id}-${rows.length}"
              }
            );
          });
        } else {
          QueryTableRow row = rows[path];
          row.values.addAll(update.values);
          forEachResponse((response) {
            response.updateStream(
              [row.format(knownColumns)],
              meta: {
                "modify": "replace ${row.id}-${row.id}"
              }
            );
          });
        }
      }

      if (forceRefresh) {
        forEachResponse((response) {
          sendToResponse(response);
        });
      }
    }, onError: (e, stack) {
      var err = new DSError(
        "invokeError",
        msg: e.toString(),
        detail: stack.toString()
      );

      forEachResponse((response) {
        response.close(err);
      });

      destroy();
    }, cancelOnError: true);
  }

  void sendToResponse(InvokeResponse response) {
    response.updateStream(
      rows.values
        .map((row) => row.format(knownColumns))
        .toList(),
      columns: knownColumns
        .map((name) => new TableColumn(name, "dynamic"))
        .toList(),
      meta: {
        "mode": "refresh"
      },
      streamStatus: StreamStatus.open
    );
  }

  void addResponse(InvokeResponse response) {
    if (!_responses.contains(response)) {
      logger.fine("Adding invoke with rid ${response.rid} to ongoing query.");
      sendToResponse(response);
      _responses.add(response);
      response.onClose = (_) {
        dropResponse(response);
      };
    } else {
      logger.warning(
        "Invoke with rid ${response.rid} is already part of this ongoing query."
      );
    }
  }

  void dropResponse(InvokeResponse response) {
    logger.fine(
      "Dropping invoke with rid ${response.rid} from ongoing query."
    );
    _responses.remove(response);

    response.close();

    if (_responses.isEmpty) {
      if (sub != null) {
        sub.cancel();
      }

      manager.destroyQuery(input, true);
    }
  }

  void destroy() {
    _responses.toList().forEach(dropResponse);
  }

  List<InvokeResponse> get responses =>
    new List<InvokeResponse>.unmodifiable(_responses);

  int get listenCount => _responses.length;
}
