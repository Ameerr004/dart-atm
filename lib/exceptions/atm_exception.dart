/// Everything the ATM can complain about is an [AtmException],
/// so the menu loop only needs to catch this one type.
class AtmException implements Exception {
  final String message;

  AtmException(this.message);

  @override
  String toString() => message;
}
