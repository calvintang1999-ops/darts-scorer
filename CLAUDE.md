# Darts Scorer

A local-only Android darts scoring app built with Flutter. There will
never be online or multiplayer-over-network features - everything is
pass-and-play on one device, by design.

## About the developer

I'm a beginner learning Flutter, Dart, git, and Claude Code at the same
time. Please:

- Prefer clear, boring code over clever code.
- Add short comments explaining any non-obvious choice.
- Explain things in plain English, not jargon.

## Roadmap (five phases)

1. **Games** (now): X01 fully working; Cricket, Split Score, Round the
   Clock next; later Shanghai, Halve-It, Bob's 27, Killer, training routines.
2. **Bot opponent**: a configurable computer opponent to play against.
3. **Voice announcer**: spoken scores ("One hundred and eighty!").
4. **Camera auto-scoring**: a camera watches the board and enters throws
   automatically.
5. **Personal statistics**: 3-dart average, checkout %, first-nine average,
   heatmaps by board position and by segment.

Phases 2-5 are NOT built yet, but the data model is already shaped for
them - don't simplify it away.

## Architecture rules

- **State management**: Provider. Games are `ChangeNotifier`s.
- **Folders**: `lib/games/` (one folder per game), `lib/models/`,
  `lib/screens/`, `lib/theme/`, `lib/widgets/`, `lib/services/`.
- **Registry pattern**: every game exposes a `GameDefinition` and is listed
  in `lib/games/registry.dart`. The home screen renders from the registry.
  Adding a game must require only one new folder + one registry line.
- **Base class**: every game extends `DartsGame`
  (`lib/models/darts_game.dart`) - players, turn history, current player,
  `applyThrow()`, `undo()`, `isFinished`, `winner`.
- **Config per game**: each game defines a config class extending
  `GameConfig` (e.g. `X01Config`), passed in when the game starts.
  Defaults must allow a zero-configuration quick start.
- **Rich Throw model** (`lib/models/throw.dart`): timestamp, player,
  actualSegment, multiplier, resultingScoreDelta, gameId, source
  (`ThrowSource` enum: manual / camera / corrected), nullable
  `landingPosition`, nullable `intendedTarget`.
- **Scoring never reads `landingPosition`.** Games score from
  `actualSegment` + `multiplier` only. Position data is enrichment for
  stats and camera work; it stays `null` for manual entry. This is what
  lets the camera phase drop in without touching any game logic.
- **`DartPosition`** (`lib/models/dart_position.dart`): normalised polar
  coordinates (radius 0-1 to the outer double wire, angle clockwise from
  top) with a `boardCoordinateSystemVersion` (currently 1). Bump the
  version if the coordinate convention ever changes so old data can't be
  silently misread. All board geometry constants live in that file only.
- **Storage behind an interface**: code depends on `StorageService`
  (`lib/services/storage_service.dart`), implemented by `DriftStorageService`
  (SQLite via drift) for the real app and `InMemoryStorageService` for tests.
- **Tokens-only styling**: every colour, size, radius, and duration comes
  from `lib/theme/tokens.dart` / `typography.dart`, consumed via
  `lib/theme/theme.dart` and the shared widgets in `lib/widgets/`.
  Screens never hardcode styles or draw raw styled containers, so a
  restyle only touches `lib/theme/` + `lib/widgets/`.
- **Usability**: the app is used standing 2-3 m from a dartboard. Big tap
  targets (`SizeTokens.playTapTarget`), huge readable scores, undo always
  visible during play, portrait and landscape both work.

## Git workflow

Commit after each meaningful change, with a descriptive message saying
what changed and why. Small, focused commits over big mixed ones.

## Useful commands

- `flutter run` - launch on a connected device/emulator (the user runs this).
- `flutter analyze` - static checks; keep it at zero issues.
- `flutter pub add <package>` - add a dependency.
