import 'package:darts/models/bot_profile.dart';
import 'package:darts/models/dart_position.dart';
import 'package:darts/models/match_record.dart';
import 'package:darts/models/player.dart';
import 'package:darts/models/throw.dart';
import 'package:darts/services/stats/stats_filter.dart';
import 'package:darts/services/stats/x01_stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression coverage for playing against a bot: a human's personal
/// stats (and, by the same mechanism, a future heatmap) must reflect only
/// their own darts - never the bot's - even though both are ordinary
/// match participants sharing the same turnHistory. The isolation comes
/// entirely from filtering by player.id (see stats_filter.dart and every
/// stats calculator), so this test's job is to prove that still holds
/// once one of the two ids belongs to a bot rather than a human.
void main() {
  test('a human\'s X01 stats never include their bot opponent\'s darts', () {
    final human = Player.create('Alice');
    final bot = Player.bot(BotProfile(
      id: 'bot-1',
      name: 'The Governor',
      sigmaMm: 5.85,
      targetAverage: 105,
      measuredCheckoutPercent: 50.33,
      isPreset: true,
    ));

    // The bot's darts carry a landingPosition (GaussianArm always sets
    // one) - deliberately different data shape from the human's manual
    // entry, to make sure isolation isn't accidentally relying on both
    // sides looking alike.
    final botThrow = Throw(
      player: bot,
      actualSegment: 20,
      multiplier: 3,
      gameId: 'm1',
      source: ThrowSource.bot,
      resultingScoreDelta: -60,
      intendedTarget: 20,
      landingPosition:
          const DartPosition(radiusNormalised: 0.62, angleDegrees: 3),
    );
    final humanThrow = Throw(
      player: human,
      actualSegment: 19,
      multiplier: 1,
      gameId: 'm1',
      resultingScoreDelta: -19,
    );

    final match = MatchRecord(
      gameId: 'm1',
      gameName: 'x01',
      players: [bot, human],
      winnerId: bot.id,
      config: const {'startingScore': 501, 'outRule': 'double'},
      turnHistory: [
        Turn(player: bot, throws: [botThrow, botThrow, botThrow]),
        Turn(player: human, throws: [humanThrow]),
      ],
    );

    // Sanity: both are genuinely recognised as participants.
    expect(matchesForPlayer(human, [match]), [match]);
    expect(matchesForPlayer(bot, [match]), [match]);

    final humanStats = X01Stats.compute(human, [match]);
    // Only the human's one dart (19, a single) should count: average is
    // 19 / 1 * 3 = 57, not something inflated by the bot's three T20s.
    expect(humanStats.threeDartAverage, closeTo(57, 1e-9));
    expect(humanStats.oneEightyVisits, 0);

    // And the reverse: the bot's own stats (if ever computed - e.g. a
    // future "bot performance" view) are like`wise untouched by the
    // human's dart.
    final botStats = X01Stats.compute(bot, [match]);
    expect(botStats.threeDartAverage, closeTo(180, 1e-9));
    expect(botStats.oneEightyVisits, 1);

    // The human participant is never marked as a bot, and vice versa.
    final humanParticipant = match.players.firstWhere((p) => p.id == human.id);
    final botParticipant = match.players.firstWhere((p) => p.id == bot.id);
    expect(humanParticipant.botProfileId, isNull);
    expect(botParticipant.botProfileId, bot.id);
  });
}
