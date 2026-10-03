import 'package:flutter/material.dart';
import '../../../core/themes/app_themes.dart';
import 'package:frontend/features/chats/components/chat_list_component.dart';
import 'package:frontend/features/chats/components/chat_window_component.dart';
import 'package:frontend/features/chats/repositories/chat_repository.dart';

class WaveChatsScreen extends StatefulWidget {
  final AppTheme currentTheme;

  const WaveChatsScreen({
    super.key,
    required this.currentTheme,
  });

  @override
  State<WaveChatsScreen> createState() => _WaveChatsScreenState();
}

class _WaveChatsScreenState extends State<WaveChatsScreen> {
  int _selectedChatIndex = 0;
  final ChatRepository _chatRepository = ChatRepository();

  final List<Map<String, dynamic>> _chats = [
    {
      'id': 'chat_0',
      'name': 'Lumina Dreamer',
      'handle': '@lumina_dream',
      'lastMessage': 'The color grid is transmitting perfectly',
      'time': '10:42',
      'hasNotification': true,
      'notificationCount': '2',
    },
    {
      'id': 'chat_1',
      'name': 'Cyber Voyager',
      'handle': '@cyber_voyager',
      'lastMessage': 'Dial-up session tonight? I found the tapes.',
      'time': '9:18',
      'hasNotification': true,
      'notificationCount': '3',
    },
    {
      'id': 'chat_2',
      'name': 'Synthesizer Club',
      'handle': '#analog_dreams',
      'lastMessage': 'Mira sent an audio wave • 0:34',
      'time': 'Yesterday',
      'hasNotification': true,
      'notificationCount': '1',
    },
    {
      'id': 'chat_3',
      'name': 'Vector Grid Crew',
      'handle': '#vectorGrids',
      'lastMessage': 'Saskia: new print artifacts are live.',
      'time': 'Mon',
      'hasNotification': false,
    },
    {
      'id': 'chat_4',
      'name': 'Retrowave FM',
      'handle': '@retrowave_fm',
      'lastMessage': 'Now playing: Digital Sunset Blvd',
      'time': 'Sun',
      'hasNotification': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeChat = _chats[_selectedChatIndex];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 750),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 380,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                    boxShadow: [
                      BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Wave Chats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: widget.currentTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.currentTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 18, color: widget.currentTheme.textColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search transmissions...',
                                style: TextStyle(fontSize: 12, color: widget.currentTheme.textColor.withValues(alpha: 0.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _chats.length,
                          itemBuilder: (context, index) {
                            final chat = _chats[index];
                            return ChatListItemComponent(
                              currentTheme: widget.currentTheme,
                              name: chat['name'],
                              handle: chat['handle'],
                              lastMessage: chat['lastMessage'],
                              time: chat['time'],
                              hasNotification: chat['hasNotification'] ?? false,
                              notificationCount: chat['notificationCount'],
                              isSelected: _selectedChatIndex == index,
                              onTap: () => setState(() => _selectedChatIndex = index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ChatWindowComponent(
                  currentTheme: widget.currentTheme,
                  activeChatName: activeChat['name'],
                  activeChatHandle: activeChat['handle'],
                  chatId: activeChat['id'],
                  chatRepository: _chatRepository,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}