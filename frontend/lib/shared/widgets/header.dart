import 'package:flutter/material.dart';
import 'package:frontend/core/themes/app_themes.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/shared/components/hover_icon_button.dart';
import 'package:frontend/shared/components/global_search_modal.dart';
import 'package:frontend/shared/components/user_avatar.dart';
import 'package:frontend/shared/repositories/notification_repository.dart';

class HeaderWidget extends StatefulWidget implements PreferredSizeWidget {
  final AppTheme currentTheme;
  final Function(String route)? onNavigate;
  final VoidCallback? onRequireLogin;
  final VoidCallback? onNavigateToRegister;
  final String? avatarUrl;
  final String? userName;

  const HeaderWidget({
    super.key,
    required this.currentTheme,
    this.onNavigate,
    this.onRequireLogin,
    this.onNavigateToRegister,
    this.avatarUrl,
    this.userName,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final NotificationRepository _notificationRepository = NotificationRepository();
  final UserRepository _userRepository = UserRepositoryImpl();
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _unreadNotificationsCount = _notificationRepository.unreadCount;
    if (UserRepositoryImpl.isLoggedIn && UserRepositoryImpl.currentUserNodeId == null) {
      _userRepository.getMyProfile().catchError((_) => PerfilRespostaDto(
            id: '',
            nome: 'User',
            email: '',
            nodeId: '',
          ));
    }
  }

  void _handleSearchTap(BuildContext context, bool isLoggedIn) {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para pesquisar perfis e transmissões.')),
      );
      widget.onRequireLogin?.call();
      return;
    }
    GlobalSearchModal.show(context, widget.currentTheme);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: UserRepositoryImpl.isLoggedInNotifier,
      builder: (context, isLoggedIn, _) {
        final bool autenticado = isLoggedIn || UserRepositoryImpl.isLoggedIn;

        return Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          decoration: BoxDecoration(
            color: widget.currentTheme.backgroundColor,
            border: Border(
              bottom: BorderSide(color: widget.currentTheme.shadowColor, width: 2.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.currentTheme.primaryColor,
                      border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: widget.currentTheme.shadowColor,
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(Icons.waves, color: widget.currentTheme.backgroundColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Telegrama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: widget.currentTheme.textColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _handleSearchTap(context, autenticado),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox(
                    width: 400,
                    height: 40,
                    child: TextField(
                      readOnly: true,
                      onTap: () => _handleSearchTap(context, autenticado),
                      style: TextStyle(color: widget.currentTheme.textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search channels, radio stations, waves...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: widget.currentTheme.textColor.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(Icons.search, color: widget.currentTheme.textColor, size: 20),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.backgroundColor,
                            border: Border.all(color: widget.currentTheme.shadowColor, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⌘K',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.currentTheme.textColor,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: widget.currentTheme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.currentTheme.shadowColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: widget.currentTheme.primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (autenticado)
                Row(
                  children: [
                    HoverIconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: widget.currentTheme.shadowColor,
                        size: 20,
                      ),
                      hasNotification: _unreadNotificationsCount > 0,
                      notificationCount: _unreadNotificationsCount > 0 ? _unreadNotificationsCount : null,
                      primaryColor: widget.currentTheme.primaryColor,
                      shadowColor: widget.currentTheme.shadowColor,
                      backgroundColor: widget.currentTheme.backgroundColor,
                      destinationRoute: 'Notifications',
                      onNavigate: widget.onNavigate,
                    ),
                    const SizedBox(width: 12),
                    HoverIconButton(
                      icon: Icon(
                        Icons.mail_outline,
                        color: widget.currentTheme.shadowColor,
                        size: 20,
                      ),
                      primaryColor: widget.currentTheme.primaryColor,
                      shadowColor: widget.currentTheme.shadowColor,
                      backgroundColor: widget.currentTheme.backgroundColor,
                      destinationRoute: 'Wave Chats',
                      onNavigate: widget.onNavigate,
                    ),
                    const SizedBox(width: 12),
                    HoverIconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: widget.currentTheme.shadowColor,
                        size: 20,
                      ),
                      primaryColor: widget.currentTheme.primaryColor,
                      shadowColor: widget.currentTheme.shadowColor,
                      backgroundColor: widget.currentTheme.backgroundColor,
                      destinationRoute: 'Settings',
                      onNavigate: widget.onNavigate,
                    ),
                    const SizedBox(width: 16),
                    ValueListenableBuilder<String>(
                      valueListenable: UserRepositoryImpl.currentAvatarNotifier,
                      builder: (context, currentAvatar, _) {
                        final effectiveAvatar = (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                            ? widget.avatarUrl!
                            : currentAvatar;
                        final effectiveName = (widget.userName != null && widget.userName!.isNotEmpty)
                            ? widget.userName!
                            : UserRepositoryImpl.currentUserNameNotifier.value;

                        return GestureDetector(
                          onTap: () => widget.onNavigate?.call('My Profile'),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: UserAvatar(
                              imageUrl: effectiveAvatar,
                              name: effectiveName,
                              radius: 20,
                              borderColor: widget.currentTheme.shadowColor,
                              borderWidth: 2,
                              backgroundColor: widget.currentTheme.secondaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onRequireLogin,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.currentTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: widget.currentTheme.shadowColor,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'ENTRAR',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: widget.currentTheme.backgroundColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.onNavigateToRegister != null) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.onNavigateToRegister,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.currentTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: widget.currentTheme.shadowColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.currentTheme.shadowColor,
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              'CRIAR CONTA',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: widget.currentTheme.textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
