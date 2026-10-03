import 'dart:async';

enum SearchCategory { all, posts, zones, users }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String? avatarOrImageUrl;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.avatarOrImageUrl,
  });
}

class SearchRepository {
  Future<List<SearchResult>> searchGlobal(String query, {SearchCategory filter = SearchCategory.all}) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simula latência de rede

    if (query.isEmpty) return [];

    final q = query.toLowerCase();

    final List<SearchResult> allMocks = [
      SearchResult(id: 'p1', title: 'The color grid is transmitting perfectly', subtitle: '@lumina_dream', category: SearchCategory.posts),
      SearchResult(id: 'p2', title: 'New grid study: warm modules moving', subtitle: '@lumina_dream', category: SearchCategory.posts),
      SearchResult(id: 'z1', title: 'BAUHAUS_GRID_04', subtitle: 'Public Zone • 14k members', category: SearchCategory.zones),
      SearchResult(id: 'z2', title: 'RETRO_AUDIO_BBS', subtitle: 'Public Zone • 3k members', category: SearchCategory.zones),
      SearchResult(id: 'u1', title: 'Saskia Vance', subtitle: '@sas_vance', category: SearchCategory.users),
      SearchResult(id: 'u2', title: 'Lumina Dreamer', subtitle: '@lumina_dream', category: SearchCategory.users),
      SearchResult(id: 'u3', title: 'Cyber Voyager', subtitle: '@cyber_voyager', category: SearchCategory.users),
    ];

    final filtered = allMocks.where((item) {
      if (filter != SearchCategory.all && item.category != filter) return false;
      return item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q);
    }).toList();

    return filtered;
  }
}
