import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/feed/models/post_model.dart';
import 'package:frontend/shared/components/user_avatar.dart';

abstract class PostRepository {
  Future<List<PostModel>> getFeedPosts({int page = 1, int limit = 10});
  Future<PostModel?> getPostById(String postId);
  Future<List<PostModel>> getUserPosts(String nodeId);
  Future<List<PostModel>> getLikedPosts(String nodeId);
  Future<List<PostModel>> getSavedPosts(String nodeId);
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag);
  Future<PostModel?> likePost(String postId);
  Future<PostModel?> savePost(String postId);
  Future<void> deletePost(String postId);
  Future<PostModel?> repost(String postId);
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId);
  Future<Map<String, dynamic>> addCommentToPost(
    String postId,
    String content, {
    String? parentId,
  });
  Future<Map<String, dynamic>?> likeComment(String postId, String commentId);
  Future<List<PostModel>> searchPosts(String query);
}

class PostRepositoryImpl implements PostRepository {
  final ApiClient _apiClient;

  /// Cache em memória de postagens repostadas na sessão para sincronia imediata
  static final Map<String, PostModel> _sessionRepostedPosts = {};
  static final Set<String> _sessionUnrepostedIds = {};
  static final Map<String, PostModel> _knownPostsCache = {};

  PostRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(
              baseUrl: kIsWeb
                  ? 'http://localhost:8080'
                  : (defaultTargetPlatform == TargetPlatform.android
                      ? 'http://10.0.2.2:8080'
                      : 'http://localhost:8080'),
            );

  PostModel _applySessionRepostState(PostModel post) {
    _knownPostsCache[post.id] = post;
    if (_sessionRepostedPosts.containsKey(post.id)) {
      final int effectiveCount =
          post.repostadoPeloUsuario ? post.reposts : (post.reposts + 1);
      final updated = post.copyWith(
        repostadoPeloUsuario: true,
        reposts: effectiveCount,
      );
      _sessionRepostedPosts[post.id] = updated;
      return updated;
    }
    if (_sessionUnrepostedIds.contains(post.id)) {
      final int effectiveCount = post.repostadoPeloUsuario
          ? (post.reposts > 0 ? post.reposts - 1 : 0)
          : post.reposts;
      return post.copyWith(
        repostadoPeloUsuario: false,
        reposts: effectiveCount,
      );
    }
    if (post.repostadoPeloUsuario) {
      _sessionRepostedPosts[post.id] = post;
    }
    return post;
  }

