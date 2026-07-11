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
    final stored = await _storage.loadPlayers();
    _players.addAll(stored);
    // Seed one default player so "quick start" needs zero setup on a
    // fresh install - open X01, hit Start, play.
    if (_players.isEmpty) {
      _players.add(Player.create('Player 1'));
      await _storage.savePlayers(_players);
    }
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
