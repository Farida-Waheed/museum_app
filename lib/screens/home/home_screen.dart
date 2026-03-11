import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';

import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
import '../../app/router.dart';
import 'package:provider/provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/dialogs/location_permission_dialog.dart';
import '../../models/user_preferences.dart';
import '../../models/tour_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late List<Exhibit> exhibits;
  late List<MockNews> news;
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

  late final AnimationController _fabPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final Animation<double> _fabScale = Tween<double>(begin: 1.0, end: 1.05).animate(
    CurvedAnimation(parent: _fabPulseCtrl, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    exhibits = MockDataService.getAllExhibits();
    news = MockDataService.getAllNews();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

        // Only trigger if onboarding is done and dialog hasn't been seen this install
        if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
          // Check if system permission is already granted
          final status = await Permission.locationWhenInUse.status;
          if (!status.isGranted) {
            _showPrivacyDialog();
          } else {
            // Already granted, mark as seen so we don't check again
            prefs.setHasSeenLocationPrompt(true);
          }
        }
      }
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
    _fabPulseCtrl.dispose();
    super.dispose();
  }

  void _showPrivacyDialog() {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false, // Allow dialog to handle its own overlay
      builder: (context) => LocationPermissionDialog(
        isHighContrast: prefs.isHighContrast,
        onAllow: () async {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
          // Trigger real system permission request
          await Permission.locationWhenInUse.request();
        },
        onDeny: () {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: _HorusFab(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
          label: l10n.talkToHorusBot,
        ),
      ),
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
              backgroundColor: isDark ? AppColors.darkHeader : AppColors.warmSurface,
              shape: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : const Color(0xFFE5E0D5), width: 1)),
              title: Image.asset("assets/icons/ankh.png", width: 32, height: 32),
              leading: IconButton(
                padding: const EdgeInsets.all(16),
                icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                onPressed: () => AppMenuShell.of(context)?.openMenu(),
              ),
              actions: [
                IconButton(
                  padding: const EdgeInsets.all(16),
                  icon: Icon(Icons.qr_code_scanner, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
                ),
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
                height: 320,
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
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Explore Egypt with Horus-Bot",
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Follow Horus-Bot and discover ancient Egypt.",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: _NextStopBadge(
                          location: "Tutankhamun Hall",
                          time: "in 5 minutes",
                          label: l10n.nextStopLabel,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ===== ROBOT STATUS CARD =====
            SliverToBoxAdapter(
              child: _RobotStatusCard(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ===== TOUR PROGRESS TRACKER =====
            SliverToBoxAdapter(
              child: _TourProgressTracker(),
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

            // ===== MUSEUM NEWS =====
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Museum News",
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...news.map((item) => _NewsCard(news: item)),
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
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1912).withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
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
                const Icon(Icons.location_on, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$label: $location $time",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
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

class _RobotStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final isOnline = tourProvider.robotState != RobotState.disconnected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.primaryGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Horus-Bot Status", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? "Online • At Ancient Jewelry Gallery" : "Offline",
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text("Next Tour", style: TextStyle(color: AppColors.helperText, fontSize: 11)),
              Text("2:00 PM", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourProgressTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Tour Progress", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("3 / 10 exhibits", style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final MockNews news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(news.image, height: 120, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(news.source, style: const TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Nov 24", style: const TextStyle(color: AppColors.helperText, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(news.title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    news.description,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
