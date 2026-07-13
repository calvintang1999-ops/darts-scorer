import 'package:flutter/foundation.dart';

import '../models/player.dart';
import 'storage_service.dart';

/// The roster of known players, kept in sync with storage.
class PlayersProvider extends ChangeNotifier {
  PlayersProvider(this._storage) {
    _load();
  }

  final StorageService _storage;
  final List<Player> _players = [];

  List<Player> get players => List.unmodifiable(_players);

  Future<void> _load() async {
    // No seeding here - the storage implementation seeds a default player
    // once, the first time it's ever created, so the roster can genuinely
    // become empty (e.g. that player gets deleted) without one reappearing.
    final stored = await _storage.loadPlayers();
    _players.addAll(stored);
    notifyListeners();
  }

  Future<void> addPlayer(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _players.add(Player.create(trimmed));
    await _storage.savePlayers(_players);
    notifyListeners();
  }

  Future<void> removePlayer(Player player) async {
    _players.removeWhere((p) => p.id == player.id);
    await _storage.savePlayers(_players);
    notifyListeners();
  }
}
