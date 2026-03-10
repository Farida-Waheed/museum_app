import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';

import '../models/user_preferences.dart';
import '../models/tour_provider.dart';
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
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final tourProvider = Provider.of<TourProvider>(context);
    final isTourActive = tourProvider.currentExhibitId != null;

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.warmSurface,
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
                          Image.asset("assets/icons/ankh.png", width: 32, height: 32),
                          const SizedBox(width: 12),
                          Text(
                            l10n.appTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: AppColors.darkInk,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.softSurface,
                            child: Icon(Icons.person, color: AppColors.primaryGold, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.guestUser,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkInk,
                                  ),
                                ),
                                Text(
                                  l10n.exploreTheMuseum,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isTourActive) ...[
                        const SizedBox(height: 16),
                        // Contextual Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_run, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                l10n.liveTourActive,
                                style: t.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),

                // --- MENU ITEMS ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _SectionHeader(title: l10n.visit),
                      _MenuItem(
                        icon: Icons.museum_outlined,
                        label: l10n.exhibits,
                        selected: currentRoute == AppRoutes.exhibits,
                        onTap: () => onPush(AppRoutes.exhibits),
                      ),
                      _MenuItem(
                        icon: Icons.quiz_outlined,
                        label: l10n.quiz,
                        selected: currentRoute == AppRoutes.quiz,
                        onTap: () => onPush(AppRoutes.quiz),
                      ),

                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.accountPreferences),
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: l10n.profile,
                        selected: currentRoute == AppRoutes.profile,
                        onTap: () => onReplace(AppRoutes.profile),
                      ),
                      _MenuItem(
                        icon: Icons.language,
                        label: l10n.language,
                        selected: currentRoute == AppRoutes.language,
                        onTap: () => onReplace(AppRoutes.language),
                      ),
                      _MenuItem(
                        icon: Icons.accessibility_new,
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

                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.extras),
                      _MenuItem(
                        icon: Icons.route_outlined,
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
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          size: 22,
          color: selected ? AppColors.primaryGold : AppColors.darkInk,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.primaryGold : AppColors.darkInk,
          ),
        ),
        tileColor: selected ? AppColors.primaryGold.withOpacity(0.08) : Colors.transparent,
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
  final Color backgroundColor;
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
    this.backgroundColor = Colors.white,
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
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void openMenu() {
    if (_isMenuOpen) return;
    _menuController.forward();
    setState(() => _isMenuOpen = true);
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;
    _menuController.reverse();
    setState(() => _isMenuOpen = false);
  }

  void _goPush(String route) {
    _closeMenu();
    Navigator.pushNamed(context, route);
  }

  void _goReplace(String route) {
    _closeMenu();
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton ?? (widget.showChatButton
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              label: Text(
                l10n.talkToHorusBot,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              backgroundColor: const Color(0xFF2A2118),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: AppColors.primaryGold, width: 1),
              ),
              elevation: 6,
            )
          : null),
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
              Container(color: widget.backgroundColor),

              // ✅ DIM / BLUR OVERLAY (Below Content Card)
              if (v > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeMenu,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        color: Colors.black.withOpacity(0.2 * v),
                      ),
                    ),
                  ),
                ),

              // ✅ MENU PANEL (Behind or alongside Content Card depending on layout)
              // Note: If we want the menu behind, it should be here.
              // If we want it on top (standard drawer), it should be after.
              // Original design had it behind with content shifting.
              _SideMenu(
                isArabic: isArabic,
                onClose: _closeMenu,
                onPush: _goPush,
                onReplace: _goReplace,
                currentRoute: currentRoute,
              ),

              // ✅ MAIN CONTENT CARD
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      child: widget.hideDefaultAppBar
                          ? widget.body
                          : Scaffold(
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                leading: IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.black),
                                  onPressed: toggleMenu,
                                ),
                                title: Row(
                                  children: [
                                    Image.asset("assets/icons/ankh.png", width: 26, height: 26),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.title ?? l10n.appTitle,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: widget.actions,
                                backgroundColor: Colors.white,
                                elevation: 0,
                                bottom: widget.subHeader != null
                                    ? PreferredSize(
                                        preferredSize: const Size.fromHeight(48),
                                        child: widget.subHeader!,
                                      )
                                    : null,
                              ),
                              body: widget.body,
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
