import 'unique_id.dart';

/// A persistent player profile. Players are real people with names rather
/// than anonymous "P1"/"P2", so stats in later phases can follow a person
/// across matches.
class Player {
  Player({required this.id, required this.name, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  /// Creates a player with a generated id - unique enough for a single
  /// local device and avoids a uuid dependency.
  factory Player.create(String name) => Player(
        id: generateLocalId(),
        name: name,
      );

  final String id;
  final String name;
  final DateTime createdAt;
}
