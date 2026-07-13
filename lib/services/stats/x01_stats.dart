import '../../games/x01/checkouts.dart';
import '../../games/x01/x01_config.dart';
import '../../models/match_record.dart';
import '../../models/player.dart';
import '../../models/throw.dart';

/// Everything computed for one player's X01 history. Every ratio/best-of
/// field is nullable, not NaN: null means "no qualifying data yet", and the
/// UI shows "No data yet" instead of a broken-looking number.
class X01Stats {
  const X01Stats({
    required this.matchesPlayed,
    required this.threeDartAverage,
    required this.firstNineAverage,
    required this.checkoutPercentage,
    required this.doublesHitRate,
    required this.highestCheckout,
    required this.oneHundredPlusVisits,
    required this.oneFortyPlusVisits,
    required this.oneEightyVisits,
    required this.bestLegDarts,
    required this.worstLegDarts,
    required this.visitScoreBuckets,
  });

  final int matchesPlayed;
  final double? threeDartAverage;
  final double? firstNineAverage;
  final double? checkoutPercentage;
  final double? doublesHitRate;
  final int? highestCheckout;
  final int oneHundredPlusVisits;
  final int oneFortyPlusVisits;
  final int oneEightyVisits;
  final int? bestLegDarts;
  final int? worstLegDarts;

  /// Visit-score histogram, in a fixed display order. Every bucket is
  /// present (possibly zero), so the UI can render a stable set of bars.
  final Map<String, int> visitScoreBuckets;

  static const _emptyBuckets = {
    '0-40': 0,
    '41-60': 0,
    '61-80': 0,
    '81-99': 0,
    '100-139': 0,
    '140-179': 0,
    '180': 0,
  };

  static const empty = X01Stats(
    matchesPlayed: 0,
    threeDartAverage: null,
    firstNineAverage: null,
    checkoutPercentage: null,
    doublesHitRate: null,
    highestCheckout: null,
    oneHundredPlusVisits: 0,
    oneFortyPlusVisits: 0,
    oneEightyVisits: 0,
    bestLegDarts: null,
    worstLegDarts: null,
    visitScoreBuckets: _emptyBuckets,
  );

