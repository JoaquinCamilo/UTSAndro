import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/bill.dart';
import '../models/investment.dart';
import '../models/debt.dart';

class FinancialProvider with ChangeNotifier {
  // Lists to store data
  final List<Transaction> _transactions = [];
  final List<Budget> _budgets = [];
  final List<Goal> _goals = [];
  final List<Bill> _bills = [];
  final List<Investment> _investments = [];
  final List<Debt> _debts = [];

  // Getters for lists
  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<Goal> get goals => _goals;
  List<Bill> get bills => _bills;
  List<Investment> get investments => _investments;
  List<Debt> get debts => _debts;

  // Computed properties
  double get totalNetWorth {
    final totalInvestments = _investments.fold(0.0, (sum, investment) => sum + investment.currentValue);
    final totalDebts = _debts.fold(0.0, (sum, debt) => sum + debt.remainingAmount);
    return totalInvestments - totalDebts;
  }

  double get totalMonthlyIncome {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == TransactionType.income && t.date.isAfter(firstDayOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalMonthlyExpenses {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return _transactions
        .where((t) => t.type == TransactionType.expense && t.date.isAfter(firstDayOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Bill> get upcomingBills {
    final now = DateTime.now();
    return _bills
        .where((bill) => !bill.isPaid && bill.dueDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Goal> get activeGoals {
    return _goals
        .where((goal) => goal.currentAmount < goal.targetAmount)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  List<Debt> get activeDebts {
    return _debts
        .where((debt) => debt.remainingAmount > 0)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  double get totalBalance {
    double balance = 0;
    for (var transaction in _transactions) {
      if (transaction.isExpense) {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    }
    return balance;
  }

  double get totalIncome {
    return _transactions
        .where((transaction) => !transaction.isExpense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.isExpense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  // CRUD operations for Transactions
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // CRUD operations for Budgets
  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void updateBudget(Budget budget) {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      notifyListeners();
    }
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // CRUD operations for Goals
  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void updateGoal(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // CRUD operations for Bills
  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void updateBill(Bill bill) {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _bills[index] = bill;
      notifyListeners();
    }
  }

  void deleteBill(String id) {
    _bills.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // CRUD operations for Investments
  void addInvestment(Investment investment) {
    _investments.add(investment);
    notifyListeners();
  }

  void updateInvestment(Investment investment) {
    final index = _investments.indexWhere((i) => i.id == investment.id);
    if (index != -1) {
      _investments[index] = investment;
      notifyListeners();
    }
  }

  void deleteInvestment(String id) {
    _investments.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // CRUD operations for Debts
  void addDebt(Debt debt) {
    _debts.add(debt);
    notifyListeners();
  }

  void updateDebt(Debt debt) {
    final index = _debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      _debts[index] = debt;
      notifyListeners();
    }
  }

  void deleteDebt(String id) {
    _debts.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  List<Transaction> getTransactionsByWallet(String walletId) {
    return _transactions.where((t) => t?.id == walletId).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t?.category == category).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t?.date.isAfter(start) == true && t?.date.isBefore(end) == true
    ).toList();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t?.isExpense == false)
        .fold(0, (sum, t) => sum + (t?.amount ?? 0));
  }

  double getTotalExpense() {
    return _transactions
        .where((t) => t?.isExpense == true)
        .fold(0, (sum, t) => sum + (t?.amount ?? 0));
  }
} 