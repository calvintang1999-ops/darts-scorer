import '../models/match_record.dart';
import '../models/player.dart';

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
}

/// Phase-1 implementation: everything lives in memory and is lost when the
/// app closes. Good enough while we build the games themselves.
class InMemoryStorageService implements StorageService {
  final List<Player> _players = [];
  final List<MatchRecord> _matches = [];

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
}
