import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';

class ProfileCard extends StatelessWidget {
  final AppTheme currentTheme;
  final String name;
  final String handle;
  final String bio;
  final String? location;
  final String followingCount;
  final String followersCount;
  final String artifactsCount;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onMessagePressed;
  final bool isFollowing;
  final bool isLoadingFollow;
  final bool isOwner;

  const ProfileCard({
    super.key,
    required this.currentTheme,
    required this.name,
    required this.handle,
    required this.bio,
    this.location,
    required this.followingCount,
    required this.followersCount,
    required this.artifactsCount,
    this.onFollowPressed,
    this.onMessagePressed,
    this.isFollowing = false,
    this.isLoadingFollow = false,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final String displayLocation = (location != null && location!.isNotEmpty) ? location! : 'Penedo, Brasil';

    return Container(
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentTheme.shadowColor, width: 2),
        boxShadow: [
          BoxShadow(color: currentTheme.shadowColor, offset: const Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: currentTheme.secondaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: currentTheme.shadowColor, width: 2)),
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/signal_artwork.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -65,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: currentTheme.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: currentTheme.shadowColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: currentTheme.primaryColor,
                      child: Text(
                        'SV',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: currentTheme.backgroundColor),
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: currentTheme.textColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              handle,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: currentTheme.primaryColor),
                            ),
                          ],
                        ),
                        if (!isOwner)
                          Row(
                            children: [
                              _buildActionButton(
                                isFollowing ? 'FOLLOWING' : 'FOLLOW', 
                                isPrimary: !isFollowing, 
                                onTap: onFollowPressed,
                                isLoading: isLoadingFollow,
                              ),
                              const SizedBox(width: 10),
                              _buildActionButton('MESSAGE', isPrimary: false, onTap: onMessagePressed),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      bio,
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: currentTheme.textColor.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: currentTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          displayLocation,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: currentTheme.textColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        _buildStatItem(followingCount, 'Following'),
                        const SizedBox(width: 24),
                        _buildStatItem(followersCount, 'Followers'),
                        const SizedBox(width: 24),
                        _buildStatItem(artifactsCount, 'Artifacts'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, {required bool isPrimary, VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? currentTheme.primaryColor : currentTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: currentTheme.shadowColor, width: 2),
          boxShadow: [
            BoxShadow(color: currentTheme.shadowColor, offset: const Offset(2, 2), blurRadius: 0),
          ],
        ),
        child: isLoading 
            ? SizedBox(
                width: 14, 
                height: 14, 
                child: CircularProgressIndicator(
                  strokeWidth: 2, 
                  color: isPrimary ? currentTheme.backgroundColor : currentTheme.primaryColor
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? currentTheme.backgroundColor : currentTheme.textColor,
                ),
              ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: currentTheme.shadowColor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: currentTheme.textColor)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: currentTheme.textColor.withOpacity(0.6))),
        ],
      ),
    );
  }
}