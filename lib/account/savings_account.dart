import 'account.dart';

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
