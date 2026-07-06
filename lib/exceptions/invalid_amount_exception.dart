import 'atm_exception.dart';

class InvalidAmountException extends AtmException {
  InvalidAmountException()
      : super('The amount must be a positive number.');
}