  @override
  Future<List<PostModel>> getFeedPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('/posts?page=$page&limit=$limit');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _applySessionRepostState(
                    PostModel.fromJson(Map<String, dynamic>.from(item)),
                  ))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar feed posts: $e');
    }
    return [];
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/posts/$postId');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is Map) {
          return _applySessionRepostState(
            PostModel.fromJson(Map<String, dynamic>.from(rawData)),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar post $postId: $e');
    }
    return _knownPostsCache[postId];
  }

  @override
  Future<List<PostModel>> getUserPosts(String nodeId) async {
    final List<PostModel> posts = [];
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          posts.addAll(
            rawData.map((item) => _applySessionRepostState(
                  PostModel.fromJson(Map<String, dynamic>.from(item)),
                )),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts do usuario $nodeId: $e');
    }

    final bool isTargetCurrentUser = UserRepositoryImpl.isCurrentUser(nodeId);
    final String cleanTargetNodeId = nodeId.trim().replaceAll('@', '');
    final String formattedTargetHandle = '@$cleanTargetNodeId';

    if (isTargetCurrentUser) {
      // Remove posts que o usuário desfez o repost nesta sessão (e que não são de autoria dele)
      posts.removeWhere((p) {
        final isOwnAuthor = p.authorHandle.replaceAll('@', '').toLowerCase() ==
            cleanTargetNodeId.toLowerCase();
        return !isOwnAuthor && _sessionUnrepostedIds.contains(p.id);
      });

      final existingIds = posts.map((p) => p.id).toSet();
      for (final reposted in _sessionRepostedPosts.values) {
        if (!existingIds.contains(reposted.id)) {
          posts.insert(
            0,
            reposted.copyWith(
              repostadoPeloUsuario: true,
              repostadoNoPerfil: true,
              repostadoPor: formattedTargetHandle,
            ),
          );
        }
      }
    }

    // Marca qualquer post na aba "Posts" cujo autor seja diferente do dono do perfil como repostado
    return posts.map((p) {
      final bool isPostAuthorDifferent =
          p.authorHandle.replaceAll('@', '').toLowerCase() !=
              cleanTargetNodeId.toLowerCase();
      if (isPostAuthorDifferent || p.repostadoNoPerfil) {
        return p.copyWith(
          repostadoNoPerfil: true,
          repostadoPor: p.repostadoPor ?? formattedTargetHandle,
        );
      }
      return p;
    }).toList();
  }

  @override
  Future<List<PostModel>> getLikedPosts(String nodeId) async {
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId/curtidas');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _applySessionRepostState(
                    PostModel.fromJson(Map<String, dynamic>.from(item)),
                  ))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts curtidos de $nodeId: $e');
    }
    return [];
  }

  @override
  Future<List<PostModel>> getSavedPosts(String nodeId) async {
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId/salvos');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _applySessionRepostState(
                    PostModel.fromJson(Map<String, dynamic>.from(item)),
                  ))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts salvos de $nodeId: $e');
    }
    return [];
  }

  @override
  Future<void> createPost(
    String content,
    String? imageUrl,
    String? frequencyTag,
  ) async {
    await _apiClient.post('/posts', body: {'content': content});
  }

  @override
  Future<PostModel?> likePost(String postId) async {
    final response = await _apiClient.post('/posts/$postId/curtir');
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return _applySessionRepostState(
          PostModel.fromJson(Map<String, dynamic>.from(rawData)),
        );
      }
    }
    return null;
  }

  @override
  Future<PostModel?> savePost(String postId) async {
    final response = await _apiClient.post('/posts/$postId/salvar');
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return _applySessionRepostState(
          PostModel.fromJson(Map<String, dynamic>.from(rawData)),
        );
      }
    }
    return null;
  }

  @override
  Future<void> deletePost(String postId) async {
    _sessionRepostedPosts.remove(postId);
    _knownPostsCache.remove(postId);
    await _apiClient.delete('/posts/$postId');
  }

  @override
  Future<PostModel?> repost(String postId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/repostar');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is Map) {
          final updated = PostModel.fromJson(Map<String, dynamic>.from(rawData));
          _knownPostsCache[postId] = updated;
          if (updated.repostadoPeloUsuario) {
            _sessionRepostedPosts[postId] = updated;
            _sessionUnrepostedIds.remove(postId);
          } else {
            _sessionRepostedPosts.remove(postId);
            _sessionUnrepostedIds.add(postId);
          }
          return updated;
        }
      }
    } catch (e) {
      debugPrint('Fallback de repost em memória para o post $postId: $e');
      final existing = _knownPostsCache[postId] ?? _sessionRepostedPosts[postId];
      if (existing != null) {
        final bool novoEstado = !existing.repostadoPeloUsuario;
        final int novaContagem = novoEstado
            ? existing.reposts + 1
            : (existing.reposts > 0 ? existing.reposts - 1 : 0);
        final updated = existing.copyWith(
          repostadoPeloUsuario: novoEstado,
          reposts: novaContagem,
        );
        _knownPostsCache[postId] = updated;
        if (novoEstado) {
          _sessionRepostedPosts[postId] = updated;
          _sessionUnrepostedIds.remove(postId);
        } else {
          _sessionRepostedPosts.remove(postId);
          _sessionUnrepostedIds.add(postId);
        }
        return updated;
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
    try {
      final response = await _apiClient.get('/posts/$postId/comentarios');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _normalizarComentario(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar comentários do post $postId: $e');
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> addCommentToPost(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
    };
    final response = await _apiClient.post('/posts/$postId/comentarios', body: body);
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return _normalizarComentario(Map<String, dynamic>.from(rawData));
      }
    }
    return {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'parentId': parentId,
      'authorName': 'Você',
      'authorHandle': '@node',
      'content': content,
      'timeAgo': 'Agora',
      'likesCount': 0,
      'curtidoPeloUsuario': false,
      'replies': <Map<String, dynamic>>[],
    };
  }

  @override
  Future<Map<String, dynamic>?> likeComment(String postId, String commentId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/comentarios/$commentId/curtir');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is Map) {
          return _normalizarComentario(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e) {
      debugPrint('Erro ao curtir comentário $commentId: $e');
    }
    return null;
  }

  Map<String, dynamic> _normalizarComentario(Map<String, dynamic> json) {
    DateTime data = DateTime.now();
    if (json['createdAt'] != null) {
      data = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['created_at'] != null) {
      data = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    final rawHandle = (json['authorId'] ?? json['authorHandle'] ?? '@node').toString();
    final handle = rawHandle.startsWith('@') ? rawHandle : '@$rawHandle';
    final rawAvatar = json['authorAvatarUrl']?.toString();

    final List<Map<String, dynamic>> repliesList = [];
    if (json['replies'] is List) {
      for (final r in (json['replies'] as List)) {
        if (r is Map) {
          repliesList.add(_normalizarComentario(Map<String, dynamic>.from(r)));
        }
      }
    }

    final commentId = (json['id'] ?? json['_id'])?.toString() ?? '';
    final parentId = (json['parentId'] ?? json['parent_id'])?.toString();

    return {
      'id': commentId,
      'parentId': parentId,
      'authorName': json['authorName'] ?? 'Node Anônimo',
      'authorHandle': handle,
      'authorAvatarUrl': UserAvatar.resolvePresetAsset(rawAvatar) ?? rawAvatar,
      'content': json['content'] ?? '',
      'timeAgo': json['timeAgo'] ?? _calcularTempoAtras(data),
      'likesCount': (json['likes'] ?? json['likesCount'] ?? 0) as int,
      'curtidoPeloUsuario': json['curtidoPeloUsuario'] == true,
      'replies': repliesList,
    };
  }

  static String _calcularTempoAtras(DateTime data) {
    final diferenca = DateTime.now().difference(data);
    if (diferenca.inDays > 0) return '${diferenca.inDays}d atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours}h atrás';
    if (diferenca.inMinutes > 0) return '${diferenca.inMinutes}m atrás';
    return 'Agora';
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _apiClient.get('/posts/busca?q=${Uri.encodeComponent(query)}');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _applySessionRepostState(
                    PostModel.fromJson(Map<String, dynamic>.from(item)),
                  ))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar postagens: $e');
    }
    return [];
  }
}
