import 'package:firebase_database/firebase_database.dart' as firebase;
import '../models/transaction.dart';

class TransactionService {
  final firebase.DatabaseReference _database = firebase.FirebaseDatabase.instance.ref();
  final String _transactionsPath = 'transactions';

  // Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _database
          .child(_transactionsPath)
          .child(transaction.userId)
          .child(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  // Get all transactions for a user
  Future<List<Transaction>> getTransactions(String userId) async {
    try {
      final snapshot = await _database
          .child(_transactionsPath)
          .child(userId)
          .get();

      if (snapshot.value == null) return [];

      final Map<dynamic, dynamic> transactionsMap = 
          snapshot.value as Map<dynamic, dynamic>;
      
      return transactionsMap.values.map((data) {
        final Map<String, dynamic> transactionData = Map<String, dynamic>.from(data as Map);
        return Transaction.fromMap(transactionData);
      }).toList();
    } catch (e) {
      throw Exception('Error getting transactions: $e');
    }
  }

  // Get realtime stream of transactions for a user
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _database
        .child(_transactionsPath)
        .child(userId)
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return [];

          final Map<dynamic, dynamic> transactionsMap = 
              event.snapshot.value as Map<dynamic, dynamic>;
          
          return transactionsMap.values.map((data) {
            final Map<String, dynamic> transactionData = Map<String, dynamic>.from(data as Map);
            return Transaction.fromMap(transactionData);
          }).toList();
        });
  }

  // Update a transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _database
          .child(_transactionsPath)
          .child(transaction.userId)
          .child(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _database
          .child(_transactionsPath)
          .child(userId)
          .child(transactionId)
          .remove();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // Get total balance for a user
  Future<double> getTotalBalance(String userId) async {
    try {
      final transactions = await getTransactions(userId);
      double balance = 0.0;

      for (var transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      return balance;
    } catch (e) {
      throw Exception('Error calculating total balance: $e');
    }
  }
} 