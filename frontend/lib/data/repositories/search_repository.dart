import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/post_repository.dart';

abstract class SearchRepository {
  Future<List<Map<String, dynamic>>> globalSearch(String query);
}

class SearchRepositoryImpl implements SearchRepository {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  SearchRepositoryImpl({
    UserRepository? userRepository,
    PostRepository? postRepository,
  })  : _userRepository = userRepository ?? UserRepositoryImpl(),
        _postRepository = postRepository ?? PostRepositoryImpl();

  @override
  Future<List<Map<String, dynamic>>> globalSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    try {
      final futures = <Future>[
        _userRepository.searchUsers(cleanQuery).then((users) {
          for (var u in users) {
            results.add({
              'id': u.nodeId,
              'title': u.nome.isNotEmpty ? u.nome : u.nodeId,
              'subtitle': '@${u.nodeId.replaceAll('@', '')}',
              'category': 'users',
              'avatarUrl': u.avatarUrl,
            });
          }
        }).catchError((_) {}),
        _postRepository.searchPosts(cleanQuery).then((posts) {
          for (var p in posts) {
            results.add({
              'id': p.id,
              'title': p.content,
              'subtitle': '${p.authorName} (${p.authorHandle})',
              'category': 'posts',
              'avatarUrl': p.authorAvatarUrl,
            });
          }
        }).catchError((_) {}),
      ];

      await Future.wait(futures);
    } catch (_) {}

    return results;
  }
}
