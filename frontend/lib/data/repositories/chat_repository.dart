abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getChatConversations();
  Future<List<Map<String, dynamic>>> getMessagesForChat(String chatId);
  Future<void> sendMessage(String chatId, String text);
  Future<void> markAsRead(String chatId);
}

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<Map<String, dynamic>>> getChatConversations() async {

    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': 'chat_0',
        'name': 'Lumina Dreamer',
        'handle': '@lumina_dream',
        'lastMessage': 'The color grid is transmitting perfectly',
        'time': '10:42',
        'hasNotification': true,
        'notificationCount': '2',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getMessagesForChat(String chatId) async {

    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'text': 'Sim, a modulação de frequência ficou impecável!',
        'isMe': true,
        'time': DateTime.now().toIso8601String(),
        'isDelivered': true,
      }
    ];
  }

  @override
  Future<void> sendMessage(String chatId, String text) async {

    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> markAsRead(String chatId) async {

    await Future.delayed(const Duration(milliseconds: 200));
  }
}
