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

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  AppTheme _currentTheme = AppTheme.retroGreen;
  
  String _currentRoute = 'Home Feed';

  final List<AppTheme> _themes = [
    AppTheme.retroGreen,
    AppTheme.cyberpunk,
    AppTheme.synthwave,
    AppTheme.hacker,
    AppTheme.espresso,
  ];

  int _currentThemeIndex = 0;

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
                // O menu lateral só aparece se a rota atual NÃO for 'Settings'
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
                
                // Área de conteúdo principal expandida
                Expanded(
                  child: _currentRoute == 'My Profile'
                      ? ProfileScreen(
                          currentTheme: _currentTheme,
                          onNavigate: (route) {
                            setState(() {
                              _currentRoute = route;
                            });
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
                                      },
                                    )
                                  : SingleChildScrollView(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 900),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [                                              const SizedBox(height: 24),
                                              SendPostWidget(
                                                currentTheme: _currentTheme,
                                                onPostSubmitted: (post) {},
                                              ),
                                              const SizedBox(height: 24),
                                              PostCard(
                                                currentTheme: _currentTheme,
                                                name: 'Alice Johnson',
                                                handle: '@alicej',
                                                timeAgo: '2h',
                                                content: 'Explorando o mundo do Flutter! #FlutterDev',
                                                imageUrl: null,
                                                likesCount: 34,
                                                commentsCount: 12,
                                                repostsCount: 5,
                                                onLikePressed: () {},
                                                onCommentPressed: () {},
                                                onRepostPressed: () {},
                                              ),
                                              const SizedBox(height: 16),
                                              PostCard(
                                                currentTheme: _currentTheme,
                                                name: 'Alice Johnson',
                                                handle: '@alicej',
                                                timeAgo: '2h',
                                                content: 'Explorando o mundo do Flutter! #FlutterDev',
                                                imageUrl: 'https://cdn0.peritoanimal.com.br/pt/posts/2/4/2/pele_seca_22242_0_600.jpg',
                                                likesCount: 34,
                                                commentsCount: 12,
                                                repostsCount: 5,
                                                onLikePressed: () {},
                                                onCommentPressed: () {},
                                                onRepostPressed: () {},
                                              ),
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