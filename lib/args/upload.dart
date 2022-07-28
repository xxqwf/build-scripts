import 'package:auto_build/args/argument.dart';

class UploadCommand extends Argument<String> {
  @override
  String get abbr => 'u';

  @override
  String get defaultsTo => 'All';

  @override
  String get help => 'upload app package to pgyer';

  @override
  String get name => 'upload';
}
