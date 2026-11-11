import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';
import 'package:frontend/shared/repositories/search_repository.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/features/feed/post_detail_screen.dart';
import 'package:frontend/features/feed/models/post_model.dart';

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
            padding: const EdgeInsets.only(top: 90),
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
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
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

    final results = await _searchRepository.searchGlobal(
      query,
      filter: _selectedFilter,
    );

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
    final userResults =
        _results.where((r) => r.category == SearchCategory.users).toList();
    final postResults =
        _results.where((r) => r.category == SearchCategory.posts).toList();

    return Container(
      width: 640,
      constraints: const BoxConstraints(maxHeight: 560),
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
              border: Border(
                bottom: BorderSide(
                  color: widget.currentTheme.shadowColor,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 24,
                  color: widget.currentTheme.textColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.currentTheme.textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar perfis (@node) ou posts...',
                      hintStyle: TextStyle(
                        fontSize: 17,
                        color: widget.currentTheme.textColor.withValues(
                          alpha: 0.4,
                        ),
                      ),
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
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: widget.currentTheme.shadowColor,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildFilterChip('Todos', SearchCategory.all, Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildFilterChip('Perfis', SearchCategory.users, Icons.person_outline),
                const SizedBox(width: 8),
                _buildFilterChip('Posts', SearchCategory.posts, Icons.article_outlined),
              ],
            ),
          ),

          // Results
          Flexible(
            child: _results.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    !_isLoading
                ? Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        'Nenhum resultado encontrado.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: widget.currentTheme.textColor.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (userResults.isNotEmpty) ...[
                        _buildSectionHeader(
                          'PERFIS DE USUÁRIOS',
                          Icons.person_outline,
                        ),
                        ...userResults.map(_buildUserResultItem),
                      ],
                      if (postResults.isNotEmpty) ...[
                        if (userResults.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            child: Divider(
                              color: widget.currentTheme.shadowColor.withValues(
                                alpha: 0.25,
                              ),
                              thickness: 1.5,
                            ),
                          ),
                        _buildSectionHeader(
                          'POSTAGENS',
                          Icons.article_outlined,
                        ),
                        ...postResults.map(_buildPostResultItem),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: widget.currentTheme.primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: widget.currentTheme.textColor.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    SearchCategory category,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == category;
    return GestureDetector(
      onTap: () => _setFilter(category),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.currentTheme.shadowColor
                : widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.currentTheme.shadowColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? []
                : [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? widget.currentTheme.backgroundColor
                    : widget.currentTheme.textColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? widget.currentTheme.backgroundColor
                      : widget.currentTheme.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(SearchResult item) {
    Navigator.of(context).pop();
    if (item.category == SearchCategory.users) {
      final bool isMe = UserRepositoryImpl.isCurrentUser(
        item.id,
        authorName: item.title,
      );
      final nodeId = item.id.replaceAll('@', '');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: widget.currentTheme.backgroundColor,
            appBar: AppBar(
              backgroundColor: widget.currentTheme.backgroundColor,
              elevation: 0,
              iconTheme: IconThemeData(color: widget.currentTheme.textColor),
              title: Text(
                item.title,
                style: TextStyle(
                  color: widget.currentTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: ProfileScreen(
              currentTheme: widget.currentTheme,
              nodeId: isMe ? null : nodeId,
            ),
          ),
        ),
      );
    } else if (item.category == SearchCategory.posts && item.id.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => PostDetailScreen(
            currentTheme: widget.currentTheme,
            postId: item.id,
            initialPost: item.originalData is PostModel
                ? item.originalData as PostModel
                : null,
            onBack: () => Navigator.of(ctx).pop(),
          ),
        ),
      );
    }
  }

  /// Item de Perfil de Usuário (com foto de perfil e badge PERFIL)
  Widget _buildUserResultItem(SearchResult item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _onItemTapped(item),
        hoverColor: widget.currentTheme.primaryColor.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                builder: (context, currentMyAvatar, _) {
                  final bool isMe = UserRepositoryImpl.isCurrentUser(
                    item.id,
                    authorName: item.title,
                  );
                  final String effectiveAvatar = isMe
                      ? currentMyAvatar
                      : ((item.avatarOrImageUrl != null &&
                              item.avatarOrImageUrl!.isNotEmpty)
                          ? item.avatarOrImageUrl!
                          : UserAvatar.defaultAvatar);

                  return UserAvatar(
                    imageUrl: effectiveAvatar,
                    name: item.title,
                    radius: 20,
                    borderColor: widget.currentTheme.shadowColor,
                    borderWidth: 2,
                    backgroundColor: widget.currentTheme.primaryColor,
                  );
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: widget.currentTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTypeBadge(
                label: 'PERFIL',
                icon: Icons.person,
                badgeColor: Colors.blueAccent,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: widget.currentTheme.textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Item de Post / Transmissão (SEM foto de perfil ao lado, com ícone de transmissão e badge POST)
  Widget _buildPostResultItem(SearchResult item) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _onItemTapped(item),
        hoverColor: widget.currentTheme.primaryColor.withValues(alpha: 0.1),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.currentTheme.shadowColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: widget.currentTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.currentTheme.shadowColor,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: widget.currentTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: widget.currentTheme.textColor.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        color: widget.currentTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(
                  Icons.open_in_new,
                  size: 15,
                  color: widget.currentTheme.textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge({
    required String label,
    required IconData icon,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: badgeColor,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
