/// Generates an id that's unique for as long as the app process runs -
/// enough for a single local device with no server to coordinate ids
/// with, which is all this app ever needs (see Player.id, DartsGame.gameId).
///
/// Plain microseconds-since-epoch alone isn't quite enough: some platforms
/// (Windows, notably) don't actually update `DateTime.now()` every
/// microsecond, so two ids requested in quick succession - e.g. creating
/// two players back-to-back - can come out identical. The counter below
/// closes that gap.
int _counter = 0;

String generateLocalId() {
  final id = '${DateTime.now().microsecondsSinceEpoch}-$_counter';
  _counter++;
  return id;
}
