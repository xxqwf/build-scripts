import 'build.dart';
import 'help.dart';

class Args {
  factory Args() => _args ??= Args._();

  Args._()
      : help = HelpCommand(),
        build = BuildCommand();
  static Args? _args;
  final HelpCommand help;
  final BuildCommand build;
}
