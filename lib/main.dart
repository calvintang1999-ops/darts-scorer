import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/players_provider.dart';
import 'services/settings_provider.dart';
import 'services/storage_service.dart';
import 'theme/theme.dart';

void main() {
  runApp(DartsApp(storage: InMemoryStorageService()));
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
