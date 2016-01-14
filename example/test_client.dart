import "dart:async";

import "package:dslink/dslink.dart";

main(List<String> args) async {
  LinkProvider link = new LinkProvider(
    args,
    "DQLTest-",
    isResponder: false,
    isRequester: true
  );

  link.connect();
  Requester r = await link.onRequesterReady;
  var sub = r.invoke("/downstream/DQL/query", {
    "query": r"list /downstream/* | filter $type='string' | subscribe"
  }).listen((RequesterInvokeUpdate update) {
    print(update.rows);
  });

  new Future.delayed(const Duration(seconds: 5), () {
    sub.cancel();
  });
}
