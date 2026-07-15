import '../../models/dart_position.dart';
import '../../services/bot/bot_aim_decision.dart';
import 'checkouts.dart';
import 'x01_strategy.dart';

/// Decides where an X01 bot should aim its next dart. This is a pure
/// function of the live game state (remaining score + darts left this
/// turn) - it holds no memory of its own, so "reacting to what actually
/// happened" is just calling [nextAim] again with the updated score after
/// every dart lands, whether that dart hit its target or not.
class X01Brain {
  const X01Brain({this.strategy = const X01Strategy()});

  final X01Strategy strategy;

  BotAimDecision nextAim({
    required int remainingScore,
    required int dartsLeftInTurn,
  }) {
    assert(remainingScore > 0, 'the leg should already be won at 0');
    assert(dartsLeftInTurn >= 1 && dartsLeftInTurn <= 3);

    if (remainingScore <= 170) {
      final route = checkoutRoutes[remainingScore];
      if (route != null && route.length <= dartsLeftInTurn) {
        final label = route.first;
        return BotAimDecision(
          aimPoint: BoardGeometry.aimPointFor(label),
          // Only the last dart of the route is the one that actually wins
          // the leg - earlier darts in a multi-dart route are still just
          // scoring towards it.
          isCheckoutAttempt: route.length == 1,
          targetLabel: label,
        );
      }

      // Not finishable this turn (a bogey number, or not enough darts left
      // to complete the route): try to leave one of the preferred setup
      // doubles instead of blindly maximising score, which risks busting
      // or leaving an unreachable 1.
      final setupLabel = _setupTarget(remainingScore);
      if (setupLabel != null) {
        return BotAimDecision(
          aimPoint: BoardGeometry.aimPointFor(setupLabel),
          isCheckoutAttempt: false,
          targetLabel: setupLabel,
        );
      }
    }

    // Scoring phase: comfortably above checkout range, or (as a fallback)
    // no safe setup shot was found this close to it either.
    final scoringLabel = _safeScoringLabel(remainingScore);
    return BotAimDecision(
      aimPoint: BoardGeometry.aimPointFor(scoringLabel),
      isCheckoutAttempt: false,
      targetLabel: scoringLabel,
    );
  }

  /// Finds a single dart that leaves one of the strategy's preferred
  /// doubles exactly, trying them in priority order. Null if none of them
  /// are reachable with just one dart from here.
  String? _setupTarget(int remainingScore) {
    for (final leave in strategy.preferredSetupLeaves) {
      final label = _labelForValue(remainingScore - leave);
      if (label != null) return label;
    }
    return null;
  }

  /// The board label for a dart worth exactly [value] points, or null if no
  /// single dart scores exactly that many (e.g. nothing scores 23).
  String? _labelForValue(int value) {
    if (value <= 0) return null;
    if (value == 50) return 'Bull';
    if (value == 25) return '25';
    if (value <= 20) return '$value';
    if (value <= 40 && value.isEven) return 'D${value ~/ 2}';
    if (value <= 60 && value % 3 == 0) return 'T${value ~/ 3}';
    return null;
  }

  /// The strategy's preferred scoring bed, unless throwing it would bust or
  /// leave an unfinishable 1 - in which case the highest-value dart that's
  /// still safe.
  String _safeScoringLabel(int remainingScore) {
    final preferred = strategy.preferredScoringBed;
    final preferredValue = preferred.number * preferred.multiplier;
    if (_isSafe(remainingScore, preferredValue)) return preferred.label;

    for (var value = 60; value >= 1; value--) {
      if (_isSafe(remainingScore, value)) {
        final label = _labelForValue(value);
        if (label != null) return label;
      }
    }
    // remainingScore <= 0 here, which can't happen (the leg would already
    // be won) - fall back to the preferred bed rather than throw.
    return preferred.label;
  }

  /// Whether aiming a dart worth [dartValue] is safe when we're *not*
  /// following a checkout-chart route (i.e. in [_safeScoringLabel]'s
  /// fallback). Landing exactly on 0 here would need to be a valid finish -
  /// but the chart above already catches every score that's a genuine
  /// 1-dart finish, so if we've reached this fallback, reducing to exactly
  /// 0 can only mean an accidental bust (a non-double dart landing on
  /// zero). Landing on 1 is always unfinishable under double-out.
  bool _isSafe(int remainingScore, int dartValue) {
    final after = remainingScore - dartValue;
    return after > 1;
  }
}
