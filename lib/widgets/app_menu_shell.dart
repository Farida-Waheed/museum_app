import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_preferences.dart';
import '../app/router.dart';
import '../core/constants/strings.dart';

class AppMenuShell extends StatefulWidget {
  final Widget body;
  final String titleEn;
  final String titleAr;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;

  const AppMenuShell({
    super.key,
    required this.body,
    this.titleEn = "Horus-Bot",
    this.titleAr = "حوروس",
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

              // ✅ MENU PANEL (shared)
              Transform.translate(
                offset: Offset(-(size.width * 0.30 * (1 - v)), 0),
                child: _SideMenu(
                  isArabic: isArabic,
                  onClose: _closeMenu,
                  onPush: _goPush,
                  onReplace: _goReplace,
                ),
              ),

              // ✅ MAIN CONTENT CARD (shared)
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
                                isArabic ? widget.titleAr : widget.titleEn,
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

// ✅ ONE SOURCE OF TRUTH MENU
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

    String t({required String en, required String ar}) => isArabic ? ar : en;

    return Align(
      alignment: Alignment.centerLeft,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t(en: "Guest User", ar: "زائر"),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(t(en: "Explore the museum", ar: "استكشف المتحف"),
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => onReplace('/profile'),
                        child: Text(t(en: "Profile", ar: "الملف الشخصي")),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _MenuItem(icon: Icons.map_rounded, label: isArabic ? "الخريطة" : "Map", onTap: () => onPush(AppRoutes.map)),
                        _MenuItem(icon: Icons.museum_outlined, label: isArabic ? "المعارض" : "Exhibits", onTap: () => onPush(AppRoutes.search)),
                        _MenuItem(icon: Icons.quiz_outlined, label: isArabic ? "الاختبار" : "Quiz", onTap: () => onPush(AppRoutes.quiz)),
                        _MenuItem(icon: Icons.radio_button_checked, label: isArabic ? "جولة حية" : "Live Tour", onTap: () => onPush(AppRoutes.liveTour)),

                        const Divider(),

                        _MenuItem(icon: Icons.person_outline, label: AppStrings.profile, onTap: () => onReplace('/profile')),
                        _MenuItem(icon: Icons.route_outlined, label: AppStrings.tourPlanner, onTap: () => onReplace('/tour-planner')),
                        _MenuItem(icon: Icons.event_outlined, label: AppStrings.events, onTap: () => onReplace('/events')),
                        _MenuItem(icon: Icons.emoji_events_outlined, label: AppStrings.achievements, onTap: () => onReplace('/achievements')),

                        const Divider(),

                        _MenuItem(icon: Icons.language, label: AppStrings.language, onTap: () => onReplace('/language')),
                        _MenuItem(icon: Icons.accessibility_new, label: AppStrings.accessibility, onTap: () => onReplace('/accessibility')),
                        _MenuItem(icon: Icons.feedback_outlined, label: AppStrings.feedback, onTap: () => onReplace('/feedback')),
                        _MenuItem(icon: Icons.settings_outlined, label: AppStrings.settings, onTap: () => onReplace('/settings')),
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
