import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Initialize notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  // Add notification
  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      await _notificationService.addNotification(
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
      );
      
      // Reload notifications to get the updated list
      await loadNotifications();
    } catch (e) {
      _error = 'Failed to add notification: $e';
      notifyListeners();
    }
  }

  // Listen to notifications changes
  void listenToNotifications() {
    _notificationService.notificationsStream().listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AppNotification.fromMap(data);
      }).toList();
      
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }
} 