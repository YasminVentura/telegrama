import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/shared/repositories/search_repository.dart';
import 'package:frontend/features/settings/profile_screen.dart';

class GlobalSearchModal extends StatefulWidget {
  final AppTheme currentTheme;

  const GlobalSearchModal({super.key, required this.currentTheme});

  static Future<void> show(BuildContext context, AppTheme theme) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Material(
              color: Colors.transparent,
              child: GlobalSearchModal(currentTheme: theme),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<GlobalSearchModal> createState() => _GlobalSearchModalState();
}

class _GlobalSearchModalState extends State<GlobalSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final SearchRepository _searchRepository = SearchRepository();
  
  List<SearchResult> _results = [];
  bool _isLoading = false;
  SearchCategory _selectedFilter = SearchCategory.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final results = await _searchRepository.searchGlobal(query, filter: _selectedFilter);

    if (mounted && _searchController.text.trim() == query) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  void _setFilter(SearchCategory filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: widget.currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.currentTheme.shadowColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.currentTheme.shadowColor,
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 24, color: widget.currentTheme.textColor),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor),
                    decoration: InputDecoration(
                      hintText: 'Search for anything...',
                      hintStyle: TextStyle(fontSize: 18, color: widget.currentTheme.textColor.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: widget.currentTheme.primaryColor,
                    ),
                  ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.currentTheme.shadowColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
                  ),
                  child: Text('ESC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: widget.currentTheme.textColor)),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              border: Border(bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              children: [
                _buildFilterChip('All', SearchCategory.all),
                const SizedBox(width: 8),
                _buildFilterChip('Posts', SearchCategory.posts),
                const SizedBox(width: 8),
                _buildFilterChip('Zones', SearchCategory.zones),
                const SizedBox(width: 8),
                _buildFilterChip('Users', SearchCategory.users),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _results.isEmpty && _searchController.text.isNotEmpty && !_isLoading
                ? Center(
                    child: Text(
                      'No signal found.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.currentTheme.textColor.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return _buildResultItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchCategory category) {
    final isSelected = _selectedFilter == category;
    return GestureDetector(
      onTap: () => _setFilter(category),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? widget.currentTheme.shadowColor : widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.currentTheme.shadowColor, width: 1.5),
            boxShadow: isSelected ? [] : [
              BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isSelected ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(SearchResult item) {
    Navigator.of(context).pop();
    if (item.category == SearchCategory.users) {
      final nodeId = item.id.replaceAll('@', '');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: widget.currentTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: widget.currentTheme.backgroundColor,
              elevation: 0,
              iconTheme: IconThemeData(color: widget.currentTheme.textColor),
              title: Text(item.title, style: TextStyle(color: widget.currentTheme.textColor, fontWeight: FontWeight.bold)),
            ),
            body: ProfileScreen(
              currentTheme: widget.currentTheme,
              nodeId: nodeId,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildResultItem(SearchResult item) {
    IconData icon;
    Color color;

    switch (item.category) {
      case SearchCategory.posts:
        icon = Icons.article_outlined;
        color = widget.currentTheme.primaryColor;
        break;
      case SearchCategory.zones:
        icon = Icons.grid_view_rounded;
        color = widget.currentTheme.secondaryColor;
        break;
      case SearchCategory.users:
        icon = Icons.person_outline;
        color = Colors.blueAccent;
        break;
      default:
        icon = Icons.search;
        color = widget.currentTheme.shadowColor;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _onItemTapped(item),
        hoverColor: widget.currentTheme.primaryColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: widget.currentTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: widget.currentTheme.textColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
