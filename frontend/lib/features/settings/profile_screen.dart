import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/models/user_preferences.dart';
import 'package:frontend/features/settings/components/profile_card.dart';
import 'package:frontend/features/feed/components/post_card.dart';
import 'package:frontend/features/feed/post_detail_screen.dart';
import 'package:frontend/features/feed/models/post_model.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/post_repository.dart';
import 'package:frontend/shared/components/user_avatar.dart';

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
  String? _selectedBannerColor;

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
          _selectedBannerColor =
              profile.preferencias?.bannerColor ?? profile.bannerColor;
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

  Future<void> _showEditProfileDialog(
    PerfilRespostaDto profile,
    String currentEffectiveAvatar,
    String currentEffectiveBannerColor,
  ) async {
    final nameController = TextEditingController(text: profile.nome);
    final bioController = TextEditingController(text: profile.bio ?? '');
    final locationController = TextEditingController(
      text: (profile.localizacao != null && profile.localizacao!.isNotEmpty)
          ? profile.localizacao!
          : 'Penedo, Brasil',
    );
    String tempSelectedAvatar =
        UserAvatar.resolvePresetAsset(currentEffectiveAvatar) ??
            currentEffectiveAvatar;
    String tempSelectedBannerColor = currentEffectiveBannerColor.isNotEmpty
        ? currentEffectiveBannerColor
        : UserPreferences.defaultBannerColor;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 540,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.currentTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.currentTheme.shadowColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.currentTheme.shadowColor,
                      offset: const Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EDITAR PERFIL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: widget.currentTheme.textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(
                                Icons.close,
                                color: widget.currentTheme.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview ao vivo do fundo + avatar
                      Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: UserPreferences.parseBannerColor(
                            tempSelectedBannerColor,
                            fallback: widget.currentTheme.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.currentTheme.shadowColor,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.currentTheme.shadowColor,
                              width: 2,
                            ),
                          ),
                          child: UserAvatar(
                            imageUrl: tempSelectedAvatar,
                            name: nameController.text.isNotEmpty
                                ? nameController.text
                                : profile.nome,
                            radius: 28,
                            showShadow: false,
                            borderWidth: 1.5,
                            borderColor: widget.currentTheme.shadowColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'COR DE FUNDO DA CAPA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: widget.currentTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: UserPreferences.fixedBannerColors.map((hexColor) {
                          final bool isSelected =
                              tempSelectedBannerColor.toUpperCase() ==
                                  hexColor.toUpperCase();
                          final Color swatchColor =
                              UserPreferences.parseBannerColor(hexColor);
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                tempSelectedBannerColor = hexColor;
                              });
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: swatchColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? widget.currentTheme.primaryColor
                                        : widget.currentTheme.shadowColor,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.currentTheme.shadowColor,
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'FOTO DO PERFIL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: widget.currentTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: UserPreferences.fixedAvatars.map((preset) {
                          final bool isSelected = tempSelectedAvatar == preset;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                tempSelectedAvatar = preset;
                              });
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? widget.currentTheme.primaryColor
                                          : widget.currentTheme.backgroundColor,
                                      border: Border.all(
                                        color: isSelected
                                            ? widget.currentTheme.primaryColor
                                            : widget.currentTheme.shadowColor,
                                        width: isSelected ? 2.5 : 2,
                                      ),
                                    ),
                                    child: UserAvatar(
                                      imageUrl: preset,
                                      name: nameController.text.isNotEmpty
                                          ? nameController.text
                                          : profile.nome,
                                      radius: 26,
                                      showShadow: false,
                                      borderWidth: 1.5,
                                      borderColor: widget.currentTheme.shadowColor,
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: widget.currentTheme.primaryColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: widget.currentTheme.shadowColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 12,
                                          color: widget.currentTheme.backgroundColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      _buildDialogField(
                        label: 'NOME DE EXIBIÇÃO',
                        controller: nameController,
                        hintText: 'Seu nome',
                      ),
                      const SizedBox(height: 14),
                      _buildDialogField(
                        label: 'LOCALIZAÇÃO',
                        controller: locationController,
                        hintText: 'Ex: Penedo, Brasil',
                      ),
                      const SizedBox(height: 14),
                      _buildDialogField(
                        label: 'BIOGRAFIA',
                        controller: bioController,
                        hintText: 'Conte um pouco sobre seu nó...',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.currentTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.currentTheme.shadowColor,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'CANCELAR',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: widget.currentTheme.textColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: isSaving
                                ? null
                                : () async {
                                    setDialogState(() => isSaving = true);
                                    try {
                                      UserRepositoryImpl.setExplicitAvatarChoice(
                                        tempSelectedAvatar,
                                      );
                                      UserRepositoryImpl
                                          .setExplicitBannerColorChoice(
                                        tempSelectedBannerColor,
                                      );
                                      await _userRepository.updatePreferences({
                                        'avatarUrl': tempSelectedAvatar,
                                        'bannerColor': tempSelectedBannerColor,
                                      });
                                      await _userRepository.updateProfile({
                                        'nome': nameController.text.trim(),
                                        'bio': bioController.text.trim(),
                                        'localizacao':
                                            locationController.text.trim(),
                                        'avatarUrl': tempSelectedAvatar,
                                        'bannerColor': tempSelectedBannerColor,
                                        'preferencias': {
                                          'avatarUrl': tempSelectedAvatar,
                                          'bannerColor':
                                              tempSelectedBannerColor,
                                        },
                                      });
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _selectedAvatarUrl = tempSelectedAvatar;
                                          _selectedBannerColor =
                                              tempSelectedBannerColor;
                                          _fetchProfileData();
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Perfil atualizado com sucesso!',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setDialogState(() => isSaving = false);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao salvar alterações: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.currentTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.currentTheme.shadowColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.currentTheme.shadowColor,
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: isSaving
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: widget.currentTheme.backgroundColor,
                                        ),
                                      )
                                    : Text(
                                        'SALVAR ALTERAÇÕES',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: widget.currentTheme.backgroundColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: widget.currentTheme.textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: widget.currentTheme.textColor.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: widget.currentTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.currentTheme.shadowColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.currentTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
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
        final String effectiveBannerColor = _selectedBannerColor ??
            profile.preferencias?.bannerColor ??
            profile.bannerColor ??
            (isOwner
                ? UserRepositoryImpl.currentBannerColorNotifier.value
                : UserPreferences.defaultBannerColor);

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
                    bannerColor: effectiveBannerColor,
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
                    onEditProfilePressed: isOwner
                        ? () => _showEditProfileDialog(
                              profile,
                              effectiveAvatar,
                              effectiveBannerColor,
                            )
                        : null,
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
                authorAvatarUrl: isPostFromProfileOwner
                    ? effectiveAvatar
                    : post.authorAvatarUrl,
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
                onCommentPressed: () => _openPostDetails(post, profile.nodeId),
                onTap: () => _openPostDetails(post, profile.nodeId),
                onRepostPressed: () {},
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _openPostDetails(PostModel post, String ownerNodeId) async {
    if (post.id.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PostDetailScreen(
          currentTheme: widget.currentTheme,
          postId: post.id,
          initialPost: post,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _refreshPostsLists(ownerNodeId);
      });
    }
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
