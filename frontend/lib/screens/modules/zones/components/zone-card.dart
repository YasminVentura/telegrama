import 'package:flutter/material.dart';
import '../../../../themes/app_themes.dart';

class ZoneCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String title;
  final String tag;
  final String stats;
  final String? imageUrl;
  final Color? cardColor;
  final VoidCallback? onTap;

  const ZoneCard({
    super.key,
    required this.currentTheme,
    required this.title,
    required this.tag,
    required this.stats,
    this.imageUrl,
    this.cardColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundBoxColor = cardColor ?? currentTheme.backgroundColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: backgroundBoxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: currentTheme.shadowColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
            image: imageUrl != null && imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: imageUrl!.startsWith('http')
                        ? NetworkImage(imageUrl!) as ImageProvider
                        : AssetImage(imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: currentTheme.shadowColor, width: 1.5),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.shadowColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: currentTheme.secondaryColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    border: Border(
                      top: BorderSide(color: currentTheme.shadowColor, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}