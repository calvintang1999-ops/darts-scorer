import '../../models/match_record.dart';
import '../../models/player.dart';

/// An inclusive date range, kept as our own tiny class (instead of
/// Flutter's `DateTimeRange`) so this whole stats layer stays plain Dart -
/// easy to unit test without pulling in the widget framework.
class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) =>
      !value.isBefore(start) && !value.isAfter(end);
}

/// Every stats calculator is handed an already-filtered match list built by
/// this one function, so "which matches count" is defined in exactly one
/// place. [gameName] null means "every game type"; [range] null means "all
/// time". Newest first, since that's what match history wants too.
List<MatchRecord> matchesForPlayer(
  Player player,
  List<MatchRecord> allMatches, {
  String? gameName,
  DateRange? range,
}) {
  final matches = allMatches.where((match) {
    if (!match.players.any((p) => p.id == player.id)) return false;
    if (gameName != null && match.gameName != gameName) return false;
    if (range != null && !range.contains(match.finishedAt)) return false;
    return true;
  }).toList()
    ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
  return matches;
}
