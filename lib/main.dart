import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/announcer_service.dart';
import 'services/dart_counter_service.dart';
import 'services/drift_storage_service.dart';
import 'services/players_provider.dart';
import 'services/settings_provider.dart';
import 'services/storage_service.dart';
import 'theme/theme.dart';

void main() {
  runApp(DartsApp(storage: DriftStorageService()));
}

class DartsApp extends StatelessWidget {
  // Storage is created once in main() and injected here, so tests could
  // pass a fake. Swapping to real on-device storage later means changing
  // only that one line in main().
  const DartsApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Plain Provider (not ChangeNotifier): storage never notifies,
        // it's just a shared service.
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlayersProvider(storage)),
        // Plain Provider (not ChangeNotifier): the announcer has nothing
        // for the UI to watch, it just needs to outlive every play screen
        // so a rematch's new game can reuse the same TTS engine.
        Provider<AnnouncerService>(
          create: (ctx) => AnnouncerService(ctx.read<SettingsProvider>()),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => DartCounterService()),
      ],
      // The MaterialApp watches SettingsProvider so switching theme mode
      // in Settings restyles the app immediately.
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Darts',
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
