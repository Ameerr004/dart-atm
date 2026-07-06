enum TransactionKind { deposit, withdrawal, transfer }

class Transaction {
  final TransactionKind kind;
  final double amount;
  final DateTime time;

  Transaction(this.kind, this.amount) : time = DateTime.now();

  String get label {
    switch (kind) {
      case TransactionKind.deposit:
        return 'Deposit';
      case TransactionKind.withdrawal:
        return 'Withdrawal';
      case TransactionKind.transfer:
        return 'Transfer';
    }
  }

  @override
  String toString() {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '[$hh:$mm] $label of \$${amount.toStringAsFixed(2)}';
  }
}
