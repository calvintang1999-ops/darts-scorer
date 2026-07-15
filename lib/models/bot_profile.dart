/// A saved bot "character" a human can play against: how accurate its arm
/// is, plus informational stats used to describe it on a picker screen.
///
/// The 8 presets ("Rookie Ray" .. "The Governor") are seeded into the
/// database on first run (see AppDatabase) and can't be deleted. Custom
/// profiles (future career mode - not built yet) are ordinary rows with
/// [isPreset] false; nothing here assumes presets are the only bots.
class BotProfile {
  BotProfile({
    required this.id,
    required this.name,
    required this.sigmaMm,
    required this.targetAverage,
    required this.measuredCheckoutPercent,
    required this.isPreset,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;

  /// Standard deviation of the bot's throw, in mm - see GaussianArm. This
  /// is the one value that actually drives play; the rest are informational.
  final double sigmaMm;

  /// The 3-dart average this sigma was calibrated to produce. Informational
  /// - shown on a picker screen, never read by the arm or brain.
  final double targetAverage;

  /// Checkout percentage measured during calibration (successful finishes
  /// / darts thrown at a double to win). Informational only.
  final double measuredCheckoutPercent;

  final bool isPreset;
  final DateTime createdAt;
}
