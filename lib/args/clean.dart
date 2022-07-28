import 'package:auto_build/args/argument.dart';

class CleanCommand extends Argument<bool> {
  @override
  String get abbr => 'c';

  @override
  bool get defaultsTo => false;

  @override
  String get help => 'execute flutter pub clean';

  @override
  String get name => 'clean';
}
