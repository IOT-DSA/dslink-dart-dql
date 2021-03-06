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
  r.invoke("/downstream/DQL-dev/query", {
    "query": r"list /downstream/System/? | filter :metric | subscribe"
  }).listen((RequesterInvokeUpdate update) {
    print(update.rows);

    if (update.error != null) {
      print(update.error.getMessage());
    }
  });

  new Future.delayed(const Duration(seconds: 5), () {
//    sub.cancel();
  });
}
