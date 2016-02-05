import "dart:io";

import "package:dslink_dql/parse.dart";

main() {
  test([
    'list * | subscribe alex',
    'list *|subscribe alex',
    'list *  | subscribe alex',
    'list *  |  subscribe alex',
    'list * |\nsubscribe alex',
    'list * \n|\n subscribe alex',
    'list *\t|\tsubscribe alex',
    'list * \t|\t subscribe alex'
  ], [
    ['list', '*'],
    ['subscribe', 'alex']
  ]);

  test([
    'list /downstream/System/? | subscribe value value.timestamp'
  ]);

  test([
    'list * | filter @test is true || @name is "Goodbye"'
  ], [
    ['list', '*'],
    ['filter', '@test is true || @name is "Goodbye"']
  ]);

  test([
    'list /sys/links/? | filter :node :name!="DQL" :name!="System" :name!="dataflow" | rename path="origPath" | subscribe :displayName state path'
  ], [
    ['list', '/sys/links/?'],
    ['filter', ':node :name!="DQL" :name!="System" :name!="dataflow"'],
    ['rename', 'path="origPath"'],
    ['subscribe', ':displayName state path']
  ]);
  
  test([
    'list * | subscribe path as test'
  ], [
    ['list', '*'],
    ['subscribe', 'path as test']
  ]);

  if (hasAnyError) {
    exit(1);
  }
}

test(input, [List<List<String>> checks]) {
  if (input is List) {
    for (var x in input) {
      test(x, checks);
    }
    return;
  }

  input = input.toString();

  print("================================================");
  print("Input: ${input.replaceAll('\n', '\\n').replaceAll('\t', '\\t')}");

  List<QueryStatement> statements = QueryStatementParser.doParse(input);
  if (checks == null) {
    print("Result: ${statements}");
  } else {
    int i = 0;
    for (List<String> check in checks) {
      String cmd = check[0];
      String arg = check.length == 1 ? null : check[1];
      QueryStatement s = statements[i];

      if (cmd != s.command) {
        print("Command failed: ${cmd} != ${s.command}");
        hasAnyError = true;
      }

      if (arg != s.argument) {
        print("Argument failed: ${arg} != ${s.argument}");
        hasAnyError = true;
      }

      print("Statement: ${s}");

      i++;
    }
  }
}

bool hasAnyError = false;
