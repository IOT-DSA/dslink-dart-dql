library dslink.dql.query.process;

import "dart:async";
import "dart:convert";

import "package:async/async.dart";

import "package:dslink/common.dart" show ValueUpdate;
import "package:dslink/requester.dart";
import "package:dslink/utils.dart";

import "package:dql/parsers/query.dart";

part "src/process/assembly.dart";
part "src/process/stream.dart";
part "src/process/update.dart";
part "src/process/processor.dart";
part "src/process/context.dart";
part "src/process/exception.dart";
part "src/process/process.dart";

const bool debugMode = const bool.fromEnvironment(
  "dql.mode.debug",
  defaultValue: false
);

final List<String> _possibleIdColumns = [
  "path",
  "id"
];
