abstract class PostRepository {
  Future<List<Map<String, dynamic>>> getFeedPosts({int page = 1, int limit = 10});
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag);
  Future<void> likePost(String postId);
  Future<void> repost(String postId);
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId);
  Future<Map<String, dynamic>> addCommentToPost(String postId, String content);
}

class PostRepositoryImpl implements PostRepository {
  @override
  Future<List<Map<String, dynamic>>> getFeedPosts({int page = 1, int limit = 10}) async {
    // Stub: Simula busca paginada de posts
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {
        'id': 'post_1',
        'authorName': 'Saskia Vance',
        'authorHandle': '@sas_vance',
        'timeAgo': '12m ago',
        'frequencyTag': 'BAUHAUS_GRID_04',
        'content': 'Spent the afternoon rendering custom vector grids in classic Bauhaus style. Really loving the warm aesthetic of burnt orange balanced against deep cool greens.',
        'imageUrl': 'lib/assets/images/signal_artwork.png',
        'likesCount': 342,
        'commentsCount': 18,
        'repostsCount': 47,
      },
      {
        'id': 'post_2',
        'authorName': 'Cyber Voyager',
        'authorHandle': '@cyber_voyager',
        'timeAgo': '45m ago',
        'frequencyTag': 'RETRO_AUDIO_BBS',
        'content': 'Who remembers the sound of a dial-up modem handshaking at 3 AM? That static hiss and beep sequence is basically the retro anthem of early cyberspace.',
        'imageUrl': null,
        'likesCount': 128,
        'commentsCount': 54,
        'repostsCount': 12,
      }
    ];
  }

  @override
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag) async {
    // Stub: Simula criação de postagem
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> likePost(String postId) async {
    // Stub: Simula o ato de curtir
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> repost(String postId) async {
    // Stub: Simula o ato de repostar
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
    // Stub: Retorna os comentários/respostas de um post
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': 'comment_1',
        'authorName': 'Lumina Dreamer',
        'authorHandle': '@lumina_dream',
        'content': 'The color palette reminds me of the old 1970s Braun calculators. Exceptional work!',
        'timeAgo': '8m ago',
        'likesCount': 24,
      },
      {
        'id': 'comment_2',
        'authorName': 'Vector Grid Crew',
        'authorHandle': '#vectorGrids',
        'content': 'Can you share the exact hex codes? We need this frequency on our end.',
        'timeAgo': '2m ago',
        'likesCount': 5,
      }
    ];
  }

  @override
  Future<Map<String, dynamic>> addCommentToPost(String postId, String content) async {
    // Stub: Adiciona um comentário a um post
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'authorName': 'Current User', // Stub for current user
      'authorHandle': '@current_user',
      'content': content,
      'timeAgo': 'Just now',
      'likesCount': 0,
    };
  }
}
