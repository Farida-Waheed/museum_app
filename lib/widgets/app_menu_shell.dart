import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../models/auth_provider.dart';
import '../widgets/ask_the_guide_button.dart';

import '../models/user_preferences.dart';
import '../app/router.dart';

class _SideMenu extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onClose;
  final void Function(String route) onPush;
  final void Function(String route) onReplace;
  final String? currentRoute;

  const _SideMenu({
    required this.isArabic,
    required this.onClose,
    required this.onPush,
    required this.onReplace,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = (size.width * 0.78).clamp(280.0, 340.0).toDouble();
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? l10n.guestUser;
    final userSubtitle = authProvider.isLoggedIn
        ? authProvider.currentUser?.email ?? l10n.exploreTheMuseum
        : l10n.exploreTheMuseum;

    return Align(
      alignment: isArabic
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isArabic
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              end: isArabic
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              colors: [
                Colors.black.withValues(alpha: 0.90),
                Colors.black.withValues(alpha: 0.74),
                Colors.transparent,
              ],
              stops: const [0.0, 0.76, 1.0],
            ),
          ),
          child: SafeArea(
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 22),
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/ankh.png',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.appTitle.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.premiumBrandTitle(
                                context,
                              ).copyWith(color: AppColors.primaryGold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.secondaryGlass(0.82),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.primaryGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: AppTextStyles.premiumCardTitle(
                                    context,
                                  ).copyWith(fontSize: 18, color: Colors.white),
                                ),
                                Text(
                                  userSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.premiumMutedBody(
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.goldBorder(0.12),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    children: [
                      _SectionHeader(label: l10n.accountPreferences),
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: l10n.profile,
                        selected: currentRoute == AppRoutes.profile,
                        onTap: () => onReplace(AppRoutes.profile),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: l10n.settings,
                        selected:
                            currentRoute == AppRoutes.settings ||
                            currentRoute == AppRoutes.accessibility,
                        onTap: () => onReplace(AppRoutes.settings),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: l10n.notifications,
                        selected: currentRoute == AppRoutes.notificationSettings,
                        onTap: () => onReplace(AppRoutes.notificationSettings),
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader(label: l10n.extras),
                      _MenuItem(
                        icon: Icons.emoji_events_outlined,
                        label: l10n.achievements,
                        selected: currentRoute == AppRoutes.achievements,
                        onTap: () => onReplace(AppRoutes.achievements),
                      ),
                      _MenuItem(
                        icon: Icons.feedback_outlined,
                        label: l10n.feedback,
                        selected: currentRoute == AppRoutes.feedback,
                        onTap: () => onReplace(AppRoutes.feedback),
                      ),
                      _MenuItem(
                        icon: Icons.support_agent_outlined,
                        label: l10n.supportInboxTitle,
                        selected: currentRoute == AppRoutes.supportInbox,
                        onTap: () => onReplace(AppRoutes.supportInbox),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        label: l10n.about,
                        selected: currentRoute == AppRoutes.projectInfo,
                        onTap: () => onReplace(AppRoutes.projectInfo),
                      ),
                      _MenuItem(
                        icon: Icons.groups_2_outlined,
                        label: l10n.team,
                        selected: currentRoute == AppRoutes.team,
                        onTap: () => onReplace(AppRoutes.team),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 24, 12),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.premiumSectionLabel(context).copyWith(
          fontSize: 12,
          letterSpacing: 2.1,
          color: AppColors.softGold.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        visualDensity: const VisualDensity(vertical: -3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          size: 23,
          color: selected ? AppColors.primaryGold : AppColors.bodyText,
        ),
        title: Text(
          label,
          style: AppTextStyles.premiumBody(context).copyWith(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primaryGold : AppColors.bodyText,
          ),
        ),
        tileColor: selected
            ? AppColors.primaryGold.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
    );
  }
}

class AppMenuShell extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showChatButton;
  final Color? backgroundColor;
  final bool hideDefaultAppBar;
  final Widget? subHeader;
  final Widget? floatingActionButton;

  const AppMenuShell({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.showChatButton = false,
    this.backgroundColor,
    this.hideDefaultAppBar = false,
    this.subHeader,
    this.floatingActionButton,
  });

  static AppMenuShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppMenuShellState>();
  }

  @override
  State<AppMenuShell> createState() => AppMenuShellState();
}

class AppMenuShellState extends State<AppMenuShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (_isMenuOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  }

  void openMenu() {
    if (_isMenuOpen) return;
    _menuController.forward();
    setState(() {
      _isMenuOpen = true;
    });
  }

  void closeMenu() {
    if (!_isMenuOpen) return;
    _menuController.reverse();
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _goPush(String route) {
    closeMenu();
    Navigator.pushNamed(context, route);
  }

  void _goReplace(String route) {
    closeMenu();
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    final bgColor =
        widget.backgroundColor ??
        (isDark ? AppColors.darkBackground : Colors.white);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton:
          widget.floatingActionButton ??
          (widget.showChatButton ? const AskTheGuideButton() : null),
      body: AnimatedBuilder(
        animation: _menuController,
        builder: (context, _) {
          final v = _menuController.value;
          final blur = 10 * v;
          final menuWidth = (size.width * 0.78).clamp(280.0, 340.0).toDouble();
          final menuDx = (isArabic ? 1 : -1) * menuWidth * (1 - v);

          return Stack(
            children: [
              AbsorbPointer(
                absorbing: _isMenuOpen,
                child: Container(
                  color: bgColor,
                  child: Builder(
                    builder: (innerContext) {
                      return widget.hideDefaultAppBar
                          ? widget.body
                          : Scaffold(
                              backgroundColor: bgColor,
                              appBar: AppBar(
                                leading: IconButton(
                                  icon: Icon(
                                    Navigator.canPop(innerContext)
                                        ? (isArabic
                                              ? Icons.arrow_forward_ios
                                              : Icons.arrow_back_ios_new)
                                        : Icons.menu,
                                    size: Navigator.canPop(innerContext)
                                        ? 20
                                        : null,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.darkInk,
                                  ),
                                  onPressed: () {
                                    if (Navigator.canPop(innerContext)) {
                                      Navigator.pop(innerContext);
                                    } else {
                                      toggleMenu();
                                    }
                                  },
                                ),
                                title: Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/ankh.png',
                                      width: 26,
                                      height: 26,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        (widget.title ?? l10n.appTitle)
                                            .toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTextStyles.premiumBrandTitle(
                                              innerContext,
                                            ).copyWith(
                                              fontSize: 18,
                                              color: AppColors.primaryGold,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: widget.actions,
                                backgroundColor: isDark
                                    ? AppColors.darkHeader
                                    : AppColors.warmSurface,
                                elevation: 0,
                                bottom: widget.subHeader != null
                                    ? PreferredSize(
                                        preferredSize: const Size.fromHeight(
                                          48,
                                        ),
                                        child: widget.subHeader!,
                                      )
                                    : null,
                              ),
                              body: widget.body,
                            );
                    },
                  ),
                ),
              ),
              if (v > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: closeMenu,
                    onHorizontalDragUpdate: (details) {
                      if (isArabic) {
                        if (details.primaryDelta! > 10 && _isMenuOpen) {
                          closeMenu();
                        }
                      } else {
                        if (details.primaryDelta! < -10 && _isMenuOpen) {
                          closeMenu();
                        }
                      }
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.46 * v),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(menuDx, 0),
                child: _SideMenu(
                  isArabic: isArabic,
                  onClose: closeMenu,
                  onPush: _goPush,
                  onReplace: _goReplace,
                  currentRoute: currentRoute,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
