import 'atm_exception.dart';

class AccountNotFoundException extends AtmException {
  AccountNotFoundException(String id)
      : super('No account with id "$id".');
}
