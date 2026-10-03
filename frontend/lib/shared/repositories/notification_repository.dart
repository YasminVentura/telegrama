import 'dart:async';

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final DateTime time;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    this.isRead = false,
  });
}

class NotificationRepository {
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'n1',
      title: 'New Follower',
      content: 'Saskia Vance started following you.',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Post Liked',
      content: 'Lumina Dreamer liked your post "Vector Grids".',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationModel(
      id: 'n3',
      title: 'New Message',
      content: 'Cyber Voyager: Dial-up session tonight?',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
  ];

  int get unreadCount => _mockNotifications.where((n) => !n.isRead).length;

  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications;
  }
}
