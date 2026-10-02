import 'package:flutter/material.dart';
import '../../../themes/app_themes.dart';
import 'components/profile-card.dart';
import '../post/post-card.dart'; 

class ProfileScreen extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(String route)? onNavigate;

  const ProfileScreen({
    super.key,
    required this.currentTheme,
    this.onNavigate,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
                name: 'Saskia Vance',
                handle: '@sas_vance',
                bio: 'Exploring high-contrast textures, vintage print design, and modern geometry. Based in Berlin. Building digital artifacts on the daily. 📻 🌱',
                location: 'Berlin, Germany',
                followingCount: '1.2k',
                followersCount: '45.9k',
                artifactsCount: '184',
                onFollowPressed: () {},
                onMessagePressed: () {},
              ),
              const SizedBox(height: 24),

              _buildTabsHeader(context),
              const SizedBox(height: 20),

              PostCard(
                currentTheme: widget.currentTheme,
                name: 'Saskia Vance',
                handle: '@sas_vance',
                timeAgo: '12m ago',
                frequencyTag: 'BAUHAUS_GRID_04',
                content: 'Spent the afternoon rendering custom vector grids in classic Bauhaus style. Really loving the warm aesthetic of burnt orange balanced against deep cool greens. Nostalgia is a solid design principle!',
                imageUrl: 'lib/assets/images/signal_artwork.png',
                likesCount: 342,
                commentsCount: 18,
                repostsCount: 47,
                onLikePressed: () {},
                onCommentPressed: () {},
                onRepostPressed: () {},
              ),
              const SizedBox(height: 16),
              PostCard(
                currentTheme: widget.currentTheme,
                name: 'Saskia Vance',
                handle: '@sas_vance',
                timeAgo: '45m ago',
                frequencyTag: 'RETRO_AUDIO_BBS',
                content: 'Who remembers the sound of a dial-up modem handshaking at 3 AM? That static hiss and beep sequence is basically the retro anthem of early cyberspace. Designing this social platform layout feels like stepping back into a cozy BBS.',
                imageUrl: null,
                likesCount: 128,
                commentsCount: 54,
                repostsCount: 12,
                onLikePressed: () {},
                onCommentPressed: () {},
                onRepostPressed: () {},
              ),
            ],
          ),
        ),
      ),
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