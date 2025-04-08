import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;
  final String walletId;
  final String? goalId;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRecurring;
  final String userId;
  final DateTime? dueDate;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    required this.walletId,
    this.goalId,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    required this.userId,
    this.dueDate,
  });

  TransactionType get type => isExpense ? TransactionType.expense : TransactionType.income;

  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Handle different date formats (ISO string or Timestamp)
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        return DateTime.now(); // Fallback
      }
    }
    
    return Transaction(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: parseDate(map['date']),
      isExpense: map['isExpense'] as bool,
      walletId: map['walletId'] as String? ?? 'default_wallet',
      goalId: map['goalId'] as String?,
      notes: map['notes'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      isRecurring: map['isRecurring'] as bool? ?? false,
      userId: map['userId'] as String? ?? 'default_user',
      dueDate: map['dueDate'] != null ? parseDate(map['dueDate']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'walletId': walletId,
      'goalId': goalId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'userId': userId,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? walletId,
    String? goalId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? userId,
    DateTime? dueDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      walletId: walletId ?? this.walletId,
      goalId: goalId ?? this.goalId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      userId: userId ?? this.userId,
      dueDate: dueDate ?? this.dueDate,
    );
  }
} 