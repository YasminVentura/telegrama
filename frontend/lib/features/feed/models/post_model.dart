class PostModel {
  final String id;
  final String authorName;
  final String authorId;
  final String? authorAvatarUrl;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;

  PostModel({
    required this.id,
    required this.authorName,
    required this.authorId,
    this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      authorName: json['author_name'] ?? 'Unknown Node',
      authorId: json['author_id'] ?? '',
      authorAvatarUrl: json['author_avatar_url'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_name': authorName,
      'author_id': authorId,
      'author_avatar_url': authorAvatarUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }
}
