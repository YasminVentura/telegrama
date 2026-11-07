import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/header.dart';
import 'package:frontend/shared/widgets/side_menu.dart';
import 'package:frontend/features/feed/components/send_post_widget.dart';
import 'package:frontend/features/feed/components/post_card.dart';
import 'package:frontend/features/settings/profile_screen.dart';
import 'package:frontend/features/zones/explore_zones_screen.dart';
import 'package:frontend/features/chats/wave_chats_screen.dart';
import 'package:frontend/features/settings/settings_screen.dart';
import 'package:frontend/core/themes/app_themes.dart';

import 'package:frontend/data/repositories/post_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/features/feed/models/post_model.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  AppTheme _currentTheme = AppTheme.retroGreen;
  String _currentRoute = 'Home Feed';

  final PostRepositoryImpl _postRepository = PostRepositoryImpl();
  final UserRepository _userRepository = UserRepositoryImpl();
  List<PostModel> _posts = [];
  bool _isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfilUsuario();
    _carregarPostagens();
  }

  Future<void> _carregarPerfilUsuario() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao publicar post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: Column(
        children: [
          HeaderWidget(
            currentTheme: _currentTheme,
            onNavigate: (route) {
              setState(() {
                _currentRoute = route;
              });
            },
          ),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentRoute != 'Settings')
                  SizedBox(
                    width: 260,
                    child: MenuWidget(
                      currentTheme: _currentTheme,
                      activeRoute: _currentRoute,
                      onItemSelected: (route) {
                        setState(() {
                          _currentRoute = route;
                        });
                      },
                    ),
                  ),

                Expanded(
                  child: _currentRoute == 'My Profile'
                      ? ProfileScreen(
                          currentTheme: _currentTheme,
                          onNavigate: (route) {
                            setState(() {
                              _currentRoute = route;
                            });
                            if (route == 'Home Feed') {
                              _carregarPostagens();
                            }
                          },
                        )
                      : _currentRoute == 'Explore Zones'
                          ? ExploreZonesScreen(
                              currentTheme: _currentTheme,
                            )
                          : _currentRoute == 'Wave Chats'
                              ? WaveChatsScreen(
                                  currentTheme: _currentTheme,
                                )
                              : _currentRoute == 'Settings'
                                  ? SettingsScreen(
                                      currentTheme: _currentTheme,
                                      onThemeChanged: (newTheme) {
                                        setState(() {
                                          _currentTheme = newTheme;
                                        });
                                      },
                                      onBack: () {
                                        setState(() {
                                          _currentRoute = 'Home Feed';
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
                                              SendPostWidget(
                                                currentTheme: _currentTheme,
                                                onPostSubmitted: (post) => _publicarPostagem(post),
                                              ),
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
                                                    border: Border.all(color: _currentTheme.shadowColor, width: 2),
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
                                                      Icon(Icons.satellite_alt_outlined, size: 48, color: _currentTheme.primaryColor),
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
                                                          color: _currentTheme.textColor.withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else
                                                ..._posts.map((post) => PostCard(
                                                  key: ValueKey(post['id'] ?? UniqueKey().toString()),
                                                  currentTheme: _currentTheme,
                                                  name: post['authorName'] ?? 'Node Anônimo',
                                                  handle: post['authorHandle'] ?? '@node',
                                                  timeAgo: post['timeAgo'] ?? 'Agora',
                                                  content: post['content'] ?? '',
                                                  authorAvatarUrl: post['authorAvatarUrl'],
                                                  imageUrl: post['imageUrl'],
                                                  likesCount: (post['likesCount'] ?? 0) as int,
                                                  commentsCount: (post['commentsCount'] ?? 0) as int,
                                                  repostsCount: (post['repostsCount'] ?? 0) as int,
                                                  onLikePressed: () async {
                                                    if (post['id'] != null) {
                                                      await _postRepository.likePost(post['id']);
                                                    }
                                                  },
                                                  onCommentPressed: () {},
                                                  onRepostPressed: () {},
                                                )),
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
}
