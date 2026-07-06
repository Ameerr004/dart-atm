import 'dart:io';

import '../lib/bank.dart';
import '../lib/exceptions.dart';

void main() {
  final bank = Bank();
  seedDemoAccounts(bank);

  print('===== Dart ATM =====');
  var running = true;
  while (running) {
    printMenu();
    final choice = ask('Choose an option');
    try {
      running = handleChoice(choice, bank);
    } on AtmException catch (e) {
      // One catch for every business rule we broke.
      print('Error: $e');
    }
  }
  print('Bye.');
}

bool handleChoice(String choice, Bank bank) {
  switch (choice) {
    case '1':
      openAccount(bank);
      break;
    case '2':
      deposit(bank);
      break;
    case '3':
      withdraw(bank);
      break;
    case '4':
      transfer(bank);
      break;
    case '5':
      showAccount(bank);
      break;
    case '6':
      listAccounts(bank);
      break;
    case '0':
      return false;
    default:
      print('Unknown option: "$choice".');
  }
  return true;
}

void openAccount(Bank bank) {
  final owner = ask('Account holder name');
  if (owner.isEmpty) {
    print('Name cannot be empty.');
    return;
  }
  final savings = ask('Savings account? (y/n)').toLowerCase() == 'y';
  final opening = double.tryParse(ask('Opening balance')) ?? 0;

  final account = bank.open(
    owner: owner,
    openingBalance: opening,
    savings: savings,
  );

  print('--------------------------------------');
  print('Account created. Please keep your id.');
  print('  Name:       ${account.owner}');
  print('  Your id:    ${account.id}   <-- use this to log in');
  print('  Balance:    \$${account.balance.toStringAsFixed(2)}');
  print('--------------------------------------');
}

void deposit(Bank bank) {
  final account = bank.find(ask('Account id'));
  account.deposit(askAmount('Amount to deposit'));
  print('New balance: \$${account.balance.toStringAsFixed(2)}');
}

void withdraw(Bank bank) {
  final account = bank.find(ask('Account id'));
  account.withdraw(askAmount('Amount to withdraw'));
  print('New balance: \$${account.balance.toStringAsFixed(2)}');
}

void transfer(Bank bank) {
  final fromId = ask('From account id');
  final toId = ask('To account id');
  final amount = askAmount('Amount to transfer');

  bank.transfer(fromId: fromId, toId: toId, amount: amount);
  print('Transferred \$${amount.toStringAsFixed(2)}.');
}

void showAccount(Bank bank) {
  final account = bank.find(ask('Account id'));
  print(account);

  if (account.history.isEmpty) {
    print('No transactions yet.');
    return;
  }
  print('History:');
  for (final tx in account.history) {
    print('  $tx');
  }
}

void listAccounts(Bank bank) {
  if (bank.isEmpty) {
    print('No accounts yet.');
    return;
  }
  for (final account in bank.accounts) {
    print(account);
  }
}

void printMenu() {
  print('''
1) Open account
2) Deposit
3) Withdraw
4) Transfer
5) Show account
6) List accounts
0) Exit''');
}

/// Reads a line and trims it. [stdin.readLineSync] can return null
/// (for example at end of input), so we fall back to an empty string.
String ask(String message) {
  stdout.write('$message: ');
  return stdin.readLineSync()?.trim() ?? '';
}

/// Same as [ask], but insists the answer is a real number.
double askAmount(String message) {
  final value = double.tryParse(ask(message));
  if (value == null) {
    throw InvalidAmountException();
  }
  return value;
}

void seedDemoAccounts(Bank bank) {
  bank.open(owner: 'Ameer', openingBalance: 500);
  bank.open(owner: 'Sara', openingBalance: 1200, savings: true);
}
