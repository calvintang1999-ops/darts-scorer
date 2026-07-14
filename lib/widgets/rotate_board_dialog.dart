import 'package:flutter/material.dart';

import '../theme/typography.dart';

/// Shown every [DartCounterService.reminderInterval] darts, from whichever
/// play screen happens to be open at the time. One shared function so the
/// wording and styling only live in one place.
Future<void> showRotateBoardDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rotate your dartboard'),
      content: Text(
        "You've thrown a thousand darts since the last reminder. Boards "
        'wear unevenly - the busiest numbers take the most hits - so '
        'rotating it now spreads that wear more evenly.',
        style: AppTypography.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}
