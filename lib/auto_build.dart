import 'dart:convert';
import 'dart:io';

import 'args/args.dart';
import 'args/argument.dart';

String defultPathSeparator = '/';
String projectDir = Directory('').absolute.path;
String pgyerUrl = 'https://www.pgyer.com/apiv2/app/upload';
String wxUrl =
    'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=2169b3b7-120c-4a49-8747-43edee152276';

const ANDROID_PLATFORM = 'Android';
const IOS_PLATFORM = 'ios';

typedef Callback<T> = void Function(T value);

Future<bool> calculate(List<String> args) async {
  if (args.isEmpty) return false;
  if (argResults['build'] != null) {
    bool dependenciseStatus = await reEstablishDependencies();
    if (!dependenciseStatus) {
      return true;
    } else {
      if (Args().build.value.contains('All')) {
        bool androidComplate = false;
        bool iosComplate = false;
        build(ANDROID_PLATFORM).then((value) {
          androidComplate = true;
          if (iosComplate && androidComplate) {
            return true;
          }
        });
        build(IOS_PLATFORM).then((value) {
          iosComplate = true;
          if (iosComplate && androidComplate) {
            return true;
          }
        });
      } else {
        if (Args().build.value.contains(ANDROID_PLATFORM)) {
          await build(ANDROID_PLATFORM).then((value) {
            return true;
          });
        }
        if (Args().build.value.contains(IOS_PLATFORM)) {
          await build(IOS_PLATFORM).then((value) {
            return true;
          });
        }
      }
    }
  }
}

Future<bool> reEstablishDependencies() async {
  logcat('开始打包');
  var clean = await start('flutter', ['clean']);
  if (clean != 0) {
    logcat(' flutter clean 失败');
    return false;
  }
  var pubGet = await start('flutter', ['pub', 'get']);
  if (pubGet != 0) {
    logcat(' flutter pub get 失败');
    return false;
  }
  return true;
}

Future<bool> build(String platform) async {
  var status =
      platform == ANDROID_PLATFORM ? await buildAndroid() : await buildIOS();
  if (status != 0) {
    logcat('$platform打包失败');
    return false;
  }
  // logcat('$platform打包完成');
  // var pubSentry = await start('flutter', ['pub', 'run', 'sentry_dart_plugin']);
  // if (pubSentry != 0) {
  //   logcat('$platform flutter pub run sentry_dart_plugin 失败');
  //   return false;
  // }
  var apkPath;
  if (platform == ANDROID_PLATFORM) {
    apkPath = '$projectDir${r'build/app/outputs/flutter-apk/app-release.apk'}';
  } else {
    apkPath = '$projectDir${r'build/ios/ipa/复骨医疗.ipa'}';
  }
  if (Platform.pathSeparator != defultPathSeparator) {
    apkPath.replaceAll(defultPathSeparator, Platform.pathSeparator);
  }
  var uploadStatus = await uploadPgyer(apkPath);
  if (uploadStatus.status != 0) {
    return false;
  }
  var toWXStatus = await uploadToWX('$platform', uploadStatus?.res);
  if (toWXStatus != 0) {
    return false;
  }
  return true;
}

Future<int> buildAndroid() async {
  var status = await start('flutter', ['build', 'apk', '--release']);
  return status;
}

Future<int> buildIOS() async {
  // var cdIos = await start('cd ios && pod install', []);
  // if (cdIos != 0) {
  //   logcat('$IOS_PLATFORM pod install 失败');
  //   return cdIos;
  // }

  var iosPath = '$projectDir${r'ios'}';
  if (Platform.pathSeparator != defultPathSeparator) {
    iosPath.replaceAll(defultPathSeparator, Platform.pathSeparator);
  }

  var podInstall = await start('pod', ['install'], workingDirectory: iosPath);
  if (podInstall != 0) {
    logcat('$IOS_PLATFORM pod install 失败');
    return podInstall;
  }
  // var cdRoot = await start('cd', ['../']);
  // if (cdRoot != 0) {
  //   logcat('$IOS_PLATFORM cd root directory 失败');
  //   return cdRoot;
  // }

  String exportOptionsPlistPath = '$projectDir${r'ExportOptions/dev.plist'}';

  var status = await start('flutter', [
    'build',
    'ipa',
    '--release',
    '--export-options-plist=$exportOptionsPlistPath',
  ]);
  return status;
}

Future<UploadPgyerEntity> uploadPgyer(String apkPath) async {
  logcat('开始上传蒲公英');
  Map<String, dynamic> _map;
  var result = await start('curl', [
    '-F',
    'file=@$apkPath',
    '-F',
    '_api_key=06bd871b10060956dfad79248e0cd44c',
    '-F',
    'userKey=5fe3ed789f19eac5f21dc9790ad0a647',
    pgyerUrl
  ], callback: (String res) {
    dynamic entity = jsonDecode(res);
    if (entity['code'] == 0) {
      _map = entity['data'];
    }
  });
  result != 0 ? logcat('上传蒲公英失败') : logcat('上传蒲公英完成');
  return UploadPgyerEntity(status: result, res: _map);
}

Future<int> uploadToWX(String platform, Map<String, dynamic> res) async {
  logcat('发送微信提示');
  var version = res['buildVersion']?.toString();
  if (version != null) {
    version = version.replaceRange(
        version.length - version.split('.').last.length,
        version.length,
        res['buildVersionNo']);
  }
  var str = {
    'msgtype': 'markdown',
    'markdown': {
      'content':
          '$platform $version 已上传至蒲公英\n[点击查看二维码](${res['buildQRCodeURL']})'
    }
  };
  var result = await start('curl', [
    wxUrl,
    '-H',
    'Content-Type: application/json',
    '-d',
    jsonEncode(str),
  ]);
  result != 0 ? logcat('微信提示失败') : logcat('微信提示成功');
  return result;
}

//执行sh脚本
Future<int> start(String executable, List<String> arguments,
    {String workingDirectory,
    Map<String, String> environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    ProcessStartMode mode = ProcessStartMode.normal,
    bool isPrint = true,
    Callback<String> callback}) async {
  var result = await Process.start(executable, arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode);
  result.stdout.listen((out) {
    var res = utf8.decode(out);
    print(res);
    callback?.call(res);
  });
  result.stderr.listen((err) {
    print(utf8.decode(err));
  });
  return result.exitCode;
}

void logcat(String content) {
  print('===================$content===================');
}

class UploadPgyerEntity {
  int status;
  Map<String, dynamic> res;

  UploadPgyerEntity({this.status, this.res});
}
