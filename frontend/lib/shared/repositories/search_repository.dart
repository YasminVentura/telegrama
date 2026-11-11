import 'dart:async';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/post_repository.dart';

enum SearchCategory { all, posts, users }

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

  Future<List<SearchResult>> searchGlobal(
    String query, {
    SearchCategory filter = SearchCategory.all,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = <SearchResult>[];

    final shouldSearchUsers =
        filter == SearchCategory.all || filter == SearchCategory.users;
    final shouldSearchPosts =
        filter == SearchCategory.all || filter == SearchCategory.posts;

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

      await Future.wait(futures);
    } catch (_) {}

    return results;
  }
}
