import 'package:flutter/foundation.dart';

import '../models/bot_profile.dart';
import 'storage_service.dart';

/// The roster of bot profiles (8 presets, plus future custom ones), kept
/// in sync with storage - same shape as PlayersProvider, but read-only for
/// now since there's no career mode yet to create custom profiles.
class BotProfilesProvider extends ChangeNotifier {
  BotProfilesProvider(this._storage) {
    _load();
  }

  /// Seeds the profiles synchronously instead of loading them - lets a
  /// test build a play screen directly (skipping the config screen, which
  /// in real use always finishes this load before a bot can even be
  /// picked) without racing the first frame's bot-turn kickoff.
  @visibleForTesting
  BotProfilesProvider.withProfiles(List<BotProfile> profiles) : _storage = null {
    _profiles.addAll(profiles);
  }

  final StorageService? _storage;
  final List<BotProfile> _profiles = [];

  List<BotProfile> get profiles => List.unmodifiable(_profiles);

  Future<void> _load() async {
    final stored = await _storage!.loadBotProfiles();
    _profiles.addAll(stored);
    notifyListeners();
  }
}