  /// [matches] must already be filtered to this player and to X01 - see
  /// `matchesForPlayer` in stats_filter.dart. Order doesn't matter here.
  factory X01Stats.compute(Player player, List<MatchRecord> matches) {
    if (matches.isEmpty) return empty;

    var totalScore = 0;
    var totalDarts = 0;
    var firstNineTotal = 0.0;
    var firstNineLegs = 0;
    var hundredPlus = 0, fortyPlus = 0, oneEighty = 0;
    final buckets = Map<String, int>.of(_emptyBuckets);

    var checkoutRoundsTotal = 0;
    var checkoutRoundsConverted = 0;
    var checkoutMultiplierDarts = 0;
    var checkoutRoundDarts = 0;
    int? highestCheckout;
    int? bestLegDarts;
    int? worstLegDarts;

    for (final match in matches) {
      final config = _configFrom(match.config);
      final playerTurns =
          match.turnHistory.where((t) => t.player.id == player.id);

      // Visit-level stats (average, ton counts, distribution): every visit
      // counts, win or lose, finished match or not - it's raw dart data.
      //
      // Visit score is -sum(resultingScoreDelta), not raw face value: a
      // busted visit (or a dart that missed the in-rule) nets to 0 this
      // way, same as every mainstream darts scorer treats it. Using raw
      // face value instead would count a busted 180 as a real 180.
      for (final turn in playerTurns) {
        final visitScore =
            -turn.throws.fold<int>(0, (sum, d) => sum + d.resultingScoreDelta);
        totalScore += visitScore;
        totalDarts += turn.throws.length;
        if (visitScore >= 180) {
          oneEighty++;
        } else if (visitScore >= 140) {
          fortyPlus++;
        } else if (visitScore >= 100) {
          hundredPlus++;
        }
        buckets[_bucketFor(visitScore)] = buckets[_bucketFor(visitScore)]! + 1;
      }

      // First-nine average: the player's first up-to-9 darts of each leg,
      // whether or not that leg was won or the match finished.
      for (final leg in _legsOf(match)) {
        var dartsSoFar = 0;
        var pointsSoFar = 0;
        for (final turn in leg.where((t) => t.player.id == player.id)) {
          if (dartsSoFar >= 9) break;
          for (final dart in turn.throws) {
            if (dartsSoFar >= 9) break;
            pointsSoFar += -dart.resultingScoreDelta;
            dartsSoFar++;
          }
        }
        if (dartsSoFar > 0) {
          firstNineTotal += pointsSoFar / dartsSoFar * 3;
          firstNineLegs++;
        }
      }

      // Leg-outcome stats (best/worst leg, and - for double/master-out only
      // - checkout %, doubles hit rate, highest checkout) need a genuine
      // winner to make sense - abandoned matches are skipped entirely for
      // these, per our "exclude" decision.
      if (match.winnerId == null) continue;
      for (final leg in _legsOf(match)) {
        final legWinnerId = leg.last.player.id;
        final playerTurnsInLeg =
            leg.where((t) => t.player.id == player.id).toList();
        if (playerTurnsInLeg.isEmpty) continue;

        var runningScore = config.startingScore;
        var dartsThisLeg = 0;
        for (final turn in playerTurnsInLeg) {
          final scoreBeforeVisit = runningScore;
          // Single-out has no "double" concept, so it never counts as a
          // checkout round - only best/worst-leg-by-darts applies to it.
          final isCheckoutRound = config.outRule != X01OutRule.single &&
              checkoutRoutes.containsKey(scoreBeforeVisit);
          var doublesThisVisit = 0;
          for (final dart in turn.throws) {
            dartsThisLeg++;
            runningScore += dart.resultingScoreDelta;
            if (isCheckoutRound &&
                _isCheckoutMultiplier(dart.multiplier, config.outRule)) {
              doublesThisVisit++;
            }
          }
          if (isCheckoutRound) {
            checkoutRoundsTotal++;
            checkoutRoundDarts += turn.throws.length;
            checkoutMultiplierDarts += doublesThisVisit;
            final wonThisVisit =
                legWinnerId == player.id && turn == playerTurnsInLeg.last;
            if (wonThisVisit) {
              checkoutRoundsConverted++;
              highestCheckout = highestCheckout == null
                  ? scoreBeforeVisit
                  : (scoreBeforeVisit > highestCheckout
                      ? scoreBeforeVisit
                      : highestCheckout);
            }
          }
        }
        if (legWinnerId == player.id) {
          bestLegDarts = bestLegDarts == null
              ? dartsThisLeg
              : (dartsThisLeg < bestLegDarts ? dartsThisLeg : bestLegDarts);
          worstLegDarts = worstLegDarts == null
              ? dartsThisLeg
              : (dartsThisLeg > worstLegDarts ? dartsThisLeg : worstLegDarts);
        }
      }
    }

    return X01Stats(
      matchesPlayed: matches.length,
      threeDartAverage: totalDarts == 0 ? null : totalScore / totalDarts * 3,
      firstNineAverage:
          firstNineLegs == 0 ? null : firstNineTotal / firstNineLegs,
      checkoutPercentage: checkoutRoundsTotal == 0
          ? null
          : checkoutRoundsConverted / checkoutRoundsTotal * 100,
      doublesHitRate: checkoutRoundDarts == 0
          ? null
          : checkoutMultiplierDarts / checkoutRoundDarts * 100,
      highestCheckout: highestCheckout,
      oneHundredPlusVisits: hundredPlus,
      oneFortyPlusVisits: fortyPlus,
      oneEightyVisits: oneEighty,
      bestLegDarts: bestLegDarts,
      worstLegDarts: worstLegDarts,
      visitScoreBuckets: buckets,
    );
  }

  static String _bucketFor(int visitScore) {
    if (visitScore >= 180) return '180';
    if (visitScore >= 140) return '140-179';
    if (visitScore >= 100) return '100-139';
    if (visitScore >= 81) return '81-99';
    if (visitScore >= 61) return '61-80';
    if (visitScore >= 41) return '41-60';
    return '0-40';
  }

  static bool _isCheckoutMultiplier(int multiplier, X01OutRule outRule) {
    if (outRule == X01OutRule.master) return multiplier == 2 || multiplier == 3;
    return multiplier == 2; // double-out
  }

  /// [match.config] as saved by X01PlayScreen, or this game's own defaults
  /// for matches saved before schema v3 added the config snapshot.
  static X01Config _configFrom(Map<String, Object?>? config) {
    if (config == null) return const X01Config();
    return X01Config(
      startingScore: config['startingScore'] as int? ?? 501,
      outRule: X01OutRule.values.byName(config['outRule'] as String? ?? 'double'),
    );
  }

  /// Splits a match's turn history into legs (grouped by legNumber/
  /// setNumber, in play order) - every other game is single-leg, so this
  /// naturally returns one group for them too.
  static List<List<Turn>> _legsOf(MatchRecord match) {
    final legs = <List<Turn>>[];
    (int, int)? currentKey;
    for (final turn in match.turnHistory) {
      final key = (turn.legNumber, turn.setNumber);
      if (key != currentKey) {
        legs.add([]);
        currentKey = key;
      }
      legs.last.add(turn);
    }
    return legs;
  }
}
