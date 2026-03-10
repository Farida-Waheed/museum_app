import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Exhibit> exhibits;
  int visitedCount = 0;
  int durationMinutes = 0;
  Timer? _simTimer;

  double robotX = 100;
  double robotY = 100;

  int pageIndex = 0;
  final PageController _pageCtrl = PageController(viewportFraction: .9);

  late final AnimationController _grad = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();

    exhibits = MockDataService.getAllExhibits();

    // Privacy dialog
    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

    // Simple simulation: robot + stats move over time
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      setState(() {
        robotX = (robotX + 20) % 300;
        robotY = (robotY + 10) % 200;

        if (timer.tick % 20 == 0) visitedCount++;
        if (timer.tick % 20 == 0) durationMinutes++;
      });
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _pageCtrl.dispose();
    _grad.dispose();
    super.dispose();
  }

  void _showPrivacyDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacyPermissions),
        content: Text(l10n.privacyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.deny),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.allow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return AppMenuShell(
      hideDefaultAppBar: true, // Tell AppMenuShell to hide its AppBar
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(l10n.talkToHorusBot),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 80.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.9),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    centerTitle: true,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: innerBoxIsScrolled ? 0 : 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/ankh.png", width: 24, height: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.appTitle,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  // This is tricky because the menu is controlled by AppMenuShell
                  // We'll need to use a key or a provider to open the menu.
                  // For now, let's assume AppMenuShell provides a way or we can trigger it.
                  // Actually, AppMenuShell should ideally expose a toggle function.
                  // Since I'm editing both, I'll make sure they work together.
                  AppMenuShell.of(context)?.openMenu();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            // ===== HERO HEADER =====
            SliverToBoxAdapter(
              child: Container(
                height: 240,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),

                      // Animated gradient wash
                      AnimatedBuilder(
                        animation: _grad,
                        builder: (_, __) {
                          final gv = _grad.value;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                transform: GradientRotation(pi * (.05 + .15 * gv)),
                                colors: [
                                  cs.secondary.withOpacity(.12 + .10 * gv),
                                  cs.primary.withOpacity(.14 - .06 * gv),
                                  cs.tertiary.withOpacity(.10 + .06 * gv),
                                  Colors.black.withOpacity(.65),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exploreTheMuseum,
                              style: t.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.followAndDiscover,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // === NEXT STOP CARD ===
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: InkWell(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.progress),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.route, color: Colors.white, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.nextStopLabel,
                                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                l10n.nextStop("Tutankhamun Hall", 5),
                                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
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
                ),
              ),
            ),

            // ===== BODY CONTENT =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FEATURE CARDS ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _FeatureCard(
                          icon: Icons.map_outlined,
                          title: l10n.map,
                          subtitle: l10n.mapSub,
                          color: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.map),
                        ),
                        _FeatureCard(
                          icon: Icons.museum_outlined,
                          title: l10n.exhibits,
                          subtitle: l10n.exhibitsSub,
                          color: Colors.orange,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                        ),
                        _FeatureCard(
                          icon: Icons.quiz_outlined,
                          title: l10n.quiz,
                          subtitle: l10n.quizSub,
                          color: Colors.purple,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
                        ),
                        _FeatureCard(
                          icon: Icons.radio_button_checked,
                          title: l10n.liveTour,
                          subtitle: l10n.liveTourSub,
                          color: Colors.redAccent,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- RECOMMENDED FOR YOU ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recommendedForYou,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                          child: Text(l10n.fullView),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 220,
                      child: PageView(
                        controller: _pageCtrl,
                        onPageChanged: (i) => setState(() => pageIndex = i),
                        children: const [
                          _HighlightCard(
                            title: "Tutankhamun Mask",
                            subtitle: "Golden Hall • Recommended now",
                            image: "assets/images/pharaoh_head.jpg",
                          ),
                          _HighlightCard(
                            title: "Golden Hieroglyphs",
                            subtitle: "Gallery 3 • New Kingdom",
                            image: "assets/images/hieroglyphs.jpg",
                          ),
                          _HighlightCard(
                            title: "Canopic Jars",
                            subtitle: "West Wing • Ritual Artifacts",
                            image: "assets/images/canopic_jars.jpg",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _Dots(count: 3, index: pageIndex),
                    const SizedBox(height: 32),

                    // --- MAP PREVIEW CARD ---
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.mapPreview,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.robotHeadingTo("Tutankhamun Hall"),
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Text(l10n.live, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: _buildMiniMap(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _LegendDot(color: Colors.blue, label: l10n.horusBot),
                                _LegendDot(color: Colors.orange, label: l10n.you),
                                _LegendDot(color: Colors.redAccent, label: l10n.exhibit),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: Text(l10n.fullView),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.primary,
                                      foregroundColor: cs.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      elevation: 0,
                                    ),
                                    child: Text(l10n.followHorusBot),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // Spacing for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            // Simple grid/floor plan background
            Positioned.fill(
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),
            ...exhibits.map((e) {
              double dx = (e.x / 400) * c.maxWidth;
              double dy = (e.y / 600) * c.maxHeight;

              return Positioned(
                left: dx.clamp(0, c.maxWidth - 5),
                top: dy.clamp(0, c.maxHeight - 5),
                child: const Icon(Icons.circle, size: 8, color: Colors.redAccent),
              );
            }),
            Positioned(
              left: c.maxWidth * 0.5,
              top: c.maxHeight * 0.7,
              child: const Icon(Icons.circle, size: 10, color: Colors.orange),
            ),
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: (robotX / 400) * c.maxWidth,
              top: (robotY / 600) * c.maxHeight,
              child: const Icon(Icons.smart_toy, size: 28, color: Colors.blue),
            ),
          ],
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  const _HighlightCard({required this.title, required this.subtitle, required this.image});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.3),
                      Colors.transparent
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: isArabic ? null : 20,
              right: isArabic ? 20 : null,
              bottom: 20,
              child: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.onSurface.withOpacity(.2),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
