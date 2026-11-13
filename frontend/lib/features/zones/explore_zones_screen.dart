import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/features/zones/components/zone_card.dart';
import 'package:frontend/features/zones/zone_detail_screen.dart';

class ExploreZonesScreen extends StatefulWidget {
  final AppTheme currentTheme;

  const ExploreZonesScreen({
    super.key,
    required this.currentTheme,
  });

  @override
  State<ExploreZonesScreen> createState() => _ExploreZonesScreenState();
}

class _ExploreZonesScreenState extends State<ExploreZonesScreen> {
  int _selectedCategoryIndex = 0;
  int _currentPage = 1;
  String _searchQuery = '';
  Map<String, dynamic>? _selectedZone;

  final List<String> _categories = [
    'For you',
    'Art & Design',
    'Music',
    'Technology',
    'Culture',
    'Live now',
  ];

  final List<Map<String, dynamic>> _allZones = [
    {
      'title': 'Bauhaus 99',
      'tag': '#bauhaus99',
      'stats': '1.1k waves • 384 nodes',
      'imageUrl': 'lib/assets/images/signal_artwork.png',
      'cardColor': null,
    },
    {
      'title': 'Analog Dreams',
      'tag': '#synthesizers',
      'stats': '1.9k waves • 642 nodes',
      'imageUrl': 'lib/assets/images/signal_artwork.png',
      'cardColor': null,
    },
    {
      'title': 'Vector Grids',
      'tag': '#vectorGrids',
      'stats': '890 waves • 215 nodes',
      'imageUrl': null,
      'isPrimaryColor': true,
    },
    {
      'title': 'Vintage OS',
      'tag': '#vintageComputing',
      'stats': '2.4k waves • 793 nodes',
      'imageUrl': null,
      'cardColor': Colors.amber,
    },
    {
      'title': 'Afterglow FM',
      'tag': '#retrowave',
      'stats': '3.1k waves • 1.2k nodes',
      'imageUrl': null,
      'cardColor': Colors.redAccent,
    },
    {
      'title': 'Night BBS',
      'tag': '#cyberspace',
      'stats': '750 waves • 198 nodes',
      'imageUrl': null,
      'cardColor': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_selectedZone != null) {
      Color? zoneColor = _selectedZone!['cardColor'];
      if (_selectedZone!['isPrimaryColor'] == true) {
        zoneColor = widget.currentTheme.primaryColor;
      }

      return ZoneDetailScreen(
        currentTheme: widget.currentTheme,
        zoneTitle: _selectedZone!['title'],
        zoneTag: _selectedZone!['tag'],
        zoneStats: _selectedZone!['stats'],
        zoneImage: _selectedZone!['imageUrl'],
        zoneColor: zoneColor,
        onBack: () => setState(() => _selectedZone = null),
      );
    }

    List<Map<String, dynamic>> filteredZones = _allZones.where((zone) {
      final query = _searchQuery.toLowerCase();
      final title = zone['title'].toString().toLowerCase();
      final tag = zone['tag'].toString().toLowerCase();
      return title.contains(query) || tag.contains(query);
    }).toList();

    int itemsPerPage = 6;
    int totalPages = (filteredZones.isEmpty) ? 1 : (filteredZones.length / itemsPerPage).ceil();
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }

    int startIndex = (_currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredZones.length) {
      endIndex = filteredZones.length;
    }

    List<Map<String, dynamic>> paginatedZones = filteredZones.isEmpty
        ? []
        : filteredZones.sublist(startIndex, endIndex);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FEATURED FREQUENCIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore Zones',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tune into strange communities, creative channels and live retrowave conversations.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: widget.currentTheme.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: widget.currentTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, size: 18, color: widget.currentTheme.textColor.withOpacity(0.6)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _currentPage = 1;
                                      });
                                    },
                                    style: TextStyle(fontSize: 12.5, color: widget.currentTheme.textColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Search channels, radio stations, waves...',
                                      hintStyle: TextStyle(
                                        fontSize: 12.5,
                                        color: widget.currentTheme.textColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                          ),
                          child: Text(
                            '${filteredZones.length} ZONES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_categories.length, (index) {
                        bool isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? widget.currentTheme.primaryColor : widget.currentTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                            ),
                            child: Text(
                              _categories[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIGNALS MATCHING YOUR ORBIT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: widget.currentTheme.textColor.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Zones to enter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: widget.currentTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'SORT: TRENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: widget.currentTheme.textColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              paginatedZones.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No zones found matching your search.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        bool isWide = constraints.maxWidth > 700;

                        List<Widget> zoneCards = paginatedZones.map((zone) {
                          Color? resolvedColor = zone['cardColor'];
                          if (zone['isPrimaryColor'] == true) {
                            resolvedColor = widget.currentTheme.primaryColor;
                          }

                          return ZoneCard(
                            currentTheme: widget.currentTheme,
                            title: zone['title'],
                            tag: zone['tag'],
                            stats: zone['stats'],
                            imageUrl: zone['imageUrl'],
                            cardColor: resolvedColor,
                            onTap: () {
                              setState(() {
                                _selectedZone = zone;
                              });
                            },
                          );
                        }).toList();

                        if (isWide) {
                          return GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.6,
                            children: zoneCards,
                          );
                        } else {
                          return Column(
                            children: zoneCards.map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: card,
                            )).toList(),
                          );
                        }
                      },
                    ),
              const SizedBox(height: 32),

              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPaginationButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                    ),
                    const SizedBox(width: 12),
                    ...List.generate(totalPages, (index) {
                      int pageNumber = index + 1;
                      bool isCurrent = pageNumber == _currentPage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _currentPage = pageNumber),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCurrent ? widget.currentTheme.primaryColor : widget.currentTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                              boxShadow: isCurrent
                                  ? [BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0)]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                '$pageNumber',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 12),
                    _buildPaginationButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton({required IconData icon, VoidCallback? onTap}) {
    bool isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? widget.currentTheme.backgroundColor : widget.currentTheme.backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.currentTheme.shadowColor.withOpacity(isEnabled ? 1 : 0.4), width: 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: isEnabled ? widget.currentTheme.textColor : widget.currentTheme.textColor.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}
