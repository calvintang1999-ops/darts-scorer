import '../models/bot_profile.dart';
import '../models/match_record.dart';
import '../models/player.dart';
import 'bot/bot_calibration_constants.dart';

/// The persistence boundary. Game and screen code only ever talks to this
/// interface, so swapping the in-memory version for real on-device storage
/// (e.g. sqflite or shared_preferences) later means writing one new class
/// and changing one line in main.dart - no game code changes.
///
/// Methods are async (return Futures) even though the in-memory version
/// doesn't need it, because real storage will - keeping the signatures
/// identical is the whole point of the interface.
abstract class StorageService {
  Future<void> savePlayers(List<Player> players);
  Future<List<Player>> loadPlayers();

  Future<void> saveMatch(MatchRecord match);
  Future<List<MatchRecord>> loadMatchHistory();

  /// The 8 presets plus any custom bot profiles (future career mode).
  Future<List<BotProfile>> loadBotProfiles();
}

/// Phase-1 implementation: everything lives in memory and is lost when the
/// app closes. Kept around (and used by tests) alongside the real
/// DriftStorageService as a lightweight fake that needs no database.
class InMemoryStorageService implements StorageService {
  /// Seeds one default player, same as the real drift database does the
  /// first time its database file is created - so a fresh in-memory
  /// instance (e.g. in every test) starts with the same "quick start"
  /// experience as a fresh install. Deleting this player is permanent,
  /// same as on-device.
  InMemoryStorageService() {
    _players.add(Player.create('Calvin'));
    final now = DateTime.now();
    for (final preset in botCalibrationPresets) {
      _botProfiles.add(BotProfile(
        id: 'preset-${preset.name}',
        name: preset.name,
        sigmaMm: preset.sigmaMm,
        targetAverage: preset.targetAverage,
        measuredCheckoutPercent: preset.measuredCheckoutPercent,
        isPreset: true,
        createdAt: now,
      ));
    }
  }

  final List<Player> _players = [];
  final List<MatchRecord> _matches = [];
  final List<BotProfile> _botProfiles = [];

  @override
  Future<void> savePlayers(List<Player> players) async {
    _players
      ..clear()
      ..addAll(players);
  }

  @override
  Future<List<Player>> loadPlayers() async => List.of(_players);

  @override
  Future<void> saveMatch(MatchRecord match) async {
    _matches.add(match);
  }

  @override
  Future<List<MatchRecord>> loadMatchHistory() async => List.of(_matches);

  @override
  Future<List<BotProfile>> loadBotProfiles() async => List.of(_botProfiles);
}
