import '../../models/game_config.dart';

/// How a leg must be started. "open" = any dart counts straight away.
enum X01InRule { open, double, master }

/// How a leg must be finished. "single" = any dart that lands exactly on
/// zero wins; "double" = the final dart must be a double (or inner bull);
/// "master" = the final dart must be a double or a treble.
enum X01OutRule { single, double, master }

/// All the options for an X01 match. The defaults are a standard casual
/// game (501, straight in, double out, single leg) so "quick start" needs
/// no configuration at all.
class X01Config extends GameConfig {
  const X01Config({
    this.startingScore = 501,
    this.inRule = X01InRule.open,
    this.outRule = X01OutRule.double,
    this.legsPerSet = 1,
    this.setsToWin = 1,
  });

  /// 301 / 501 / 701, or any custom value.
  final int startingScore;
  final X01InRule inRule;
  final X01OutRule outRule;

  /// First player to win this many legs takes a set.
  final int legsPerSet;

  /// First player to win this many sets wins the match.
  final int setsToWin;
}
