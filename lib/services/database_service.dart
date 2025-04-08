import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) return null;
    
    final snapshot = await _database.ref().child('users').child(currentUserId!).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  // Find user by username
  Future<String?> findUserByUsername(String username) async {
    final snapshot = await _database.ref().child('users').get();
    if (snapshot.exists) {
      final Map<dynamic, dynamic> users = snapshot.value as Map;
      for (var entry in users.entries) {
        final Map<String, dynamic> user = Map<String, dynamic>.from(entry.value as Map);
        if (user['username'] == username) {
          return entry.key;
        }
      }
    }
    return null;
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    await _database.ref().child('users').child(currentUserId!).update({
      ...data,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Add transaction
  Future<void> addTransaction({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    required bool isExpense,
    String? notes,
  }) async {
    if (currentUserId == null) return;
    
    final transactionRef = _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('transactions')
        .push();
    
    await transactionRef.set({
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'isExpense': isExpense,
      'notes': notes ?? '',
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
    
    // Update user's balance
    await _database.ref().child('users').child(currentUserId!).update({
      'balance': ServerValue.increment(isExpense ? -amount : amount),
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Get transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    if (currentUserId == null) return [];
    
    final snapshot = await _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('transactions')
        .orderByChild('date')
        .get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map;
      return data.entries.map((entry) {
        final Map<String, dynamic> transaction = Map<String, dynamic>.from(entry.value as Map);
        transaction['id'] = entry.key;
        return transaction;
      }).toList();
    }
    return [];
  }

  // Add goal
  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    String? icon,
    String? color,
  }) async {
    if (currentUserId == null) return;
    
    final goalRef = _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('goals')
        .push();
    
    await goalRef.set({
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': 0,
      'deadline': deadline.millisecondsSinceEpoch,
      'icon': icon ?? 'savings',
      'color': color ?? '#2196F3',
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Get goals
  Future<List<Map<String, dynamic>>> getGoals() async {
    if (currentUserId == null) return [];
    
    final snapshot = await _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('goals')
        .get();
    
    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map;
      return data.entries.map((entry) {
        final Map<String, dynamic> goal = Map<String, dynamic>.from(entry.value as Map);
        goal['id'] = entry.key;
        return goal;
      }).toList();
    }
    return [];
  }

  // Update goal
  Future<void> updateGoal({
    required String goalId,
    required Map<String, dynamic> data,
  }) async {
    if (currentUserId == null) return;
    
    await _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('goals')
        .child(goalId)
        .update({
      ...data,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Add contribution to goal
  Future<void> addContributionToGoal({
    required String goalId,
    required double amount,
  }) async {
    if (currentUserId == null) return;
    
    final goalRef = _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('goals')
        .child(goalId);
    
    final snapshot = await goalRef.get();
    if (snapshot.exists) {
      final Map<String, dynamic> goal = Map<String, dynamic>.from(snapshot.value as Map);
      final double currentAmount = (goal['currentAmount'] ?? 0).toDouble();
      
      await goalRef.update({
        'currentAmount': currentAmount + amount,
        'updatedAt': ServerValue.timestamp,
      });
      
      // Add transaction for the contribution
      await addTransaction(
        description: 'Contribution to ${goal['name']}',
        amount: amount,
        category: 'Goals',
        date: DateTime.now(),
        isExpense: true,
        notes: 'Contribution to goal: ${goal['name']}',
      );
    }
  }

  // Listen to user data changes
  Stream<DatabaseEvent> userDataStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _database.ref()
        .child('users')
        .child(currentUserId!)
        .onValue;
  }

  // Listen to transactions changes
  Stream<DatabaseEvent> transactionsStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('transactions')
        .onValue;
  }

  // Listen to goals changes
  Stream<DatabaseEvent> goalsStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _database.ref()
        .child('users')
        .child(currentUserId!)
        .child('goals')
        .onValue;
  }
} 