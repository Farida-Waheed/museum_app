import 'dart:async';
import 'dart:math';
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
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
        ),
      ],
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: CustomScrollView(
        slivers: [
          // ===== HERO HEADER =====
          SliverToBoxAdapter(
            child: Container(
              height: 240,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
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
                                Colors.black.withOpacity(.55),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.exploreEgypt,
                            style: t.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // === NEXT STOP CARD ===
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.pushNamed(context, AppRoutes.progress),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.black.withOpacity(0.30),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.route, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.nextStop("Tutankhamun Hall", 5),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                                ],
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
                  // --- STATS ROW ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.map,
                          value: "${exhibits.length}",
                          label: l10n.exhibits,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.trending_up,
                          value: "$visitedCount",
                          label: l10n.visited,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer,
                          value: "${durationMinutes}m",
                          label: l10n.duration,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- TODAY'S HIGHLIGHTS ---
                  Text(
                    l10n.todaysHighlights,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 180,
                    child: PageView(
                      controller: _pageCtrl,
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      children: const [
                        _HighlightCard(
                          title: "Tutankhamun Mask", // TODO: These should be localized exhibit names
                          image: "assets/images/pharaoh_head.jpg",
                        ),
                        _HighlightCard(
                          title: "Golden Hieroglyphs",
                          image: "assets/images/hieroglyphs.jpg",
                        ),
                        _HighlightCard(
                          title: "Canopic Jars",
                          image: "assets/images/canopic_jars.jpg",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  _Dots(count: 3, index: pageIndex),
                  const SizedBox(height: 24),

                  // --- MAP PREVIEW CARD ---
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.mapPreview,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                                child: Text(l10n.fullView),
                              ),
                            ],
                          ),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildMiniMap(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _LegendDot(color: Colors.blue, label: l10n.horusBot),
                              _LegendDot(color: Colors.orange, label: l10n.you),
                              _LegendDot(color: Colors.redAccent, label: l10n.exhibit),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [color.withOpacity(.10), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
              child: const Icon(Icons.smart_toy, size: 24, color: Colors.blue),
            ),
          ],
        );
      },
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final String image;
  const _HighlightCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(.45), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: isArabic ? null : 14,
              right: isArabic ? 14 : null,
              bottom: 12,
              child: Text(
                title,
                style: t.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
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
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.secondary : cs.onSurface.withOpacity(.3),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
