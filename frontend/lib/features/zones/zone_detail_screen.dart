import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/features/feed/components/post_card.dart';

class ZoneDetailScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final String zoneTitle;
  final String zoneTag;
  final String zoneStats;
  final String? zoneImage;
  final Color? zoneColor;
  final VoidCallback? onBack;

  const ZoneDetailScreen({
    super.key,
    required this.currentTheme,
    required this.zoneTitle,
    required this.zoneTag,
    required this.zoneStats,
    this.zoneImage,
    this.zoneColor,
    this.onBack,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final Color headerColor = widget.zoneColor ?? widget.currentTheme.secondaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.onBack != null) ...[
                GestureDetector(
                  onTap: widget.onBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: widget.currentTheme.textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Explore Zones',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                decoration: BoxDecoration(
                  color: widget.currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        border: Border(
                          bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                        ),
                        image: widget.zoneImage != null && widget.zoneImage!.isNotEmpty
                            ? DecorationImage(
                                image: widget.zoneImage!.startsWith('http')
                                    ? NetworkImage(widget.zoneImage!) as ImageProvider
                                    : AssetImage(widget.zoneImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.currentTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                                    ),
                                    child: Text(
                                      '${widget.zoneTag.toUpperCase()} • PUBLIC ZONE',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: widget.currentTheme.shadowColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.zoneTitle,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: widget.currentTheme.textColor,
                                    ),
                                  ),
                                ],
                              ),                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A frequency for geometric experiments, high-contrast print systems and modernist artifacts. Share the grids shaping tomorrow\'s retroverse.',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: widget.currentTheme.textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              Text(
                                widget.zoneStats,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: widget.currentTheme.textColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Latest waves',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: widget.currentTheme.textColor,
                              ),
                            ),
                            Text(
                              'POPULAR • NEWEST',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: widget.currentTheme.textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PostCard(
                          currentTheme: widget.currentTheme,
                          name: 'Lumina Dreamer',
                          handle: '@lumina_dream',
                          timeAgo: '18m ago',
                          content: 'New grid study: warm modules moving through a midnight field. Which rhythm should become the next poster series?',
                          imageUrl: 'lib/assets/images/signal_artwork.png',
                          frequencyTag: widget.zoneTag,
                          likesCount: 342,
                          commentsCount: 18,
                          repostsCount: 47,
                        ),
                        PostCard(
                          currentTheme: widget.currentTheme,
                          name: 'Saskia Vance',
                          handle: '@sas_vance',
                          timeAgo: '1h ago',
                          content: 'Uploaded the print notes from today\'s 1200 BAUD workshop. The imperfect registration is the whole signal.',
                          imageUrl: null,
                          frequencyTag: widget.zoneTag,
                          likesCount: 128,
                          commentsCount: 54,
                          repostsCount: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.currentTheme.shadowColor,
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zone guidelines',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: widget.currentTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildGuidelineItem('01', 'Share original artifacts'),
                              _buildGuidelineItem('02', 'Credit borrowed frequencies'),
                              _buildGuidelineItem('03', 'Keep critique constructive'),
                              _buildGuidelineItem('04', 'No signal spam'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.currentTheme.shadowColor,
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frequency keepers',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: widget.currentTheme.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '@gridmaster • @lumina_dream • @sas_vance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.currentTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: widget.currentTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: widget.currentTheme.textColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}