import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/post_repository.dart';
import 'package:frontend/features/feed/components/post_detail_card.dart';
import 'package:frontend/features/feed/components/comment_item_component.dart';
import 'package:frontend/features/feed/components/reply_input_widget.dart';
import 'package:frontend/features/feed/models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final String postId;
  final PostModel? initialPost;
  final VoidCallback? onBack;

  const PostDetailScreen({
    super.key,
    required this.currentTheme,
    required this.postId,
    this.initialPost,
    this.onBack,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostRepositoryImpl _postRepository = PostRepositoryImpl();
  final FocusNode _replyFocusNode = FocusNode();

  bool _isLoading = true;
  PostModel? _postData;
  List<Map<String, dynamic>> _comments = [];
  String? _replyingToCommentId;
  String? _replyingToHandle;

  @override
  void initState() {
    super.initState();
    _postData = widget.initialPost;
    _fetchPostDetails();
  }

  @override
  void dispose() {
    _replyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetails() async {
    if (_postData == null) {
      setState(() => _isLoading = true);
    }

    final fetchedPost = await _postRepository.getPostById(widget.postId);
    final comments = await _postRepository.getCommentsForPost(widget.postId);

    if (mounted) {
      setState(() {
        if (fetchedPost != null) {
          _postData = fetchedPost;
        }
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment(String text) async {
    final parentId = _replyingToCommentId;
    try {
      await _postRepository.addCommentToPost(
        widget.postId,
        text,
        parentId: parentId,
      );
      setState(() {
        _replyingToCommentId = null;
        _replyingToHandle = null;
      });
      await _fetchPostDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar comentário: $e')),
        );
      }
    }
  }

  Future<void> _togglePostLike() async {
    if (_postData == null) return;
    final atualizado = await _postRepository.likePost(widget.postId);
    if (atualizado != null && mounted) {
      setState(() {
        _postData = atualizado;
      });
    }
  }

  Future<void> _togglePostSave() async {
    if (_postData == null) return;
    final atualizado = await _postRepository.savePost(widget.postId);
    if (atualizado != null && mounted) {
      setState(() {
        _postData = atualizado;
      });
    }
  }

  Future<void> _togglePostRepost() async {
    if (_postData == null) return;
    final atualizado = await _postRepository.repost(widget.postId);
    if (atualizado != null && mounted) {
      setState(() {
        _postData = atualizado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            atualizado.repostadoPeloUsuario
                ? 'Transmissão repostada no seu perfil!'
                : 'Repost removido do seu perfil.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleCommentLike(String commentId) async {
    await _postRepository.likeComment(widget.postId, commentId);
    final comments = await _postRepository.getCommentsForPost(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  void _startReplyingToComment(String commentId, String handle) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToHandle = handle;
    });
    _replyFocusNode.requestFocus();
  }

  void _cancelReplyToComment() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToHandle = null;
    });
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_postData);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _postData == null) {
      return Scaffold(
        backgroundColor: widget.currentTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: widget.currentTheme.primaryColor,
          ),
        ),
      );
    }

    if (_postData == null) {
      return Scaffold(
        backgroundColor: widget.currentTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Transmissão não encontrada.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.currentTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _handleBack(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.currentTheme.backgroundColor,
      body: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                GestureDetector(
                  onTap: () => _handleBack(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: widget.currentTheme.textColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: widget.currentTheme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      PostDetailCard(
                        currentTheme: widget.currentTheme,
                        name: _postData!.authorName,
                        handle: _postData!.authorHandle,
                        content: _postData!.content,
                        authorAvatarUrl: _postData!.authorAvatarUrl,
                        imageUrl: _postData!.imageUrl,
                        frequencyTag: _postData!.frequencyTag,
                        exactTime: _postData!.timeAgo,
                        likesCount: _postData!.likesCount,
                        commentsCount: _postData!.commentsCount,
                        repostsCount: _postData!.repostsCount,
                        isLiked: _postData!.curtidoPeloUsuario,
                        isSaved: _postData!.salvoPeloUsuario,
                        isReposted: _postData!.repostadoPeloUsuario,
                        onLikePressed: _togglePostLike,
                        onSavePressed: _togglePostSave,
                        onRepostPressed: _togglePostRepost,
                        onCommentPressed: () {
                          _cancelReplyToComment();
                          _replyFocusNode.requestFocus();
                        },
                      ),

                      if (_comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'Nenhum comentário ainda. Seja o primeiro nó a responder!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.textColor.withValues(
                                alpha: 0.5,
                              ),
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
                            final List<Map<String, dynamic>> repliesList =
                                (comment['replies'] is List)
                                    ? (comment['replies'] as List)
                                        .map((e) => Map<String, dynamic>.from(e as Map))
                                        .toList()
                                    : const [];

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: CommentItemComponent(
                                key: ValueKey(comment['id'] ?? 'comment_$index'),
                                currentTheme: widget.currentTheme,
                                commentId: comment['id']?.toString() ?? '',
                                name: comment['authorName'] ?? 'Node Anônimo',
                                handle: comment['authorHandle'] ?? '@node',
                                authorAvatarUrl: comment['authorAvatarUrl']?.toString(),
                                content: comment['content'] ?? '',
                                timeAgo: comment['timeAgo'] ?? 'Agora',
                                likesCount: (comment['likesCount'] ?? 0) as int,
                                isLiked: comment['curtidoPeloUsuario'] == true,
                                isLast: isLast,
                                replies: repliesList,
                                onReplyPressed: _startReplyingToComment,
                                onLikePressed: _toggleCommentLike,
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),

          ReplyInputWidget(
            currentTheme: widget.currentTheme,
            focusNode: _replyFocusNode,
            replyingToHandle: _replyingToHandle,
            onCancelReply: _cancelReplyToComment,
            onReplySubmitted: _addComment,
          ),
        ],
      ),
    );
  }
}
