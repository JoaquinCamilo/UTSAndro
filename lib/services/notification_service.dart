import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get notifications
  Future<List<AppNotification>> getNotifications() async {
    if (currentUserId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AppNotification.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Add notification
  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    if (currentUserId == null) return;
    
    final notificationRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .doc();
    
    await notificationRef.set({
      'title': title,
      'message': message,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'referenceId': referenceId,
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (currentUserId == null) return;
    
    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _firestore.batch();
    
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    if (currentUserId == null) return;
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    if (currentUserId == null) return 0;
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      
      return querySnapshot.count ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Listen to notifications changes
  Stream<QuerySnapshot> notificationsStream() {
    if (currentUserId == null) {
      return Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
} 