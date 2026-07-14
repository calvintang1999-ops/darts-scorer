/// Display name for a registry game id, shared by every stats/history
/// screen so the mapping lives in exactly one place.
String gameLabel(String gameName) => switch (gameName) {
      'x01' => 'X01',
      'cricket' => 'Cricket',
      'round_the_clock' => 'Round the Clock',
      'halfit' => 'Half It',
      _ => gameName,
    };

/// A plain, locale-independent yyyy-mm-dd date - good enough for match
/// history and detail screens without pulling in an intl dependency.
String formatMatchDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
