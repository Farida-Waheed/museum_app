import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';

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
  final PageController _pageCtrl = PageController(viewportFraction: .85);

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(begin: 1.0, end: 1.08).animate(
    CurvedAnimation(parent: _robotPulseCtrl, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(Duration.zero, () {
      if (mounted) _showPrivacyDialog();
    });

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
    _robotPulseCtrl.dispose();
    super.dispose();
  }

  void _showPrivacyDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.privacyPermissions,
          style: theme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyText,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "• ${l10n.dataAnonymous}\n• ${l10n.analyticsNote}",
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.darkMutedText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.notNow,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.darkMutedText, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkInk,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.allow, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppMenuShell(
      hideDefaultAppBar: true,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: _HorusFab(onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), label: l10n.talkToHorusBot),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 64.0,
              toolbarHeight: 64.0,
              floating: false,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              backgroundColor: AppColors.darkHeader,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/icons/ankh.png", width: 24, height: 24),
                  const SizedBox(width: 16),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 0.5),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: () => AppMenuShell.of(context)?.openMenu(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ===== HERO HEADER =====
            SliverToBoxAdapter(
              child: Container(
                height: 260,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.4, 1.0],
                              colors: [
                                Colors.black.withOpacity(0.75),
                                Colors.black.withOpacity(0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        top: 48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Explore Egypt With Horus-Bot",
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Follow the robot and uncover the stories behind ancient artifacts.",
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: _NextStopBadge(
                          location: "Tutankhamun Hall",
                          time: "5 minutes away",
                          label: l10n.nextStopLabel,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.progress),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ===== FEATURE CARDS =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.museum_outlined,
                        title: l10n.exhibits,
                        subtitle: l10n.exhibitsSub,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FeatureCard(
                        icon: Icons.quiz_outlined,
                        title: l10n.quiz,
                        subtitle: l10n.quizSub,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.quiz),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ===== RECOMMENDED SECTION =====
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recommendedForYou,
                          style: theme.textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                          child: Text(
                            l10n.seeAll,
                            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
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
                  const SizedBox(height: 16),
                  _Dots(count: 3, index: pageIndex),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ===== MAP PREVIEW =====
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceSecondary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.mapPreview, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                l10n.robotHeadingTo("Tutankhamun Hall"),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          _LiveBadge(label: l10n.live),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: _buildMiniMap(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _LegendDot(color: Colors.blue, label: l10n.horusBot),
                          _LegendDot(color: Colors.orange, label: l10n.you),
                          _LegendDot(color: AppColors.alertRed, label: l10n.exhibit),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text("Full Map", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.darkInk,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text(l10n.followHorusBot, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
            Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
            ...exhibits.map((e) {
              double dx = (e.x / 400) * c.maxWidth;
              double dy = (e.y / 600) * c.maxHeight;
              return Positioned(
                left: dx.clamp(0, c.maxWidth - 5),
                top: dy.clamp(0, c.maxHeight - 5),
                child: const Icon(Icons.circle, size: 6, color: AppColors.alertRed),
              );
            }),
            Positioned(
              left: c.maxWidth * 0.5,
              top: c.maxHeight * 0.7,
              child: const Icon(Icons.circle, size: 8, color: Colors.orange),
            ),
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              left: (robotX / 400) * c.maxWidth,
              top: (robotY / 600) * c.maxHeight,
              child: ScaleTransition(
                scale: _robotScale,
                child: const Icon(Icons.smart_toy, size: 28, color: Colors.blue),
              ),
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
      ..color = Colors.white.withOpacity(0.05)
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

class _NextStopBadge extends StatelessWidget {
  final String label;
  final String location;
  final String time;
  final VoidCallback onTap;

  const _NextStopBadge({required this.label, required this.location, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1912).withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryGold, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.route, color: AppColors.primaryGold, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.darkSurface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 28),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.darkMutedText),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGold : const Color(0xFF555555),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String label;
  const _LiveBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.alertRed),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.alertRed, letterSpacing: 0.5),
          ),
        ],
      ),
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
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.darkMutedText)),
      ],
    );
  }
}

class _HorusFab extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _HorusFab({required this.label, required this.onPressed});
  @override
  State<_HorusFab> createState() => _HorusFabState();
}

class _HorusFabState extends State<_HorusFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2118),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primaryGold, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
