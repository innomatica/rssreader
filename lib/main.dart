import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:just_audio_background/just_audio_background.dart'
    show JustAudioBackground;
import 'package:logging/logging.dart' show Logger, Level;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show MultiProvider;
import 'package:rssread/shared/dependencies.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import 'shared/constants.dart' show appName, appDocPath;
import 'shared/routing.dart' show router;

Future<void> main() async {
  Logger.root.level = kDebugMode ? Level.FINE : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '\u001b[1;33m${record.loggerName}.${record.level.name}: ${record.time}: ${record.message}\u001b[0m',
    );
  });
  // application document directory path
  WidgetsFlutterBinding.ensureInitialized();
  // initialize just audio background
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  appDocPath = (await getApplicationDocumentsDirectory()).path;

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
