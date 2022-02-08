import 'package:auto_build/args/argument.dart';
import 'package:auto_build/auto_build.dart';

void main(List<String> arguments) async {
  parseArgs(arguments);
  if (arguments.contains('-h') || arguments.contains('--help')) {
    print('${parser.usage}');
    return;
  }
  await calculate(arguments);
  return;
}
