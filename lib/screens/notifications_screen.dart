import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the screen is opened
    Future.microtask(() =>
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Text(
                notificationProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<NotificationProvider>(context, listen: false)
            .deleteNotification(notification.id);
      },
      child: ListTile(
        leading: _getNotificationIcon(),
        title: Text(notification.title),
        subtitle: Text(notification.message),
        trailing: Text(
          _formatDate(notification.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          if (!notification.isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'transaction':
        iconData = Icons.attach_money;
        iconColor = Colors.green;
        break;
      case 'goal':
        iconData = Icons.flag;
        iconColor = Colors.blue;
        break;
      case 'bill':
        iconData = Icons.receipt;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Icon(
      iconData,
      color: iconColor,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 