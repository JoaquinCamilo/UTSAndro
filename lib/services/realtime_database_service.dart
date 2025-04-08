import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as firebase;
import '../models/bill.dart';
import '../models/debt.dart';
import '../models/split_bill.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/goal.dart';
import '../models/category.dart';

class RealtimeDatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebase.DatabaseReference _database = firebase.FirebaseDatabase.instance.ref();
  final String _goalsId = 'zsAxpX9iN1JO6mxTYv6k';

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Goals
  Future<List<Goal>> getGoals() async {
    final snapshot = await _database.child('goals/$_goalsId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> goalData = Map<String, dynamic>.from(entry.value);
        return Goal.fromMap(goalData);
      }).toList();
    }
    return [];
  }

  Future<void> addGoal(Goal goal) async {
    await _database.child('goals/$_goalsId/${goal.id}').set(goal.toMap());
  }

  Future<void> updateGoal(Goal goal) async {
    await _database.child('goals/$_goalsId/${goal.id}').update(goal.toMap());
  }

  Future<void> deleteGoal(String goalId) async {
    await _database.child('goals/$_goalsId/$goalId').remove();
  }

  // Wallets
  Future<List<Wallet>> getWallets() async {
    final snapshot = await _database.child('wallets/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> walletData = Map<String, dynamic>.from(entry.value);
        return Wallet.fromMap(walletData);
      }).toList();
    }
    return [];
  }

  Future<void> addWallet(Wallet wallet) async {
    await _database.child('wallets/$currentUserId/${wallet.id}').set(wallet.toMap());
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _database.child('wallets/$currentUserId/${wallet.id}').update(wallet.toMap());
  }

  Future<void> deleteWallet(String walletId) async {
    await _database.child('wallets/$currentUserId/$walletId').remove();
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final snapshot = await _database.child('transactions/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> transactionData = Map<String, dynamic>.from(entry.value);
        return Transaction.fromMap(transactionData);
      }).toList();
    }
    return [];
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _database.child('transactions/$currentUserId/${transaction.id}').set(transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _database.child('transactions/$currentUserId/${transaction.id}').update(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _database.child('transactions/$currentUserId/$transactionId').remove();
  }

  // Bills
  Future<List<Bill>> getBills() async {
    final snapshot = await _database.child('bills/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> billData = Map<String, dynamic>.from(entry.value);
        return Bill.fromMap(billData);
      }).toList();
    }
    return [];
  }

  Future<void> addBill(Bill bill) async {
    await _database.child('bills/$currentUserId/${bill.id}').set(bill.toMap());
  }

  Future<void> updateBill(Bill bill) async {
    await _database.child('bills/$currentUserId/${bill.id}').update(bill.toMap());
  }

  Future<void> deleteBill(String billId) async {
    await _database.child('bills/$currentUserId/$billId').remove();
  }

  // Debts
  Future<List<Debt>> getDebts() async {
    final snapshot = await _database.child('debts/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> debtData = Map<String, dynamic>.from(entry.value);
        return Debt.fromMap(debtData);
      }).toList();
    }
    return [];
  }

  Future<void> addDebt(Debt debt) async {
    await _database.child('debts/$currentUserId/${debt.id}').set(debt.toMap());
  }

  Future<void> updateDebt(Debt debt) async {
    await _database.child('debts/$currentUserId/${debt.id}').update(debt.toMap());
  }

  Future<void> deleteDebt(String debtId) async {
    await _database.child('debts/$currentUserId/$debtId').remove();
  }

  // Split Bills
  Future<List<SplitBill>> getSplitBills() async {
    final snapshot = await _database.child('split_bills/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> splitBillData = Map<String, dynamic>.from(entry.value);
        return SplitBill.fromMap(splitBillData);
      }).toList();
    }
    return [];
  }

  Future<void> addSplitBill(SplitBill splitBill) async {
    await _database.child('split_bills/$currentUserId/${splitBill.id}').set(splitBill.toMap());
  }

  Future<void> updateSplitBill(SplitBill splitBill) async {
    await _database.child('split_bills/$currentUserId/${splitBill.id}').update(splitBill.toMap());
  }

  Future<void> deleteSplitBill(String splitBillId) async {
    await _database.child('split_bills/$currentUserId/$splitBillId').remove();
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final snapshot = await _database.child('categories/$currentUserId').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final Map<String, dynamic> categoryData = Map<String, dynamic>.from(entry.value);
        return Category.fromMap(categoryData);
      }).toList();
    }
    return [];
  }

  Future<void> addCategory(Category category) async {
    await _database.child('categories/$currentUserId/${category.id}').set(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _database.child('categories/$currentUserId/${category.id}').update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _database.child('categories/$currentUserId/$categoryId').remove();
  }

  // Write data to a specific path
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    try {
      await _database.child(path).set(data);
    } catch (e) {
      throw Exception('Error writing data: $e');
    }
  }

  // Read data from a specific path
  Future<firebase.DataSnapshot> readData(String path) async {
    try {
      return await _database.child(path).get();
    } catch (e) {
      throw Exception('Error reading data: $e');
    }
  }

  // Update data at a specific path
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _database.child(path).update(data);
    } catch (e) {
      throw Exception('Error updating data: $e');
    }
  }

  // Delete data at a specific path
  Future<void> deleteData(String path) async {
    try {
      await _database.child(path).remove();
    } catch (e) {
      throw Exception('Error deleting data: $e');
    }
  }

  // Listen to realtime changes at a specific path
  Stream<firebase.DatabaseEvent> listenToData(String path) {
    return _database.child(path).onValue;
  }
} 