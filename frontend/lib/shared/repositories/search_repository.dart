import 'dart:async';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/post_repository.dart';

enum SearchCategory { all, posts, zones, users }

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String? avatarOrImageUrl;
  final dynamic originalData;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.avatarOrImageUrl,
    this.originalData,
  });
}

class SearchRepository {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  SearchRepository({
    UserRepository? userRepository,
    PostRepository? postRepository,
  })  : _userRepository = userRepository ?? UserRepositoryImpl(),
        _postRepository = postRepository ?? PostRepositoryImpl();

  Future<List<SearchResult>> searchGlobal(String query, {SearchCategory filter = SearchCategory.all}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = <SearchResult>[];

    final shouldSearchUsers = filter == SearchCategory.all || filter == SearchCategory.users;
    final shouldSearchPosts = filter == SearchCategory.all || filter == SearchCategory.posts;
    final shouldSearchZones = filter == SearchCategory.all || filter == SearchCategory.zones;

    try {
      final futures = <Future>[];

      if (shouldSearchUsers) {
        futures.add(
          _userRepository.searchUsers(cleanQuery).then((users) {
            for (var u in users) {
              results.add(SearchResult(
                id: u.nodeId,
                title: u.nome.isNotEmpty ? u.nome : u.nodeId,
                subtitle: '@${u.nodeId.replaceAll('@', '')}',
                category: SearchCategory.users,
                avatarOrImageUrl: u.avatarUrl,
                originalData: u,
              ));
            }
          }).catchError((_) {}),
        );
      }

      if (shouldSearchPosts) {
        futures.add(
          _postRepository.searchPosts(cleanQuery).then((posts) {
            for (var p in posts) {
              results.add(SearchResult(
                id: p.id,
                title: p.content,
                subtitle: '${p.authorName} (${p.authorHandle})',
                category: SearchCategory.posts,
                avatarOrImageUrl: p.authorAvatarUrl,
                originalData: p,
              ));
            }
          }).catchError((_) {}),
        );
      }

      if (shouldSearchZones) {
        final mockZones = [
          SearchResult(id: 'z1', title: 'BAUHAUS_GRID_04', subtitle: 'Public Zone • 14k members', category: SearchCategory.zones),
          SearchResult(id: 'z2', title: 'RETRO_AUDIO_BBS', subtitle: 'Public Zone • 3k members', category: SearchCategory.zones),
          SearchResult(id: 'z3', title: 'CYBERPUNK_LOUNGE', subtitle: 'Public Zone • 8.5k members', category: SearchCategory.zones),
        ];
        final q = cleanQuery.toLowerCase();
        for (var z in mockZones) {
          if (z.title.toLowerCase().contains(q) || z.subtitle.toLowerCase().contains(q)) {
            results.add(z);
          }
        }
      }

      await Future.wait(futures);
    } catch (_) {}

    return results;
  }
}
