import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/features/chats/repositories/chat_repository.dart';

class ChatWindowComponent extends StatefulWidget {
  final AppTheme currentTheme;
  final String activeChatName;
  final String activeChatHandle;
  final String chatId;
  final ChatRepository chatRepository;

  const ChatWindowComponent({
    super.key,
    required this.currentTheme,
    required this.activeChatName,
    required this.activeChatHandle,
    required this.chatId,
    required this.chatRepository,
  });

  @override
  State<ChatWindowComponent> createState() => _ChatWindowComponentState();
}

class _ChatWindowComponentState extends State<ChatWindowComponent> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void didUpdateWidget(covariant ChatWindowComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _messages = [];
    });
    final msgs = await widget.chatRepository.getMessages(widget.chatId);
    if (mounted) {
      setState(() {
        _messages = List.from(msgs);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    // Add locally immediately as "undelivered"
    final localMsg = MessageModel(text: text, isMe: true, time: DateTime.now(), isDelivered: false);
    setState(() {
      _messages.add(localMsg);
    });
    _scrollToBottom();

    // Send to repository
    final deliveredMsg = await widget.chatRepository.sendMessage(widget.chatId, text);
    
    if (mounted) {
      setState(() {
        // Replace local with delivered
        _messages.removeLast();
        _messages.add(deliveredMsg);
        _isTyping = true;
      });
      _scrollToBottom();
      
      // Auto reply simulation
      final reply = await widget.chatRepository.simulateAutoReply(widget.chatId);
      if (mounted && widget.chatId == widget.chatId) {
        setState(() {
          _isTyping = false;
          if (reply != null) {
            _messages.add(reply);
          }
        });
        _scrollToBottom();
      }
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          // Header
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
                          _isTyping ? 'Typing...' : widget.activeChatHandle,
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold, 
                            color: _isTyping ? widget.currentTheme.primaryColor : widget.currentTheme.textColor.withValues(alpha: 0.5)
                          ),
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

          // Messages List
          Expanded(
            child: Container(
              color: widget.currentTheme.backgroundColor.withValues(alpha: 0.5),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: widget.currentTheme.primaryColor,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 400),
                            decoration: BoxDecoration(
                              color: msg.isMe ? widget.currentTheme.primaryColor : widget.currentTheme.backgroundColor,
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
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: msg.isMe ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(msg.time),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: (msg.isMe ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor).withValues(alpha: 0.7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (msg.isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg.isDelivered ? Icons.done_all : Icons.check,
                                          size: 12,
                                          color: widget.currentTheme.backgroundColor.withValues(alpha: 0.8),
                                        ),
                                      ]
                                    ],
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

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              border: Border(top: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_emotions_outlined, size: 22, color: widget.currentTheme.textColor.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Icon(Icons.attach_file, size: 22, color: widget.currentTheme.textColor.withValues(alpha: 0.7)),
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
                        hintText: 'Transmit a message...',
                        hintStyle: TextStyle(fontSize: 13, color: widget.currentTheme.textColor.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}