import 'atm_exception.dart';

class InsufficientFundsException extends AtmException {
  InsufficientFundsException(double shortfall)
      : super('Not enough money. You are short by '
            '\$${shortfall.toStringAsFixed(2)}.');
}
