import 'account.dart';
import 'exceptions.dart';

/// Holds every account and knows how to look them up by id.
class Bank {
  final Map<String, Account> _accounts = {};
  int _lastId = 1000;

  bool get isEmpty => _accounts.isEmpty;
  Iterable<Account> get accounts => _accounts.values;

  Account open({
    required String owner,
    double openingBalance = 0,
    bool savings = false,
  }) {
    final id = _nextId();
    final account = savings
        ? SavingsAccount(id, owner, openingBalance: openingBalance)
        : Account(id, owner, openingBalance);
    _accounts[id] = account;
    return account;
  }

  Account find(String id) {
    final account = _accounts[id];
    if (account == null) {
      throw AccountNotFoundException(id);
    }
    return account;
  }

  void transfer({
    required String fromId,
    required String toId,
    required double amount,
  }) {
    if (fromId == toId) {
      throw AtmException('Cannot transfer to the same account.');
    }
    final source = find(fromId);
    final target = find(toId);

    // Take from the source first: if it fails, nothing has moved.
    source.applyTransfer(amount, outgoing: true);
    target.applyTransfer(amount, outgoing: false);
  }

  String _nextId() {
    _lastId++;
    return _lastId.toString();
    //return id string
  }
}
