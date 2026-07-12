import 'package:flutter/material.dart';

/// Wraps a game's play screen so leaving mid-match - the Android back
/// gesture, the app bar's auto-added back arrow, or any future explicit
/// quit button (all of these go through the same Navigator pop) - asks
/// for confirmation whenever there's real progress that would be lost.
class QuitGameScope extends StatelessWidget {
  const QuitGameScope({
    super.key,
    required this.confirmBeforeLeaving,
    required this.child,
  });

  /// True while leaving would throw away real progress: some darts have
  /// been thrown and the match isn't finished yet. False skips the
  /// dialog entirely - a fresh game, or a match already won, has
  /// nothing to lose by leaving.
  final bool confirmBeforeLeaving;

  final Widget child;

  Future<bool> _confirmQuit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !confirmBeforeLeaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldQuit = await _confirmQuit(context);
        if (shouldQuit && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
