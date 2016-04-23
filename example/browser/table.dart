import "dart:html";

import "package:dql/query.dart";
import "package:dql/process.dart";

import "package:dslink/browser.dart";

Uri currentUri;
String brokerUrl = "http://127.0.0.1:8080/conn";
String linkName = "DQL-Browser-";
LinkProvider provider;
Requester requester;
BasicQueryContext queryContext;

main() async {
  updateLogLevel("ALL");
  currentUri = Uri.parse(window.location.href);

  if (currentUri.queryParameters.containsKey("broker")) {
    brokerUrl = currentUri.queryParameters["broker"];
  }

  if (currentUri.queryParameters.containsKey("name")) {
    brokerUrl = currentUri.queryParameters["name"];
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

  print("Requester Ready!");

  queryContext = new BasicQueryContext(requester, baseQueryCommandSet);

  inputElement.onKeyDown.where((e) => e.keyCode == 13).listen((KeyboardEvent e) async {
    await onChange(inputElement.value);
  });
}

InputElement inputElement = querySelector("#query");
TableElement table = querySelector("#table");
QueryTableAssembly queryTable;

onChange(String text) async {
  print("Text Changed to '${text}'");

  if (queryTable != null) {
    queryTable.close();
    table.rows.toList().forEach((t) => t.remove());
  }

  queryTable = queryContext.query(text).assemble();

  queryTable.onRowAdded.listen((QueryTableAssemblyRow row) {
    TableRowElement tr = table.addRow();
    Map<String, TableCellElement> cells = {};

    for (String key in row.keys) {
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
