import 'package:flutter/material.dart';
import 'modules/header/header.dart';
import 'modules/menu/menu.dart';
import 'modules/post/send-post.dart';
import 'modules/post/post-card.dart';
import '../themes/app_themes.dart';

class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  AppTheme _currentTheme = AppTheme.retroGreen;

  final List<AppTheme> _themes = [
    AppTheme.retroGreen,
    AppTheme.cyberpunk,
    AppTheme.synthwave,
    AppTheme.hacker,
    AppTheme.espresso,
  ];

  int _currentThemeIndex = 0;

  void _toggleTheme() {
    setState(() {
      _currentThemeIndex = (_currentThemeIndex + 1) % _themes.length;
      _currentTheme = _themes[_currentThemeIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: Column(
        children: [
          HeaderWidget(currentTheme: _currentTheme),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 260,
                  child: MenuWidget(currentTheme: _currentTheme, activeRoute: 'Home Feed', onItemSelected: (route) {
                  }),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentTheme.primaryColor,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black, width: 2),
                          ),
                          onPressed: _toggleTheme, 
                          child: Text('Mudar Tema (Atual: ${_currentTheme.name})'),
                        ),
                        const SizedBox(height: 24),
                        SendPostWidget(currentTheme: _currentTheme, onPostSubmitted: (post) {
                          // Lógica para lidar com o envio do post
                        }),
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
                          onLikePressed: () {
                            // Lógica para curtir o post
                          },
                          onCommentPressed: () {
                            // Lógica para comentar no post
                          },
                          onRepostPressed: () {
                            // Lógica para repostar
                          },
                        ),
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
                          onLikePressed: () {
                            // Lógica para curtir o post
                          },
                          onCommentPressed: () {
                            // Lógica para comentar no post
                          },
                          onRepostPressed: () {
                            // Lógica para repostar
                          },
                        ),
                      ],
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