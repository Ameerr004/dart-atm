/// Everything the ATM can complain about is an [AtmException],
/// so the menu loop only needs to catch this one type.
class AtmException implements Exception {
  final String message;

  AtmException(this.message);

  @override
  String toString() => message;
}

class InvalidAmountException extends AtmException {
  InvalidAmountException()
      : super('The amount must be a positive number.');
}

class InsufficientFundsException extends AtmException {
  InsufficientFundsException(double shortfall)
      : super('Not enough money. You are short by '
            '\$${shortfall.toStringAsFixed(2)}.');
}

class AccountNotFoundException extends AtmException {
  AccountNotFoundException(String id)
      : super('No account with id "$id".');
}
