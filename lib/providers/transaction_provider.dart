import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class TransactionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance => getBalance();
  double get totalIncome => getTotalIncome();
  double get totalExpenses => getTotalExpense();

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _firestoreService.getTransactions();
      _transactions = data.map((item) {
        // Convert Firestore data to Transaction model
        return Transaction(
          id: item['id'] as String,
          description: item['description'] as String,
          amount: (item['amount'] as num).toDouble(),
          category: item['category'] as String,
          date: (item['date'] as firestore.Timestamp).toDate(),
          isExpense: item['isExpense'] as bool,
          walletId: 'default_wallet', // Default wallet ID
          notes: item['notes'] as String? ?? '',
          createdAt: (item['createdAt'] as firestore.Timestamp).toDate(),
          updatedAt: (item['updatedAt'] as firestore.Timestamp).toDate(),
          userId: _firestoreService.currentUserId ?? 'default_user',
        );
      }).toList();
    } catch (e) {
      _error = 'Failed to load transactions: $e';
      // Initialize empty list if there's an error
      _transactions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _firestoreService.addTransaction(
        description: transaction.description,
        amount: transaction.amount,
        category: transaction.category,
        date: transaction.date,
        isExpense: transaction.isExpense,
        notes: transaction.notes,
      );
      
      // Reload transactions to get the updated list
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _firestoreService.updateTransaction(
        transactionId: transaction.id,
        description: transaction.description,
        amount: transaction.amount,
        category: transaction.category,
        date: transaction.date,
        isExpense: transaction.isExpense,
        notes: transaction.notes,
      );
      
      // Reload transactions to get the updated list
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestoreService.deleteTransaction(transactionId);
      
      // Reload transactions to get the updated list
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  List<Transaction> getTransactionsByWallet(String walletId) {
    return _transactions.where((t) => t.walletId == walletId).toList();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
      t.date.isAfter(start) && t.date.isBefore(end)
    ).toList();
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => !t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }
} 