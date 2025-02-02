import 'package:dart_gsheet_remote_config/dart_gsheet_remote_config.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final remoteConfig = SheetRemoteConfig();
  await remoteConfig.initilize(
      id: '1qEskeRwdtAfnewig-slspPHKafDKV0JMexXdDWgCCeQ');
  runApp(MyApp(
    remoteConfig: remoteConfig,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.remoteConfig});

  final SheetRemoteConfig remoteConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String appName = '';
  bool forceUpdate = false;
  bool isDarkMode = false;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    appName = widget.remoteConfig.getString('appName') ?? '';
    forceUpdate = widget.remoteConfig.getBool('forceUpdate') ?? false;
    isDarkMode = widget.remoteConfig.getString('themeMode') == 'dark';
    currentVersion = widget.remoteConfig.getString('currentVersion') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: MyHomePage(
        appName: appName,
        forceUpdate: forceUpdate,
        currentVersion: currentVersion,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key,
      required this.appName,
      required this.forceUpdate,
      required this.currentVersion});

  final String appName;
  final bool forceUpdate;
  final String currentVersion;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted && widget.forceUpdate) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Update Required'),
                content: const Text('Please update the app to continue.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'App Name: ${widget.appName}',
            ),
            Text(
              'Current Version: ${widget.currentVersion}',
            ),
            Text(
              'Force Update: ${widget.forceUpdate}',
            ),
          ],
        ),
      ),
    );
  }
}
