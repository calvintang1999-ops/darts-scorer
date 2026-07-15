/// Calibrated sigma / checkout% for each preset bot, produced by
/// tool/calibrate_bot.dart and consumed only when the database seeds the
/// BotProfiles table for the first time (see AppDatabase).
///
/// Generated 2026-07-15 by `flutter test tool/calibrate_bot.dart`
/// (dart:ui means it has to run under the Flutter test harness, not plain
/// `dart run` - see that script's doc comment). Simulation parameters:
/// X01 501, double-out, straight-in, X01Brain with the default strategy,
/// GaussianArm; 5,000 solo legs per binary-search evaluation (up to 20
/// evaluations per preset, sigma search bounds 3-130mm) until the
/// simulated 3-dart average was within 0.5 of the target. The average is
/// computed the same way lib/services/stats/x01_stats.dart does (net
/// per-visit score, so a busted visit counts as 0 - not raw dart face
/// value), so a calibrated bot reads as its labelled average in the app's
/// own stats screen.
library;

class BotCalibrationPreset {
  const BotCalibrationPreset({
    required this.name,
    required this.targetAverage,
    required this.sigmaMm,
    required this.measuredCheckoutPercent,
  });

  final String name;
  final double targetAverage;
  final double sigmaMm;
  final double measuredCheckoutPercent;
}

const List<BotCalibrationPreset> botCalibrationPresets = [
  BotCalibrationPreset(
      name: 'Rookie Ray', targetAverage: 35, sigmaMm: 23.84, measuredCheckoutPercent: 9.67),
  BotCalibrationPreset(
      name: 'Steady Steve', targetAverage: 45, sigmaMm: 18.38, measuredCheckoutPercent: 14.10),
  BotCalibrationPreset(
      name: 'Lucky Lou', targetAverage: 55, sigmaMm: 14.78, measuredCheckoutPercent: 19.33),
  BotCalibrationPreset(
      name: 'Sharp Sam', targetAverage: 65, sigmaMm: 12.18, measuredCheckoutPercent: 24.74),
  BotCalibrationPreset(
      name: 'Bullseye Bex', targetAverage: 75, sigmaMm: 10.19, measuredCheckoutPercent: 30.31),
  BotCalibrationPreset(
      name: 'Cool Hand Cody', targetAverage: 85, sigmaMm: 8.58, measuredCheckoutPercent: 35.74),
  BotCalibrationPreset(
      name: 'The Professor', targetAverage: 95, sigmaMm: 7.09, measuredCheckoutPercent: 42.39),
  BotCalibrationPreset(
      name: 'The Governor',
      targetAverage: 105,
      sigmaMm: 5.85,
      measuredCheckoutPercent: 50.33),
];
