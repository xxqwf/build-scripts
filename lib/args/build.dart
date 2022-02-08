import 'package:auto_build/args/argument.dart';

class BuildCommand extends Argument<String> {
  @override
  String get abbr => 'b';

  @override
  String get defaultsTo => 'All';

  @override
  String get help =>
      'build app(you should specify platform and split multiple by ,)';

  @override
  String get name => 'build';
}
