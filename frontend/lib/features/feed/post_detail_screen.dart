import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/post_repository.dart';
import 'package:frontend/features/feed/components/post_detail_card.dart';
import 'package:frontend/features/feed/components/comment_item_component.dart';
import 'package:frontend/features/feed/components/reply_input_widget.dart';

class PostDetailScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final String postId;
  final VoidCallback? onBack;

  const PostDetailScreen({
    super.key,
    required this.currentTheme,
    required this.postId,
    this.onBack,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepositoryImpl _postRepository = PostRepositoryImpl();
  
  bool _isLoading = true;
  Map<String, dynamic>? _postData;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
  }

  Future<void> _fetchPostDetails() async {
    setState(() => _isLoading = true);
    
    // In a real app we would have a getPostById method.
    // For this prototype, we'll fetch feed posts and match, or just use a mock object.
    final posts = await _postRepository.getFeedPosts();
    final post = posts.firstWhere((p) => p['id'] == widget.postId, orElse: () => posts.first);
    
    final comments = await _postRepository.getCommentsForPost(widget.postId);

    if (mounted) {
      setState(() {
        _postData = post;
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment(String text) async {
    final newComment = await _postRepository.addCommentToPost(widget.postId, text);
    if (mounted) {
      setState(() {
        _comments.insert(0, newComment);
        _postData!['commentsCount'] = (_postData!['commentsCount'] as int) + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _postData == null) {
      return Center(
        child: CircularProgressIndicator(color: widget.currentTheme.primaryColor),
      );
    }

    return Scaffold(
      backgroundColor: widget.currentTheme.backgroundColor,
      body: Column(
        children: [
          // Header Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2)),
            ),
            child: Row(
              children: [
                if (widget.onBack != null)
                  GestureDetector(
                    onTap: widget.onBack,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: widget.currentTheme.textColor),
                          const SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: widget.currentTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'Thread',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: widget.currentTheme.textColor,
                    ),
                  ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      PostDetailCard(
                        currentTheme: widget.currentTheme,
                        name: _postData!['authorName'],
                        handle: _postData!['authorHandle'],
                        content: _postData!['content'],
                        imageUrl: _postData!['imageUrl'],
                        frequencyTag: _postData!['frequencyTag'],
                        exactTime: '8:45 PM · Oct 24, 2026 · Telegrama Desktop',
                        likesCount: _postData!['likesCount'],
                        commentsCount: _postData!['commentsCount'],
                        repostsCount: _postData!['repostsCount'],
                      ),
                      
                      // Comments Section
                      if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'No replies yet. Be the first to transmit.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final isLast = index == _comments.length - 1;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: CommentItemComponent(
                                currentTheme: widget.currentTheme,
                                name: comment['authorName'],
                                handle: comment['authorHandle'],
                                content: comment['content'],
                                timeAgo: comment['timeAgo'],
                                likesCount: comment['likesCount'],
                                isLast: isLast,
                              ),
                            );
                          },
                        ),
                        
                      const SizedBox(height: 60), // padding before bottom input
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Reply Input
          ReplyInputWidget(
            currentTheme: widget.currentTheme,
            onReplySubmitted: _addComment,
          ),
        ],
      ),
    );
  }
}
