import 'exceptions.dart';
import 'transaction.dart';

class Account {
  final String id;
  final String owner;

  double _balance;
  final List<Transaction> _history = [];

  Account(this.id, this.owner, [double openingBalance = 0])
      : _balance = openingBalance;

  double get balance => _balance;

  // Hand out a read-only view so callers can list history
  // but can't tamper with it.
  List<Transaction> get history => List.unmodifiable(_history);

  void deposit(double amount) {
    _requirePositive(amount);
    _balance += amount;
    _history.add(Transaction(TransactionKind.deposit, amount));
  }

  void withdraw(double amount) {
    _requirePositive(amount);
    if (amount > _balance) {
      throw InsufficientFundsException(amount - _balance);
    }
    _balance -= amount;
    _history.add(Transaction(TransactionKind.withdrawal, amount));
  }

  void applyTransfer(double amount, {required bool outgoing}) {
    _requirePositive(amount);
    if (outgoing && amount > _balance) {
      throw InsufficientFundsException(amount - _balance);
    }
    _balance += outgoing ? -amount : amount;
    _history.add(Transaction(TransactionKind.transfer, amount));
  }

  void _requirePositive(double amount) {
    if (amount <= 0) {
      throw InvalidAmountException();
    }
  }

  @override
  String toString() => '$id  $owner  \$${_balance.toStringAsFixed(2)}';
}

/// A savings account is an account that can earn interest.
class SavingsAccount extends Account {
  final double interestRate;

  SavingsAccount(
    String id,
    String owner, {
    this.interestRate = 0.02,
    double openingBalance = 0,
  }) : super(id, owner, openingBalance);

  void applyInterest() {
    deposit(balance * interestRate);
  }

  @override
  String toString() {
    final percent = (interestRate * 100).toStringAsFixed(1);
    return '${super.toString()}  (savings @ $percent%)';
  }
}
