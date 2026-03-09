import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../models/user_preferences.dart';
import '../app/router.dart';

class _SideMenu extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onClose;
  final void Function(String route) onPush;
  final void Function(String route) onReplace;

  const _SideMenu({
    required this.isArabic,
    required this.onClose,
    required this.onPush,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width * 0.70;
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF3F6FB)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment:
                    isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset("assets/icons/ankh.png", width: 90, height: 90),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      const CircleAvatar(radius: 22, child: Text("G")),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(l10n.guestUser,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(l10n.exploreMuseum,
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => onReplace('/profile'),
                        child: Text(l10n.profile),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _MenuItem(icon: Icons.map_rounded, label: l10n.map, onTap: () => onPush(AppRoutes.map)),
                        _MenuItem(icon: Icons.museum_outlined, label: l10n.exhibits, onTap: () => onPush(AppRoutes.search)),
                        _MenuItem(icon: Icons.quiz_outlined, label: l10n.quiz, onTap: () => onPush(AppRoutes.quiz)),
                        _MenuItem(icon: Icons.radio_button_checked, label: l10n.liveTour, onTap: () => onPush(AppRoutes.liveTour)),

                        const Divider(),

                        _MenuItem(icon: Icons.person_outline, label: l10n.profile, onTap: () => onReplace('/profile')),
                        _MenuItem(icon: Icons.route_outlined, label: l10n.tourPlanner, onTap: () => onReplace('/tour-planner')),
                        _MenuItem(icon: Icons.event_outlined, label: l10n.events, onTap: () => onReplace('/events')),
                        _MenuItem(icon: Icons.emoji_events_outlined, label: l10n.achievements, onTap: () => onReplace('/achievements')),

                        const Divider(),

                        _MenuItem(icon: Icons.language, label: l10n.language, onTap: () => onReplace('/language')),
                        _MenuItem(icon: Icons.accessibility_new, label: l10n.accessibility, onTap: () => onReplace('/accessibility')),
                        _MenuItem(icon: Icons.feedback_outlined, label: l10n.feedback, onTap: () => onReplace('/feedback')),
                        _MenuItem(icon: Icons.settings_outlined, label: l10n.settings, onTap: () => onReplace('/settings')),
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

class AppMenuShell extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;

  const AppMenuShell({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor = Colors.white,
  });

  @override
  State<AppMenuShell> createState() => _AppMenuShellState();
}

class _AppMenuShellState extends State<AppMenuShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
    setState(() => _isMenuOpen = !_isMenuOpen);
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

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      body: AnimatedBuilder(
        animation: _menuController,
        builder: (context, _) {
          final v = _menuController.value;
          final scale = 1 - 0.18 * v;
          final radius = 32 * v;
          final dx = (isArabic ? -1 : 1) * size.width * 0.62 * v;

          return Stack(
            children: [
              Container(color: widget.backgroundColor),

              // ✅ MENU PANEL
              _SideMenu(
                isArabic: isArabic,
                onClose: _closeMenu,
                onPush: _goPush,
                onReplace: _goReplace,
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
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.22),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: Scaffold(
                        backgroundColor: Colors.white,
                        appBar: AppBar(
                          leading: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black),
                            onPressed: _toggleMenu,
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
                                ),
                              ),
                            ],
                          ),
                          actions: widget.actions,
                          backgroundColor: Colors.white,
                          elevation: 0,
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
