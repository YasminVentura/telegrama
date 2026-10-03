import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class CommentItemComponent extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String content;
  final String timeAgo;
  final int likesCount;
  final bool isLast;

  const CommentItemComponent({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.content,
    required this.timeAgo,
    required this.likesCount,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna Esquerda: Avatar e Linha de Conexão
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: currentTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: currentTheme.secondaryColor,
                  child: Text(
                    name.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.backgroundColor,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: currentTheme.shadowColor.withValues(alpha: 0.3),
                    margin: const EdgeInsets.only(top: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Coluna Direita: Conteúdo
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 16, 24, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: currentTheme.shadowColor.withValues(alpha: 0.2), width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        handle,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: currentTheme.textColor.withValues(alpha: 0.6)),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: TextStyle(fontSize: 12, color: currentTheme.textColor.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(fontSize: 15, height: 1.4, color: currentTheme.textColor),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildActionIcon(Icons.chat_bubble_outline, 'Reply'),
                      const SizedBox(width: 24),
                      _buildActionIcon(Icons.favorite_border, '$likesCount'),
                      const SizedBox(width: 24),
                      _buildActionIcon(Icons.share_outlined, ''),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        children: [
          Icon(icon, size: 16, color: currentTheme.textColor.withValues(alpha: 0.6)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentTheme.textColor.withValues(alpha: 0.6))),
          ]
        ],
      ),
    );
  }
}
