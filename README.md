# Dart ATM

A small console banking app, built while learning Dart from
[darttutorial.org](https://www.darttutorial.org). It runs in the terminal
(no GUI) and lets you open accounts, deposit, withdraw, transfer money,
and view each account's history.

The goal of the project is **learning**: it deliberately touches most of
the core Dart topics — classes, inheritance, enums, collections, null
safety, and exceptions — while staying small enough to read in one sitting.

---

## The idea

The app models a tiny bank:

- The **bank** holds many **accounts**.
- Each **account** has an owner, a balance, and a list of **transactions**.
- The user interacts through a **text menu** in a loop until they exit.

Every account gets a unique **id** (like a real account number). The owner's
name is just a label — the id is what identifies the account and is used to
deposit, withdraw, or transfer.

---

## How to run

```bash
dart run bin/atm.dart # start the app
```

You'll see a menu. Pick a number:

```
1) Open account
2) Deposit
3) Withdraw
4) Transfer
5) Show account
6) List accounts
0) Exit
```

Two demo accounts (`1001` Ameer, `1002` Sara) are created at startup so you
have something to play with immediately.

---

## Project structure

Each file has **one responsibility** — that is itself a clean-code rule.

| File | Responsibility |
|------|----------------|
| [`bin/atm.dart`](bin/atm.dart) | The menu loop and all user input/output |
| [`lib/bank.dart`](lib/bank.dart) | Stores accounts and looks them up by id |
| [`lib/account.dart`](lib/account.dart) | Account rules: deposit / withdraw + inheritance |
| [`lib/transaction.dart`](lib/transaction.dart) | One history record + the `enum` |
| [`lib/exceptions.dart`](lib/exceptions.dart) | Custom error types |

The three layers talk to each other like this:

```
menu (atm.dart)  ->  bank.find("1002")   ->  returns the Account
      |                                              
      +-------->  account.deposit(50)  ->  the Account changes its OWN balance
```

- The **menu** decides *when* something happens (the user pressed a key).
- The **bank** answers *"which account?"* (storage + lookup).
- The **account** does the actual money math on itself.

---

## Core Dart concepts used

### `Map` (a hashmap)

```dart
final Map<String, Account> _accounts = {};
```

A `Map` stores **key → value** pairs and finds values by key almost
instantly (O(1)). Here the **key** is the account id (`"1001"`) and the
**value** is the whole `Account` object. This is why looking up an account
by id is fast and simple:

```dart
_accounts["1001"];       // -> the Account, or null if missing
_accounts[id] = account; // store an account under its id
_accounts.values;        // all the accounts
```

Keys are unique, which is exactly why account ids make good keys.

### `List`

```dart
final List<Transaction> _history = [];
```

An ordered, indexable collection. Each account keeps its transactions in a
`List` and adds to it with `_history.add(...)`.

### `enum`

```dart
enum TransactionKind { deposit, withdrawal, transfer }
```

A fixed set of named options. It makes a transaction's type readable and
type-safe instead of using loose strings like `"deposit"`.

### Null safety

`stdin.readLineSync()` can return `null`, and `double.tryParse` returns
`null` when the text isn't a number. The code handles both explicitly:

```dart
return stdin.readLineSync()?.trim() ?? '';   // ?. and ?? guard the null
final value = double.tryParse(ask(message));  // value is double?
if (value == null) { throw InvalidAmountException(); }
```

- `?.` — call only if not null.
- `??` — fall back to a default if null.
- `tryParse` — the safe parse that returns null instead of crashing.

### Exceptions

Anything that breaks a banking rule `throw`s an exception, and the menu
loop catches it so the app never crashes:

```dart
throw InsufficientFundsException(amount - _balance);
```

```dart
try {
  running = handleChoice(choice, bank);
} on AtmException catch (e) {
  print('Error: $e');   // one catch for every rule we broke
}
```

---

## Classes and their methods

### `Bank` — storage + lookup

| Member | What it does |
|--------|--------------|
| `_accounts` (`Map`) | Holds every account, keyed by id |
| `_lastId` (`int`) | Counter that remembers the last id handed out |
| `open(...)` | Creates a new account, gives it an id, stores it |
| `find(id)` | Returns the account for an id, or throws if missing |
| `transfer(...)` | Moves money between two accounts safely |
| `_nextId()` | Bumps `_lastId` and returns the new id as a `String` |

The id is minted in exactly one place — `open()`:

```dart
final id = _nextId();                 // 1. counter picks the next id
final account = Account(id, owner...);// 2. id stamped onto the account
_accounts[id] = account;              // 3. stored in the map under that id
```

### `Account` — its own money logic

| Member | What it does |
|--------|--------------|
| `id`, `owner` | Identity (set once, `final`) |
| `_balance` | The money, private; exposed through the `balance` getter |
| `deposit(amount)` | Adds money, records a transaction |
| `withdraw(amount)` | Removes money, throws if not enough |
| `applyTransfer(amount, outgoing:)` | The move used by `Bank.transfer` |
| `_requirePositive(amount)` | Private guard: amount must be > 0 |

### `Transaction` — one history line

Stores the `kind` (enum), the `amount`, and the `time`. Its `toString()`
formats a line like `[11:53] Deposit of $250.00`.

### Exceptions

`AtmException` is the base type; the specific ones extend it:
`InvalidAmountException`, `InsufficientFundsException`,
`AccountNotFoundException`.

---

## Inheritance in the code

Two places use inheritance (`extends`):

**1. Accounts.** `SavingsAccount` is an `Account` that can earn interest:

```dart
class SavingsAccount extends Account {
  final double interestRate;

  SavingsAccount(String id, String owner, {this.interestRate = 0.02, ...})
      : super(id, owner, openingBalance);   // reuse Account's constructor

  void applyInterest() => deposit(balance * interestRate);

  @override
  String toString() => '${super.toString()}  (savings @ ...)';
}
```

- `extends Account` — a savings account **is an** account, so it inherits
  `deposit`, `withdraw`, `balance`, etc. for free.
- `super(...)` — reuses the parent's constructor instead of repeating it.
- `@override` — replaces `toString()` with a savings-specific version, while
  still calling `super.toString()` to reuse the parent's text.

**2. Exceptions.** Every custom error `extends AtmException`, which lets the
menu catch them all with a single `on AtmException`.

---

## Clean code principles used

- **One responsibility per file/class.** The menu handles input, the bank
  handles storage, the account handles money. None of them do each other's
  job.
- **Encapsulation.** `_balance`, `_accounts`, and `_lastId` are private
  (`_`). Outside code can't change a balance directly — it must call
  `deposit`/`withdraw`, which enforce the rules.
- **Don't Repeat Yourself (DRY).** Null handling lives in one `ask()`
  helper; number validation lives in one `askAmount()`; positive-amount
  checks live in one `_requirePositive()`.
- **Fail loudly, recover gracefully.** Broken rules `throw`; one central
  `try/catch` turns them into friendly messages instead of crashes.
- **Meaningful names.** `applyTransfer(amount, outgoing: true)` reads like a
  sentence; no cryptic variables.
- **Small functions.** Each menu action (`deposit`, `withdraw`, `transfer`)
  is a handful of lines that reads top to bottom.
- **Safe by construction.** Transfers charge the source first, so a failed
  transfer can never add money to the target.

---

## Dart topics this project covers

Variables and `final` / `const` · `int` / `double` / `String` / `bool` ·
string interpolation · arithmetic and comparison operators · `if` / `else` ·
`switch` · `while` and `for-in` loops · functions with positional, optional,
and named-required parameters · getters · null safety (`String?`, `?.`,
`??`, `tryParse`) · `List` and `Map` collections · classes and constructors
· inheritance with `super` and `@override` · `enum` · exceptions (custom
classes, `throw`, `try` / `on ... catch`).

Topics intentionally left out to keep it simple: **mixins** and
`async` / `Future`.
