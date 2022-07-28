import 'build.dart';
import 'clean.dart';
import 'help.dart';
import 'upload.dart';

class Args {
  factory Args() => _args ??= Args._();

  Args._()
      : help = HelpCommand(),
        build = BuildCommand(),
        upload = UploadCommand(),
        clean = CleanCommand();

  static Args? _args;
  final HelpCommand help;
  final BuildCommand build;
  final UploadCommand upload;
  final CleanCommand clean;
}
