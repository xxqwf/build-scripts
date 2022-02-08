import 'package:auto_build/args/argument.dart';

class HelpCommand extends Argument<bool> {
  @override
  String get abbr => 'h';

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'Help usage';

  @override
  String get name => 'help';
}
