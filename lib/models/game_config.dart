/// Marker base class for per-game configuration objects (e.g. X01Config).
///
/// Every game defines its own config type extending this, and the registry's
/// `createGame` factory accepts a GameConfig, so the shell can start any game
/// without knowing its specific options.
abstract class GameConfig {
  const GameConfig();
}
