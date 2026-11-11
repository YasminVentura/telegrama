import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/header.dart';
import 'package:frontend/shared/widgets/side_menu.dart';
import 'package:frontend/features/feed/components/send_post_widget.dart';
import 'package:frontend/features/feed/components/post_card.dart';
import 'package:frontend/features/feed/post_detail_screen.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/features/settings/settings_screen.dart';
import 'package:frontend/core/themes/app_themes.dart';

import 'package:frontend/data/repositories/post_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/feed/models/post_model.dart';

class MainFeedScreen extends StatefulWidget {
  final VoidCallback? onRequireLogin;
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onLogout;

  const MainFeedScreen({
    super.key,
    this.onRequireLogin,
    this.onNavigateToRegister,
    this.onLogout,
  });

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  AppTheme _currentTheme = AppTheme.retroGreen;
  String _currentRoute = 'Feed Inicial';

  final PostRepositoryImpl _postRepository = PostRepositoryImpl();
  final UserRepository _userRepository = UserRepositoryImpl();
  List<PostModel> _posts = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    if (UserRepositoryImpl.isLoggedIn) {
      _carregarPerfilUsuario();
    }
    _carregarPostagens();
  }

  bool _exigirAutenticacao({
    String mensagem = 'Faça login para acessar esta área.',
  }) {
    if (UserRepositoryImpl.isLoggedIn) {
      return true;
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
    widget.onRequireLogin?.call();
    return false;
  }

  void _navegarParaRota(String route) {
    if (route != 'Feed Inicial' && !UserRepositoryImpl.isLoggedIn) {
      _exigirAutenticacao(
        mensagem:
            'Usuários não logados podem acessar apenas o Feed. Faça login para continuar.',
      );
      return;
    }
    setState(() {
      _currentRoute = route;
    });
  }

  Future<void> _carregarPerfilUsuario() async {
    if (!UserRepositoryImpl.isLoggedIn) return;
    try {
      final profile = await _userRepository.getMyProfile();
      if (mounted && profile.preferencias != null) {
        final themeEnum = profile.preferencias!.theme;
        setState(() {
          if (themeEnum == 'CYBERPUNK_DARK') {
            _currentTheme = AppTheme.cyberpunk;
          } else if (themeEnum == 'SUNSET_SYNTHWAVE') {
            _currentTheme = AppTheme.synthwave;
          } else if (themeEnum == 'MONOKAI_HACKER') {
            _currentTheme = AppTheme.hacker;
          } else if (themeEnum == 'CREAM_ESPRESSO') {
            _currentTheme = AppTheme.espresso;
          } else {
            _currentTheme = AppTheme.retroGreen;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _carregarPostagens() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await _postRepository.getFeedPosts();
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPosts = false);
      }
    }
  }

  Future<void> _publicarPostagem(String conteudo) async {
    if (!_exigirAutenticacao(
      mensagem: 'Faça login para publicar uma transmissão.',
    )) {
      return;
    }
    try {
      await _postRepository.createPost(conteudo, null, null);
      await _carregarPostagens();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transmissão publicada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao publicar post: $e')));
      }
    }
  }

  Future<void> _excluirPostagem(String postId) async {
    if (!_exigirAutenticacao()) return;
    try {
      await _postRepository.deletePost(postId);
      await _carregarPostagens();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transmissão excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha ao excluir post: $e')));
      }
    }
  }

  Widget _buildGuestFeedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _currentTheme.shadowColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODO VISITANTE • APENAS FEED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: _currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Conecte-se à sua conta para publicar transmissões, comentar, curtir e explorar perfis.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _currentTheme.textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: widget.onRequireLogin,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _currentTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _currentTheme.shadowColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _currentTheme.shadowColor,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'FAZER LOGIN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _currentTheme.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool autenticado = UserRepositoryImpl.isLoggedIn;
    final String rotaEfetiva = autenticado ? _currentRoute : 'Home Feed';

    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: Column(
        children: [
          HeaderWidget(
            currentTheme: _currentTheme,
            onNavigate: _navegarParaRota,
            onRequireLogin: widget.onRequireLogin,
            onNavigateToRegister: widget.onNavigateToRegister,
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rotaEfetiva != 'Settings')
                  SizedBox(
                    width: 260,
                    child: MenuWidget(
                      currentTheme: _currentTheme,
                      activeRoute: rotaEfetiva,
                      onItemSelected: _navegarParaRota,
                      onLogout: widget.onLogout,
                    ),
                  ),

                Expanded(
                  child: rotaEfetiva == 'Meu Perfil'
                      ? ProfileScreen(
                          currentTheme: _currentTheme,
                          onNavigate: (route) {
                            _navegarParaRota(route);
                            if (route == 'Feed inicial') {
                              _carregarPostagens();
                            }
                          },
                        )
                      : rotaEfetiva == 'Settings'
                      ? SettingsScreen(
                          currentTheme: _currentTheme,
                          onThemeChanged: (newTheme) {
                            setState(() {
                              _currentTheme = newTheme;
                            });
                          },
                          onBack: () {
                            setState(() {
                              _currentRoute = 'Feed Inicial';
                            });
                            _carregarPerfilUsuario();
                            _carregarPostagens();
                          },
                          onProfileUpdated: () {
                            _carregarPerfilUsuario();
                            _carregarPostagens();
                          },
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  if (autenticado)
                                    SendPostWidget(
                                      currentTheme: _currentTheme,
                                      onPostSubmitted: (post) =>
                                          _publicarPostagem(post),
                                    )
                                  else
                                    _buildGuestFeedBanner(),
                                  const SizedBox(height: 24),
                                  if (_isLoadingPosts)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: CircularProgressIndicator(
                                          color: _currentTheme.primaryColor,
                                        ),
                                      ),
                                    )
                                  else if (_posts.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: _currentTheme.backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _currentTheme.shadowColor,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _currentTheme.shadowColor,
                                            offset: const Offset(4, 4),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.satellite_alt_outlined,
                                            size: 48,
                                            color: _currentTheme.primaryColor,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Nenhuma transmissão no sinal ainda.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _currentTheme.textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Seja o primeiro nó a transmitir uma mensagem no retroverse!',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _currentTheme.textColor
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    ..._posts.map((post) {
                                      final bool canDeletePost =
                                          autenticado &&
                                          (UserRepositoryImpl
                                                  .isCurrentUserAdmin ||
                                              UserRepositoryImpl.isCurrentUser(
                                                post.authorHandle,
                                                authorName: post.authorName,
                                              ));
                                      return PostCard(
                                        key: ValueKey(
                                          post.id.isNotEmpty
                                              ? post.id
                                              : UniqueKey().toString(),
                                        ),
                                        currentTheme: _currentTheme,
                                        name: post.authorName,
                                        handle: post.authorHandle,
                                        timeAgo: post.timeAgo,
                                        content: post.content,
                                        authorAvatarUrl: post.authorAvatarUrl,
                                        imageUrl: post.imageUrl,
                                        likesCount: post.likesCount,
                                        commentsCount: post.commentsCount,
                                        repostsCount: post.repostsCount,
                                        isLiked: post.curtidoPeloUsuario,
                                        isSaved: post.salvoPeloUsuario,
                                        isReposted: post.repostadoPeloUsuario,
                                        canDelete:
                                            canDeletePost && post.id.isNotEmpty,
                                        onDeletePressed: () =>
                                            _excluirPostagem(post.id),
                                        onProfileTap: autenticado
                                            ? null
                                            : () => _exigirAutenticacao(
                                                mensagem:
                                                    'Faça login para visualizar perfis de usuários.',
                                              ),
                                        onLikePressed: () async {
                                          if (!_exigirAutenticacao(
                                            mensagem:
                                                'Faça login para curtir transmissões.',
                                          )) {
                                            return;
                                          }
                                          if (post.id.isNotEmpty) {
                                            final atualizado =
                                                await _postRepository.likePost(
                                                  post.id,
                                                );
                                            if (atualizado != null && mounted) {
                                              setState(() {
                                                final idx = _posts.indexWhere(
                                                  (p) => p.id == post.id,
                                                );
                                                if (idx != -1) {
                                                  _posts[idx] = atualizado;
                                                }
                                              });
                                            }
                                          }
                                        },
                                        onSavePressed: () async {
                                          if (!_exigirAutenticacao(
                                            mensagem:
                                                'Faça login para salvar transmissões.',
                                          )) {
                                            return;
                                          }
                                          if (post.id.isNotEmpty) {
                                            final atualizado =
                                                await _postRepository.savePost(
                                                  post.id,
                                                );
                                            if (atualizado != null && mounted) {
                                              setState(() {
                                                final idx = _posts.indexWhere(
                                                  (p) => p.id == post.id,
                                                );
                                                if (idx != -1) {
                                                  _posts[idx] = atualizado;
                                                }
                                              });
                                            }
                                          }
                                        },
                                        onCommentPressed: () =>
                                            _abrirDetalhesPost(post),
                                        onTap: () => _abrirDetalhesPost(post),
                                        onRepostPressed: () async {
                                          if (!_exigirAutenticacao(
                                            mensagem:
                                                'Faça login para repostar transmissões.',
                                          )) {
                                            return;
                                          }
                                          if (post.id.isNotEmpty) {
                                            final atualizado =
                                                await _postRepository.repost(
                                                  post.id,
                                                );
                                            if (atualizado != null && mounted) {
                                              setState(() {
                                                final idx = _posts.indexWhere(
                                                  (p) => p.id == post.id,
                                                );
                                                if (idx != -1) {
                                                  _posts[idx] = atualizado;
                                                }
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    atualizado
                                                            .repostadoPeloUsuario
                                                        ? 'Transmissão repostada no seu perfil!'
                                                        : 'Repost removido do seu perfil.',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirDetalhesPost(PostModel post) async {
    if (!_exigirAutenticacao(
      mensagem:
          'Usuários não logados podem acessar apenas o Feed. Faça login para abrir e comentar na transmissão.',
    )) {
      return;
    }
    if (post.id.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => PostDetailScreen(
          currentTheme: _currentTheme,
          postId: post.id,
          initialPost: post,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    if (mounted) {
      _carregarPostagens();
    }
  }
}
