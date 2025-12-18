import 'package:flutter/foundation.dart';

class AppNotification {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  bool unread;

  AppNotification({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.unread = true,
  });
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// In-memory list; replace with persistence if needed.
  final ValueNotifier<List<AppNotification>> notifications =
  ValueNotifier<List<AppNotification>>(<AppNotification>[]);

  void addNotification({
    required String title,
    required String subtitle,
  }) {
    final n = AppNotification(
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      unread: true,
    );
    final current = [...notifications.value];
    current.insert(0, n); // newest on top
    notifications.value = current;
  }

  void markAllRead() {
    final updated = notifications.value
        .map((n) => AppNotification(
      title: n.title,
      subtitle: n.subtitle,
      timestamp: n.timestamp,
      unread: false,
    ))
        .toList();
    notifications.value = updated;
  }
}