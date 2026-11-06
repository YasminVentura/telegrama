class PostModel {
  final String id;
  final String authorName;
  final String authorId;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final String timeAgo;
  final String? frequencyTag;
  final int likes;
  final int comments;
  final int reposts;
  final bool curtidoPeloUsuario;

  PostModel({
    required this.id,
    required this.authorName,
    required this.authorId,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    this.timeAgo = 'Agora',
    this.frequencyTag,
    this.likes = 0,
    this.comments = 0,
    this.reposts = 0,
    this.curtidoPeloUsuario = false,
  });

  int get likesCount => likes;
  int get commentsCount => comments;
  int get repostsCount => reposts;
  String get authorHandle => authorId.startsWith('@') ? authorId : '@\$authorId';
  String? get imageUrl => authorAvatarUrl;

  /// Método copyWith para criar cópias modificadas imutáveis
  PostModel copyWith({
    String? id,
    String? authorName,
    String? authorId,
    String? authorAvatarUrl,
    String? content,
    DateTime? createdAt,
    String? timeAgo,
    String? frequencyTag,
    int? likes,
    int? comments,
    int? reposts,
    bool? curtidoPeloUsuario,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      frequencyTag: frequencyTag ?? this.frequencyTag,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      curtidoPeloUsuario: curtidoPeloUsuario ?? this.curtidoPeloUsuario,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    DateTime data = DateTime.now();
    if (json['created_at'] != null) {
      data = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    } else if (json['createdAt'] != null) {
      data = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
    }

    return PostModel(
      id: json['id']?.toString() ?? '',
      authorName: json['authorName'] ?? json['author_name'] ?? 'Node Anônimo',
      authorId: json['authorId'] ?? json['author_id'] ?? 'node',
      authorAvatarUrl: json['authorAvatarUrl'] ?? json['author_avatar_url'],
      content: json['content'] ?? json['conteudo'] ?? '',
      createdAt: data,
      timeAgo: json['timeAgo'] ?? _calcularTempoAtras(data),
      frequencyTag: json['frequencyTag'] ?? 'GENERAL_SIGNAL',
      likes: (json['likesCount'] ?? json['likes'] ?? 0) as int,
      comments: (json['commentsCount'] ?? json['comments'] ?? 0) as int,
      reposts: (json['repostsCount'] ?? json['reposts'] ?? 0) as int,
      curtidoPeloUsuario: json['curtidoPeloUsuario'] == true,
    );
  }

  static String _calcularTempoAtras(DateTime data) {
    final diferenca = DateTime.now().difference(data);
    if (diferenca.inDays > 0) return '${diferenca.inDays}d atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours}h atrás';
    if (diferenca.inMinutes > 0) return '${diferenca.inMinutes}m atrás';
    return 'Agora';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'author_name': authorName,
      'authorId': authorId,
      'author_id': authorId,
      'authorAvatarUrl': authorAvatarUrl,
      'author_avatar_url': authorAvatarUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'timeAgo': timeAgo,
      'frequencyTag': frequencyTag,
      'likes': likes,
      'likesCount': likes,
      'comments': comments,
      'commentsCount': comments,
      'reposts': reposts,
      'repostsCount': reposts,
      'curtidoPeloUsuario': curtidoPeloUsuario,
    };
  }

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'authorName':
      case 'author_name':
        return authorName;
      case 'authorHandle':
      case 'author_id':
        return authorHandle;
      case 'timeAgo':
        return timeAgo;
      case 'frequencyTag':
        return frequencyTag;
      case 'content':
      case 'conteudo':
        return content;
      case 'imageUrl':
      case 'author_avatar_url':
        return imageUrl;
      case 'likesCount':
      case 'likes':
        return likesCount;
      case 'commentsCount':
      case 'comments':
        return commentsCount;
      case 'repostsCount':
      case 'reposts':
        return repostsCount;
      case 'curtidoPeloUsuario':
        return curtidoPeloUsuario;
      default:
        return null;
    }
  }
}