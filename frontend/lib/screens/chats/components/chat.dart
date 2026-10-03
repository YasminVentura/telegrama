import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';

class ChatWindowComponent extends StatefulWidget {
  final AppTheme currentTheme;
  final String activeChatName;
  final String activeChatHandle;

  const ChatWindowComponent({
    super.key,
    required this.currentTheme,
    required this.activeChatName,
    required this.activeChatHandle,
  });

  @override
  State<ChatWindowComponent> createState() => _ChatWindowComponentState();
}

class _ChatWindowComponentState extends State<ChatWindowComponent> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'The color grid is transmitting perfectly', 'isMe': false, 'time': '10:42'},
    {'text': 'Sim, a modulação de frequência ficou impecável!', 'isMe': true, 'time': '10:45'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _messageController.text,
        'isMe': true,
        'time': 'Agora',
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: widget.currentTheme.primaryColor,
                      child: Text(
                        widget.activeChatName.substring(0, 2).toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.currentTheme.backgroundColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activeChatName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor),
                        ),
                        Text(
                          widget.activeChatHandle,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.videocam_outlined, size: 20, color: widget.currentTheme.textColor),
                    const SizedBox(width: 16),
                    Icon(Icons.phone_outlined, size: 18, color: widget.currentTheme.textColor),
                    const SizedBox(width: 16),
                    Icon(Icons.search, size: 18, color: widget.currentTheme.textColor),
                    const SizedBox(width: 16),
                    Icon(Icons.more_vert, size: 18, color: widget.currentTheme.textColor),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: widget.currentTheme.backgroundColor.withOpacity(0.5),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isMe = msg['isMe'];
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: isMe ? widget.currentTheme.primaryColor : widget.currentTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                        boxShadow: [
                          BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'],
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isMe ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg['time'],
                              style: TextStyle(
                                fontSize: 9.5,
                                color: (isMe ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor).withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              border: Border(top: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_emotions_outlined, size: 22, color: widget.currentTheme.textColor.withOpacity(0.7)),
                const SizedBox(width: 12),
                Icon(Icons.attach_file, size: 22, color: widget.currentTheme.textColor.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                    ),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(fontSize: 13, color: widget.currentTheme.textColor),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Digite uma mensagem...',
                        hintStyle: TextStyle(fontSize: 13, color: widget.currentTheme.textColor.withOpacity(0.4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: Icon(Icons.send, size: 18, color: widget.currentTheme.backgroundColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}