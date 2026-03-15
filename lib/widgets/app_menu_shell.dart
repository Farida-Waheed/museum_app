import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

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
    final width = size.width * 0.75;
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkHeader : AppColors.warmSurface,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/ankh.png",
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l10n.appTitle.toUpperCase(),
                            style: AppTextStyles.brandTitle(context, isDark: isDark).copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceSecondary
                                : AppColors.softSurface,
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.primaryGold,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.guestUser,
                                  style: AppTextStyles.cardTitle(context).copyWith(
                                    fontSize: 18,
                                    color: isDark ? Colors.white : AppColors.darkInk,
                                  ),
                                ),
                                Text(
                                  l10n.exploreTheMuseum,
                                  style: AppTextStyles.body(context),
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
                  color: isDark
                      ? AppColors.darkDivider
                      : const Color(0xFFF5F5F5),
                ),

                // --- MENU ITEMS ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _SectionHeader(label: l10n.visit),
                      _MenuItem(
                        icon: Icons.home_outlined,
                        label: l10n.home,
                        selected: currentRoute == AppRoutes.mainHome,
                        onTap: () => onReplace(AppRoutes.mainHome),
                      ),
                      _MenuItem(
                        icon: Icons.auto_awesome_mosaic_outlined,
                        label: l10n.exhibits,
                        selected: currentRoute == AppRoutes.exhibits,
                        onTap: () => onReplace(AppRoutes.exhibits),
                      ),
                      _MenuItem(
                        icon: Icons.quiz_outlined,
                        label: l10n.quiz,
                        selected: currentRoute == AppRoutes.quiz,
                        onTap: () => onReplace(AppRoutes.quiz),
                      ),

                      const SizedBox(height: 16),
                      _SectionHeader(label: l10n.accountPreferences),
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: l10n.profile,
                        selected: currentRoute == AppRoutes.profile,
                        onTap: () => onReplace(AppRoutes.profile),
                      ),
                      _MenuItem(
                        icon: Icons.language_outlined,
                        label: l10n.language,
                        selected: currentRoute == AppRoutes.language,
                        onTap: () => onReplace(AppRoutes.language),
                      ),
                      _MenuItem(
                        icon: Icons.accessibility_outlined,
                        label: l10n.accessibility,
                        selected: currentRoute == AppRoutes.accessibility,
                        onTap: () => onReplace(AppRoutes.accessibility),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: l10n.settings,
                        selected: currentRoute == AppRoutes.settings,
                        onTap: () => onReplace(AppRoutes.settings),
                      ),

                      const SizedBox(height: 16),
                      _SectionHeader(label: l10n.extras),
                      _MenuItem(
                        icon: Icons.event_note_outlined,
                        label: l10n.tourPlanner,
                        selected: currentRoute == AppRoutes.tourPlanner,
                        onTap: () => onReplace(AppRoutes.tourPlanner),
                      ),
                      _MenuItem(
                        icon: Icons.event_outlined,
                        label: l10n.events,
                        selected: currentRoute == AppRoutes.events,
                        onTap: () => onReplace(AppRoutes.events),
                      ),
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
                        icon: Icons.info_outline,
                        label: l10n.about,
                        selected: currentRoute == AppRoutes.projectInfo,
                        onTap: () => onReplace(AppRoutes.projectInfo),
                      ),
                    ],
                  ),
                ),
              ],
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
      padding: const EdgeInsets.fromLTRB(28, 24, 24, 12),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.sectionTitle(context).copyWith(
          fontSize: 11,
          letterSpacing: 1.5,
          color: AppColors.primaryGold.withOpacity(0.7),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          size: 22,
          color: selected
              ? AppColors.primaryGold
              : (isDark ? Colors.white : AppColors.darkInk),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? AppColors.primaryGold
                : (isDark ? Colors.white : AppColors.darkInk),
          ),
        ),
        tileColor: selected
            ? AppColors.primaryGold.withOpacity(0.08)
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
    if (route == AppRoutes.mainHome) {
      Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
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
      floatingActionButton: widget.floatingActionButton,
      body: AnimatedBuilder(
        animation: _menuController,
        builder: (context, _) {
          final v = _menuController.value;
          final scale = 1 - 0.1 * v;
          final radius = 24 * v;
          final dx = (isArabic ? -1 : 1) * size.width * 0.7 * v;
          final blur = 10 * v;

          return Stack(
            children: [
              Container(color: bgColor),

              if (v > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: closeMenu,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        color: Colors.black.withOpacity(0.2 * v),
                      ),
                    ),
                  ),
                ),

              _SideMenu(
                isArabic: isArabic,
                onClose: closeMenu,
                onPush: _goPush,
                onReplace: _goReplace,
                currentRoute: currentRoute,
              ),

              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: scale,
                  child: GestureDetector(
                    onTap: _isMenuOpen ? closeMenu : null,
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
                    child: AbsorbPointer(
                      absorbing: _isMenuOpen,
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(radius),
                          boxShadow: [
                            if (v > 0)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
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
                                                ? Icons.arrow_back_ios_new
                                                : Icons.menu,
                                            size: Navigator.canPop(innerContext)
                                                ? 20
                                                : null,
                                          ),
                                          onPressed: () {
                                            if (Navigator.canPop(
                                              innerContext,
                                            )) {
                                              Navigator.pop(innerContext);
                                            } else {
                                              toggleMenu();
                                            }
                                          },
                                        ),
                                        title: Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/ankh.png",
                                              width: 26,
                                              height: 26,
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              widget.title ?? l10n.appTitle,
                                              style: AppTextStyles.brandTitle(
                                                innerContext,
                                                isDark: isDark,
                                              ).copyWith(fontSize: 18),
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
                                                preferredSize:
                                                    const Size.fromHeight(48),
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
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
