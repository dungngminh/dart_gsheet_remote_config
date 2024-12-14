import 'package:dart_gsheet_remote_config/dart_gsheet_remote_config.dart';
import 'package:version/version.dart';

Future<void> main() async {
  final remoteConfig = SheetRemoteConfig();

  await remoteConfig.initilize(
      id: "1qEskeRwdtAfnewig-slspPHKafDKV0JMexXdDWgCCeQ");

  final testValue = remoteConfig.getDouble("test");
  print("test: $testValue");

  final themeMode = remoteConfig.getString("themeMode");

  print("themeMode: $themeMode");

  final enableAds = remoteConfig.getBool("enableAds");

  print("enableAds: $enableAds");

  final inAppVersion = Version.parse("1.0.0");

  final currentVersion = remoteConfig.getString("currentVersion");

  print("currentVersion: $currentVersion");

  if (currentVersion != null && inAppVersion < Version.parse(currentVersion)) {
    print("Please update your app");
  } else {
    print("You are using the latest version");
  }
}
