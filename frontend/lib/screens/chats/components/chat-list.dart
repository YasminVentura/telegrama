import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';

class ChatListItemComponent extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String lastMessage;
  final String time;
  final bool hasNotification;
  final String? notificationCount;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatListItemComponent({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.lastMessage,
    required this.time,
    this.hasNotification = false,
    this.notificationCount,
    required this.isSelected,
    required this.onTap,
  });

  String _getInitials(String text) {
    List<String> words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'WC';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 6, left: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? currentTheme.primaryColor : currentTheme.shadowColor,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: currentTheme.shadowColor,
                      offset: const Offset(4, 3),
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: currentTheme.shadowColor, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: currentTheme.primaryColor,
                  child: Text(
                    _getInitials(name),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentTheme.backgroundColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: currentTheme.textColor,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: currentTheme.textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: currentTheme.textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        if (hasNotification && notificationCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: currentTheme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                            ),
                            child: Text(
                              notificationCount!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: currentTheme.backgroundColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}