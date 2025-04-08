import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'transaction', 'goal', 'bill', etc.
  final bool isRead;
  final DateTime createdAt;
  final String? referenceId; // ID of the related item (transaction, goal, etc.)

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.referenceId,
  });

  // Create from Firestore data
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      referenceId: map['referenceId'] as String?,
    );
  }

  // Convert to Firestore data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'referenceId': referenceId,
    };
  }

  // Create a copy with updated fields
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    String? referenceId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      referenceId: referenceId ?? this.referenceId,
    );
  }
} 