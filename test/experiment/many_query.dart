import "dart:async";

import "package:dslink/dslink.dart";

main(List<String> args) async {
  LinkProvider link = new LinkProvider(
    args,
    "DQLManyTest-",
    isResponder: false,
    isRequester: true
  );

  link.connect();
  Requester r = await link.onRequesterReady;

  List<StreamSubscription<RequesterInvokeUpdate>> invokes = [];

  for (var count = 1; count <= 20; count++) {
    invokes.add(r.invoke("/downstream/DQL-dev/query", {
      "query": "list /downstream/DGBox1/downstream/WeMo/? ${' ' * count} | filter @device_label | subscribe BinaryState State"
    }).listen((update) {
      print("(#${count}) " + update.updates.toString());
    }));
  }
}
