import 'bot_profile.dart';
import 'unique_id.dart';

/// A persistent player profile. Players are real people with names rather
/// than anonymous "P1"/"P2", so stats in later phases can follow a person
/// across matches.
class Player {
  Player({
    required this.id,
    required this.name,
    DateTime? createdAt,
    this.botProfileId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a player with a generated id - unique enough for a single
  /// local device and avoids a uuid dependency.
  factory Player.create(String name) => Player(
        id: generateLocalId(),
        name: name,
      );

  /// A match participant backed by a bot profile rather than a human. Uses
  /// the profile's own id as the player id - simple, and unique enough
  /// since only one instance of a given preset can be in a match at once.
  factory Player.bot(BotProfile profile) => Player(
        id: profile.id,
        name: profile.name,
        botProfileId: profile.id,
      );

  final String id;
  final String name;
  final DateTime createdAt;

  /// Set when this "player" is actually a bot opponent, pointing back at
  /// the [BotProfile] it was created from. Null for every human player.
  /// This is what lets a bot take part in a match using all the same
  /// Player/Turn/Throw plumbing as a human, while still being
  /// distinguishable in match history (see MatchPlayers.botProfileId).
  final String? botProfileId;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'botProfileId': botProfileId,
      };
}
