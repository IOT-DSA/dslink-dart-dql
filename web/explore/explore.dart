import "dart:async";
import "dart:html";

import "package:dql/query.dart";
import "package:dql/process.dart";

import "package:dslink/browser.dart";

Uri currentUri;
String brokerUrl = const String.fromEnvironment(
  "broker.url",
  defaultValue: "http://127.0.0.1:8080/conn"
);

String brokerToken = const String.fromEnvironment(
  "broker.token",
  defaultValue: null
);

String currentQuery = "";

String linkName = "DQL-Browser-";
LinkProvider provider;
Requester requester;
BasicQueryContext queryContext;

main() async {
  QueryStream.autoAssembleTable = true;

  currentUri = Uri.parse(window.location.href);

  if (currentUri.queryParameters.containsKey("broker")) {
    brokerUrl = currentUri.queryParameters["broker"];
  }

  if (currentUri.queryParameters.containsKey("name")) {
    brokerUrl = currentUri.queryParameters["name"];
  }

  if (currentUri.queryParameters.containsKey("query")) {
    currentQuery = currentUri.queryParameters["query"];
  }

  if (currentUri.queryParameters.containsKey("token")) {
    brokerToken = currentUri.queryParameters["token"];
  }

  if (currentUri.hasFragment) {
    currentQuery = Uri.decodeComponent(window.location.hash.substring(1));
  }

  provider = new LinkProvider(
    brokerUrl,
    linkName,
    isRequester: true,
    isResponder: false,
    token: brokerToken
  );

  await provider.init();
  await provider.connect();

  requester = await provider.onRequesterReady;

  queryContext = new BasicQueryContext(requester, baseQueryCommandSet);

  inputElement.onKeyDown.where((e) => e.keyCode == 13).listen((KeyboardEvent e) async {
    await update(inputElement.value);
  });

  window.onHashChange.listen((_) async {
    await update(Uri.decodeComponent(window.location.hash.substring(1)));
  });

  if (currentQuery != null && currentQuery.isNotEmpty) {
    await update(currentQuery, force: true);
  }

  querySelector("#peek-up").onClick.listen((_) {
    peekUp();
  });

  querySelector("#peek-down").onClick.listen((_) {
    peekDown();
  });
}

update(String text, {bool force: false}) async {
  if (currentQuery == text && !force) {
    return;
  }

  inputElement.value = text;
  await onChange(text);
}

InputElement inputElement = querySelector("#query");
TableElement table = querySelector("#table");

QueryStream currentQueryStream;
QueryTableAssembly currentQueryTable;
int currentTotalStreams = 0;
int currentStreamId = 0;

StreamSubscription subA;
StreamSubscription subB;

useQueryTable(QueryTableAssembly input) async {
  var stat = "${currentStreamId} of ${currentTotalStreams}";

  if (input.stream.processor != null) {
    stat += " (" + input.stream.processor.toString() + ")";
  } else {
    stat += " (Unprocessed)";
  }

  querySelector("#status").text = stat;

  if (currentQueryTable != null) {
    table.rows.toList().forEach((t) => t.remove());
  }

  if (subA != null) {
    subA.cancel();
    subA = null;
  }

  if (subB != null) {
    subB.cancel();
    subB = null;
  }

  currentQueryTable = input;

  TableSectionElement thead = table.tHead;
  TableRowElement head = thead.addRow();
  Map<String, Element> headers = {};

  var handleRow = (QueryTableAssemblyRow row) {
    TableRowElement tr = table.addRow();
    Map<String, TableCellElement> cells = {};

    for (String key in row.keys) {
      if (!headers.containsKey(key)) {
        Element h = new Element.th();
        headers[key] = h;
        head.append(h);
        h.text = key;
      }

      TableCellElement cell = tr.addCell();
      cell.text = row.getValue(key).toString();
      cell.dataset["col"] = key;
      cells[key] = cell;
    }

    subA = row.onUpdate.listen((_) {
      if (row.isDeleted) {
        tr.remove();
        return;
      }

      for (String k in row.keys) {
        TableCellElement cell;
        if (cells[k] == null) {
          cells[k] = tr.addCell();
        }
        cell = cells[k];

        cell.text = row.getValue(k).toString();
      }
    });
  };
  subB = currentQueryTable.onRowAdded.listen(handleRow);
  currentQueryTable.rows.values.forEach(handleRow);
}

onChange(String text) async {
  currentQuery = text;
  window.location.hash = Uri.encodeComponent(text);

  QueryStream stream = queryContext.query(text);
  currentQueryStream = stream;

  var s = stream;
  currentTotalStreams = 0;
  while (s != null) {
    currentTotalStreams++;
    s = s.parent;
  }

  currentStreamId = currentTotalStreams;

  await useQueryTable(stream.assemble());
}

peekUp() async {
  if (currentQueryTable == null) {
    return;
  }

  if (currentQueryTable.stream.parent != null) {
    currentStreamId--;
    await useQueryTable(currentQueryTable.stream.parent.assemble());
  }
}

peekDown() async {
  if (currentQueryStream == null) {
    return;
  }

  QueryStream stream = currentQueryStream;

  if (currentQueryTable.stream == stream) {
    return;
  }

  while (stream.parent != null) {
    if (stream.parent == currentQueryTable.stream) {
      break;
    }
    stream = stream.parent;
  }

  currentStreamId++;
  await useQueryTable(stream.assemble());
}
