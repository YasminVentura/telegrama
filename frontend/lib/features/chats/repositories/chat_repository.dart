import 'dart:async';

class MessageModel {
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isDelivered;

  MessageModel({
    required this.text,
    required this.isMe,
    required this.time,
    this.isDelivered = true,
  });
}

class ChatRepository {
  // Simulação de banco de dados por chatId
  final Map<String, List<MessageModel>> _mockDatabase = {
    'chat_0': [
      MessageModel(text: 'The color grid is transmitting perfectly', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 10))),
      MessageModel(text: 'Sim, a modulação de frequência ficou impecável!', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 8))),
    ],
    'chat_1': [
      MessageModel(text: 'Dial-up session tonight? I found the tapes.', isMe: false, time: DateTime.now().subtract(const Duration(hours: 2))),
    ],
    'chat_2': [
      MessageModel(text: 'Mira sent an audio wave • 0:34', isMe: false, time: DateTime.now().subtract(const Duration(days: 1))),
    ],
    'chat_3': [
      MessageModel(text: 'Saskia: new print artifacts are live.', isMe: false, time: DateTime.now().subtract(const Duration(days: 2))),
    ],
    'chat_4': [
      MessageModel(text: 'Now playing: Digital Sunset Blvd', isMe: false, time: DateTime.now().subtract(const Duration(days: 3))),
    ],
  };

  Future<List<MessageModel>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simula network
    return _mockDatabase[chatId] ?? [];
  }

  Future<MessageModel> sendMessage(String chatId, String text) async {
    final msg = MessageModel(text: text, isMe: true, time: DateTime.now(), isDelivered: false);
    
    if (_mockDatabase[chatId] == null) {
      _mockDatabase[chatId] = [];
    }
    _mockDatabase[chatId]!.add(msg);
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simula rede
    
    return MessageModel(text: text, isMe: true, time: msg.time, isDelivered: true);
  }

  Future<MessageModel?> simulateAutoReply(String chatId) async {
    await Future.delayed(const Duration(seconds: 3));
    final replies = [
      "Transmissão recebida. Sinal forte.",
      "Ajustando os parâmetros da rede.",
      "Entendido. Aguardando novos dados.",
      "A frequência neubrutalista está instável, cuidado!"
    ];
    replies.shuffle();
    final reply = MessageModel(text: replies.first, isMe: false, time: DateTime.now());
    _mockDatabase[chatId]?.add(reply);
    return reply;
  }
}
