import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) return null;
    
    final docSnapshot = await _firestore.collection('users').doc(currentUserId).get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
    return null;
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    await _firestore.collection('users').doc(currentUserId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTransaction({
    required String description,
    required double amount,
    required String category,
    required DateTime date,
    required bool isExpense,
    String? notes,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _ensureUserDocumentExists();
    
    final transactionRef = _firestore.collection('users').doc(currentUserId).collection('transactions').doc();
    
    await transactionRef.set({
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'notes': notes ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    await _firestore.collection('users').doc(currentUserId).update({
      'balance': FieldValue.increment(isExpense ? -amount : amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _ensureUserDocumentExists() async {
    if (currentUserId == null) return;
    
    final userDoc = _firestore.collection('users').doc(currentUserId);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'balance': 0,
        'username': _auth.currentUser?.email?.split('@')[0] ?? 'user_${currentUserId!.substring(0, 5)}',
        'email': _auth.currentUser?.email ?? '',
      });
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    if (currentUserId == null) return [];
    
    try {
      await _ensureUserDocumentExists();
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    int? icon,
    int? color,
  }) async {
    if (currentUserId == null) return;
    
    final goalRef = _firestore.collection('users').doc(currentUserId).collection('goals').doc();
    
    await goalRef.set({
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': 0,
      'deadline': Timestamp.fromDate(deadline),
      'icon': icon ?? 0xe587, // Simpan sebagai int
      'color': color ?? 0xFF2196F3,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    if (currentUserId == null) return [];
    
    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('goals')
        .get();
    
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateGoal({
    required String goalId,
    required Map<String, dynamic> data,
  }) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('goals')
        .doc(goalId)
        .update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addContributionToGoal({
    required String goalId,
    required double amount,
  }) async {
    if (currentUserId == null) return;
    
    final goalRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('goals')
        .doc(goalId);
    
    final docSnapshot = await goalRef.get();
    if (docSnapshot.exists) {
      final goal = docSnapshot.data()!;
      final double currentAmount = (goal['currentAmount'] ?? 0).toDouble();
      
      await goalRef.update({
        'currentAmount': currentAmount + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
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

  Future<String?> findUserByUsername(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Stream<DocumentSnapshot> userDataStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot> transactionsStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> goalsStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('goals')
        .snapshots();
  }

  Future<void> updateTransaction({
    required String transactionId,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? notes,
  }) async {
    if (currentUserId == null) return;
    
    final Map<String, dynamic> updateData = {};
    
    if (description != null) updateData['description'] = description;
    if (amount != null) updateData['amount'] = amount;
    if (category != null) updateData['category'] = category;
    if (date != null) updateData['date'] = Timestamp.fromDate(date);
    if (isExpense != null) updateData['isExpense'] = isExpense;
    if (notes != null) updateData['notes'] = notes;
    
    updateData['updatedAt'] = FieldValue.serverTimestamp();
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('transactions')
        .doc(transactionId)
        .update(updateData);
    
    if (amount != null || isExpense != null) {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .doc(transactionId)
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final oldAmount = (data['amount'] as num).toDouble();
        final oldIsExpense = data['isExpense'] as bool;
        
        double balanceChange = 0;
        
        if (amount != null && isExpense != null) {
          balanceChange = oldIsExpense ? oldAmount : -oldAmount;
          balanceChange += isExpense ? -amount : amount;
        } else if (amount != null) {
          balanceChange = oldIsExpense ? (oldAmount - amount) : (amount - oldAmount);
        } else if (isExpense != null) {
          balanceChange = oldIsExpense ? oldAmount : -oldAmount;
          balanceChange += isExpense ? -oldAmount : oldAmount;
        }
        
        await _firestore.collection('users').doc(currentUserId).update({
          'balance': FieldValue.increment(balanceChange),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (currentUserId == null) return;
    
    final docSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('transactions')
        .doc(transactionId)
        .get();
    
    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final amount = (data['amount'] as num).toDouble();
      final isExpense = data['isExpense'] as bool;
      
      final balanceChange = isExpense ? amount : -amount;
      
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
      
      await _firestore.collection('users').doc(currentUserId).update({
        'balance': FieldValue.increment(balanceChange),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
