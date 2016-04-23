import "dart:html";

import "package:dql/query.dart";
import "package:dql/process.dart";

import "package:dslink/browser.dart";

Uri currentUri;
String brokerUrl = const String.fromEnvironment(
  "broker.url",
  defaultValue: "http://127.0.0.1:8080/conn"
);

String currentQuery = "";

String linkName = "DQL-Browser-";
LinkProvider provider;
Requester requester;
BasicQueryContext queryContext;

main() async {
  updateLogLevel("FINE");
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

  if (currentUri.hasFragment) {
    currentQuery = Uri.decodeComponent(window.location.hash.substring(1));
  }

  provider = new LinkProvider(
    brokerUrl,
    linkName,
    isRequester: true,
    isResponder: false
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
QueryTableAssembly queryTable;

onChange(String text) async {
  currentQuery = text;

  window.location.hash = Uri.encodeComponent(text);

  if (queryTable != null) {
    queryTable.close();
    table.rows.toList().forEach((t) => t.remove());
  }

  TableSectionElement thead = table.tHead;
  TableRowElement head = thead.addRow();
  Map<String, Element> headers = {};

  queryTable = queryContext.query(text).assemble();

  queryTable.onRowAdded.listen((QueryTableAssemblyRow row) {
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

    row.onUpdate.listen((_) {
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
  });
}
