import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/features/settings/components/profile_card.dart';
import 'package:frontend/features/feed/components/post_card.dart';
import 'package:frontend/features/feed/models/post_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/post_repository.dart';

class ProfileScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(String route)? onNavigate;
  final String? nodeId; // Opcional: Se nulo, busca o perfil do usuário logado via GET /usuarios/me

  const ProfileScreen({
    super.key,
    required this.currentTheme,
    this.nodeId,
    this.onNavigate,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  final UserRepository _userRepository = UserRepositoryImpl();
  final PostRepositoryImpl _postRepository = PostRepositoryImpl();

  late Future<PerfilRespostaDto> _profileFuture;
  Future<List<PostModel>>? _userPostsFuture;
  Future<List<PostModel>>? _likedPostsFuture;
  Future<List<PostModel>>? _savedPostsFuture;
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isLoadingFollow = false;
  String? _selectedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _refreshPostsLists(String nodeId) {
    _userPostsFuture = _postRepository.getUserPosts(nodeId);
    _likedPostsFuture = _postRepository.getLikedPosts(nodeId);
    _savedPostsFuture = _postRepository.getSavedPosts(nodeId);
  }

  void _fetchProfileData() {
    if (widget.nodeId != null && widget.nodeId!.isNotEmpty) {
      _profileFuture = _userRepository.getUserProfile(widget.nodeId!);
    } else {
      _profileFuture = _userRepository.getMyProfile().catchError((error) {
        final fallbackNodeId = UserRepositoryImpl.currentUserNodeId;
        if (fallbackNodeId != null && fallbackNodeId.isNotEmpty) {
          return _userRepository.getUserProfile(fallbackNodeId);
        }
        throw error;
      });
    }

    _profileFuture.then((profile) {
      if (mounted) {
        setState(() {
          _isFollowing = profile.isFollowing;
          _followersCount = profile.seguidoresCount;
          _followingCount = profile.seguindoCount;
          _selectedAvatarUrl = profile.preferencias?.avatarUrl ?? profile.avatarUrl;
          _refreshPostsLists(profile.nodeId);
        });
      }
    }).catchError((_) {});
  }

  Future<void> _updateAvatarPreference(String newAvatarUrl) async {
    setState(() {
      _selectedAvatarUrl = newAvatarUrl;
    });
    UserRepositoryImpl.setExplicitAvatarChoice(newAvatarUrl);

    try {
      await _userRepository.updatePreferences({'avatarUrl': newAvatarUrl});
      await _userRepository.updateProfile({
        'avatarUrl': newAvatarUrl,
        'preferencias': {'avatarUrl': newAvatarUrl},
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto de perfil: $e')),
        );
      }
    }
  }

  Future<void> _toggleFollow() async {
    final targetNodeId = widget.nodeId;
    if (_isLoadingFollow || targetNodeId == null) return;

    setState(() => _isLoadingFollow = true);

    try {
      if (_isFollowing) {
        await _userRepository.unfollowUser(targetNodeId);
      } else {
        await _userRepository.followUser(targetNodeId);
      }

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
          _followersCount += _isFollowing ? 1 : -1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar follow: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFollow = false);
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Future<void> _deleteUserAccount(String targetNodeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.currentTheme.backgroundColor,
        title: Text(
          'Excluir Usuário',
          style: TextStyle(color: widget.currentTheme.textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja excluir permanentemente o nó $targetNodeId e todas as suas transmissões?',
          style: TextStyle(color: widget.currentTheme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('CANCELAR', style: TextStyle(color: widget.currentTheme.textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('EXCLUIR', style: TextStyle(color: Color(0xFFFF4D4D), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _userRepository.deleteUser(targetNodeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário $targetNodeId excluído com sucesso!')),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (widget.onNavigate != null) {
          widget.onNavigate!('Home Feed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir usuário: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(String postId, String ownerNodeId) async {
    try {
      await _postRepository.deletePost(postId);
      if (mounted) {
        setState(() {
          _refreshPostsLists(ownerNodeId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transmissão excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir transmissão: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerfilRespostaDto>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro ao carregar dados do perfil: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: widget.currentTheme.textColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _fetchProfileData()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = snapshot.data!;
        final bool isOwner = profile.isMe || (widget.nodeId == null || widget.nodeId!.isEmpty);
        final String formattedHandle = profile.nodeId.startsWith('@')
            ? profile.nodeId
            : '@${profile.nodeId}';
        final String effectiveAvatar = _selectedAvatarUrl ??
            profile.preferencias?.avatarUrl ??
            profile.avatarUrl ??
            UserRepositoryImpl.currentAvatarNotifier.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCard(
                    currentTheme: widget.currentTheme,
                    name: profile.nome,
                    handle: formattedHandle,
                    bio: profile.bio ?? 'Sem biografia disponível.',
                    location: (profile.localizacao != null && profile.localizacao!.isNotEmpty)
                        ? profile.localizacao!
                        : 'Penedo, Brasil',
                    avatarUrl: effectiveAvatar,
                    followingCount: _formatCount(_followingCount),
                    followersCount: _formatCount(_followersCount),
                    artifactsCount: '0',
                    isFollowing: _isFollowing,
                    isLoadingFollow: _isLoadingFollow,
                    isOwner: isOwner,
                    canDeleteUser: !isOwner && UserRepositoryImpl.isCurrentUserAdmin,
                    onDeleteUserPressed: () => _deleteUserAccount(profile.nodeId),
                    onFollowPressed: _toggleFollow,
                    onMessagePressed: () {},
                    onAvatarSelected: isOwner ? _updateAvatarPreference : null,
                  ),
                  const SizedBox(height: 24),

                  _buildTabsHeader(context),
                  const SizedBox(height: 20),

                  _buildActiveTabPostsList(profile, isOwner, effectiveAvatar),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTabPostsList(
    PerfilRespostaDto profile,
    bool isOwner,
    String effectiveAvatar,
  ) {
    Future<List<PostModel>>? currentFuture;
    String emptyMessage;
    IconData emptyIcon;

    if (_selectedTab == 1) {
      currentFuture = _likedPostsFuture;
      emptyMessage = 'Nenhuma transmissão curtida por este nó ainda.';
      emptyIcon = Icons.favorite_border;
    } else if (_selectedTab == 2) {
      currentFuture = _savedPostsFuture;
      emptyMessage = 'Nenhuma transmissão salva por este nó ainda.';
      emptyIcon = Icons.bookmark_border;
    } else {
      currentFuture = _userPostsFuture;
      emptyMessage = 'Nenhuma transmissão publicada por este nó.';
      emptyIcon = Icons.satellite_alt_outlined;
    }

    return FutureBuilder<List<PostModel>>(
      future: currentFuture,
      builder: (context, postsSnapshot) {
        if (postsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: widget.currentTheme.primaryColor),
            ),
          );
        }

        final posts = postsSnapshot.data ?? [];
        if (posts.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: widget.currentTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.currentTheme.shadowColor,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(emptyIcon, size: 40, color: widget.currentTheme.primaryColor),
                const SizedBox(height: 12),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.currentTheme.textColor,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: posts.map((post) {
            final bool isPostFromProfileOwner = post.authorHandle.replaceAll('@', '').toLowerCase() ==
                profile.nodeId.replaceAll('@', '').toLowerCase();
            final bool canDeletePost = UserRepositoryImpl.isCurrentUserAdmin ||
                UserRepositoryImpl.isCurrentUser(
                  post.authorHandle,
                  authorName: post.authorName,
                );
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PostCard(
                key: ValueKey('${_selectedTab}_${post.id.isNotEmpty ? post.id : UniqueKey().toString()}'),
                currentTheme: widget.currentTheme,
                name: post.authorName,
                handle: post.authorHandle,
                timeAgo: post.timeAgo,
                frequencyTag: post.frequencyTag,
                content: post.content,
                authorAvatarUrl: (isOwner && isPostFromProfileOwner)
                    ? effectiveAvatar
                    : (post.authorAvatarUrl ?? effectiveAvatar),
                imageUrl: post.imageUrl,
                likesCount: post.likesCount,
                commentsCount: post.commentsCount,
                repostsCount: post.repostsCount,
                isLiked: post.curtidoPeloUsuario,
                isSaved: post.salvoPeloUsuario,
                canDelete: canDeletePost && post.id.isNotEmpty,
                onDeletePressed: () => _deletePost(post.id, profile.nodeId),
                onLikePressed: () async {
                  if (post.id.isNotEmpty) {
                    await _postRepository.likePost(post.id);
                    if (mounted) {
                      setState(() {
                        _refreshPostsLists(profile.nodeId);
                      });
                    }
                  }
                },
                onSavePressed: () async {
                  if (post.id.isNotEmpty) {
                    await _postRepository.savePost(post.id);
                    if (mounted) {
                      setState(() {
                        _refreshPostsLists(profile.nodeId);
                      });
                    }
                  }
                },
                onCommentPressed: () {},
                onRepostPressed: () {},
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTabsHeader(BuildContext context) {
    return Row(
      children: [
        _buildTabButton('Posts', 0),
        const SizedBox(width: 12),
        _buildTabButton('Likes', 1),
        const SizedBox(width: 12),
        _buildTabButton('Saved', 2),
      ],
    );
  }

  Widget _buildTabButton(String title, int tabIndex) {
    bool isSelected = _selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.currentTheme.shadowColor : widget.currentTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
          boxShadow: isSelected
              ? [BoxShadow(color: widget.currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0)]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? widget.currentTheme.backgroundColor : widget.currentTheme.textColor,
          ),
        ),
      ),
    );
  }
}
