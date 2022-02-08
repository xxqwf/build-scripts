import 'package:args/args.dart';

import 'args.dart';

ArgParser parser = ArgParser();
ArgResults argResults;

void parseArgs(List<String> args) {
  Args();
  argResults = parser.parse(args);
}

abstract class Argument<T> {
  Argument() {
    if (false is T) {
      parser.addFlag(name,
          abbr: abbr, help: help, defaultsTo: defaultsTo as bool);
    } else if ('' is T) {
      parser.addOption(name,
          abbr: abbr, help: help, defaultsTo: defaultsTo as String);
    } else if (<String>[] is T) {
      parser.addMultiOption(
        name,
        abbr: abbr,
        help: help,
        defaultsTo: defaultsTo as List<String>,
      );
    } else if (HBCommand() is T) {
      parser.addCommand(name);
    } else {
      throw Exception('not implement fill method');
    }
  }

  /// The name of the option that the user passes as an argument.
  String get name;

  /// A single-character string that can be used as a shorthand for this option.
  ///
  /// For example, `abbr: "a"` will allow the user to pass `-a value` or
  /// `-avalue`.
  String get abbr;

  /// A description of this option.
  String get help;

  /// The value this option will have if the user doesn't explicitly pass it in
  T get defaultsTo;

  /// The value this option
  T get value {
    if (argResults.wasParsed(name)) {
      return argResults[name] as T;
    }
    return defaultsTo;
  }
}

class HBCommand {}
