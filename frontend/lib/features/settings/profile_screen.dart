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
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() {
    // Se nodeId foi informado, busca aquele usuário específico; caso contrário, busca /usuarios/me
    if (widget.nodeId != null && widget.nodeId!.isNotEmpty) {
      _profileFuture = _userRepository.getUserProfile(widget.nodeId!);
    } else {
      _profileFuture = _userRepository.getMyProfile();
    }

    _profileFuture.then((profile) {
      if (mounted) {
        setState(() {
          _followersCount = profile.seguidoresCount;
          _followingCount = profile.seguindoCount;
          _userPostsFuture = _postRepository.getUserPosts(profile.nodeId);
        });
      }
    }).catchError((_) {});
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
                    handle: '@${profile.nodeId}',
                    bio: profile.bio ?? 'Sem biografia disponível.',
                    location: (profile.localizacao != null && profile.localizacao!.isNotEmpty)
                        ? profile.localizacao!
                        : 'Penedo, Brasil',
                    followingCount: _formatCount(_followingCount),
                    followersCount: _formatCount(_followersCount),
                    artifactsCount: '0',
                    isFollowing: _isFollowing,
                    isLoadingFollow: _isLoadingFollow,
                    isOwner: isOwner,
                    onFollowPressed: _toggleFollow,
                    onMessagePressed: () {},
                  ),
                  const SizedBox(height: 24),

                  _buildTabsHeader(context),
                  const SizedBox(height: 20),

                  if (_selectedTab == 0) ...[
                    FutureBuilder<List<PostModel>>(
                      future: _userPostsFuture,
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
                                Icon(Icons.satellite_alt_outlined, size: 40, color: widget.currentTheme.primaryColor),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhuma transmissão publicada por este nó.',
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
                          children: posts.map((post) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: PostCard(
                              key: ValueKey(post.id.isNotEmpty ? post.id : UniqueKey().toString()),
                              currentTheme: widget.currentTheme,
                              name: post.authorName,
                              handle: post.authorHandle,
                              timeAgo: post.timeAgo,
                              frequencyTag: post.frequencyTag,
                              content: post.content,
                              imageUrl: post.imageUrl,
                              likesCount: post.likesCount,
                              commentsCount: post.commentsCount,
                              repostsCount: post.repostsCount,
                              onLikePressed: () async {
                                if (post.id.isNotEmpty) {
                                  await _postRepository.likePost(post.id);
                                  if (mounted) {
                                    setState(() {
                                      _userPostsFuture = _postRepository.getUserPosts(profile.nodeId);
                                    });
                                  }
                                }
                              },
                              onCommentPressed: () {},
                              onRepostPressed: () {},
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Nenhum item nesta seção ainda.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.currentTheme.textColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
