import 'package:flutter/material.dart';
import '../../common/notification_service.dart';
import '../../common/color_extension.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  String _timeAgo(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return "Now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} h ago";
    return "${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: service.markAllRead,
            child: const Text("Mark all read"),
          )
        ],
      ),
      body: ValueListenableBuilder<List<AppNotification>>(
        valueListenable: service.notifications,
        builder: (_, list, __) {
          if (list.isEmpty) {
            return const Center(child: Text("No notifications"));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.grey.shade300, height: 1),
            itemBuilder: (_, i) {
              final n = list[i];
              return Container(
                color: n.unread ? Colors.grey.shade100 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, right: 10),
                      child: Icon(Icons.circle,
                          size: 10, color: n.unread ? Colors.orange : Colors.grey),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title,
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(n.subtitle,
                              style: TextStyle(
                                  color: TColor.secondaryText, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(_timeAgo(n.timestamp),
                              style: TextStyle(
                                  color: TColor.secondaryText, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}