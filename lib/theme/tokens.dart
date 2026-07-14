import 'package:flutter/material.dart';

/// ALL design tokens live in this file. Screens and widgets never hardcode
/// a colour, size, radius, or duration - they reference these names (or the
/// ThemeData built from them). Restyling the app should only ever touch
/// lib/theme/ and lib/widgets/.

abstract final class ColorTokens {
  /// Material 3 generates the whole light + dark palette from this one
  /// seed colour (see theme.dart). Dartboard green for now - placeholder
  /// until visual references arrive.
  static const Color seed = Color(0xFF1E7A46);

  /// Accent used for "danger"-ish highlights (bust, delete). Kept as a
  /// token rather than using raw red in widgets.
  static const Color danger = Color(0xFFC62828);
}

abstract final class SpacingTokens {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class RadiusTokens {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

abstract final class ElevationTokens {
  static const double card = 1;
  static const double raised = 3;
}

abstract final class DurationTokens {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
}

abstract final class SizeTokens {
  /// Minimum tap-target side for anything pressed during play. The app is
  /// used standing at the oche, often at arm's length, so this is much
  /// bigger than Material's usual 48.
  static const double playTapTarget = 64;

  /// Height of the big primary action buttons (Start, Undo).
  static const double buttonHeight = 56;

  /// Width of one player panel on the play screen's scrolling strip.
  static const double playerCardWidth = 180;

  /// Height of a chart's plotting area on the stats screens.
  static const double chartHeight = 160;

  /// Width of one StatTile in the stats screens' wrapping grid.
  static const double statTileWidth = 150;
}
