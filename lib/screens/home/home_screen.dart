import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

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

  double robotX = 140;
  double robotY = 80;

  int pageIndex = 0;
  final PageController _pageCtrl = PageController(viewportFraction: .85);

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(begin: 1.0, end: 1.15).animate(
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

        if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
          if (kIsWeb) {
            prefs.setHasSeenLocationPrompt(true);
            return;
          }
          final status = await Permission.locationWhenInUse.status;
          if (!status.isGranted) {
            _showPrivacyDialog();
          } else {
            prefs.setHasSeenLocationPrompt(true);
          }
        }
      }
    });

    _simTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        final r = Random();
        robotX = 100 + r.nextDouble() * 100;
        robotY = 60 + r.nextDouble() * 60;
        if (timer.tick % 15 == 0) visitedCount++;
        if (timer.tick % 15 == 0) durationMinutes += 5;
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
      useSafeArea: false,
      builder: (context) => LocationPermissionDialog(
        isHighContrast: prefs.isHighContrast,
        onAllow: () async {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
          await Permission.locationWhenInUse.request();
        },
        onDeny: () {
          Navigator.pop(context);
          prefs.setHasSeenLocationPrompt(true);
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandStyle = AppTextStyles.brandTitle(context, isDark: isDark);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                onPressed: () {
                  AppMenuShell.of(context)?.toggleMenu();
                },
              ),
              Row(
                children: [
                  Image.asset("assets/icons/ankh.png", width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(
                    "HORUS",
                    style: brandStyle.copyWith(color: AppColors.primaryGold),
                  ),
                  Text(
                    "-BOT",
                    style: brandStyle,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: isDark ? Colors.white : AppColors.darkInk, size: 28),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 520,
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.4),
                AppColors.cinematicBackground,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Image.asset(
            'assets/images/museum_interior.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exploreEgypt,
                style: AppTextStyles.heroTitle(context),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.followAndDiscover,
                style: AppTextStyles.heroSubtitle(context),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -40,
          child: _buildNextStopCard(context, l10n),
        ),
      ],
    );
  }

  Widget _buildNextStopCard(BuildContext context, AppLocalizations l10n) {
    return _NextStopBadge(
      label: l10n.nextStopLabel.toUpperCase(),
      location: l10n.tutankhamunHall,
      time: l10n.fiveMinutesAway,
      onTap: () => Navigator.pushNamed(context, AppRoutes.liveTour),
    );
  }

  Widget _buildSummaryStats(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          _RobotStatusCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.visited,
                  value: visitedCount.toString(),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l10n.exhibits,
                  value: exhibits.length.toString(),
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l10n.duration,
                  value: "$durationMinutes min",
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
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
      body: Builder(
        builder: (innerContext) => Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 1. Cinematic Hero Section
                SliverToBoxAdapter(
                  child: _buildHeroSection(innerContext, l10n),
                ),
                SliverToBoxAdapter(
                  child: _buildSummaryStats(innerContext, l10n),
                ),

                // 3. Quick Actions (Exhibits)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exhibits.toUpperCase(),
                          style: AppTextStyles.sectionTitle(innerContext),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _FeatureCard(
                                icon: Icons.map_outlined,
                                title: l10n.map,
                                onTap: () => Navigator.pushNamed(innerContext, AppRoutes.map),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _FeatureCard(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: l10n.talkToHorusBot,
                                isHighlighted: true,
                                onTap: () => Navigator.pushNamed(innerContext, AppRoutes.chat),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // 4. Discovery Carousel
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(l10n.recommendedForYou.toUpperCase(), style: AppTextStyles.sectionTitle(innerContext)),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 240,
                        child: PageView(
                          controller: _pageCtrl,
                          onPageChanged: (i) => setState(() => pageIndex = i),
                          children: [
                            _HighlightCard(
                              title: l10n.tutankhamunMask,
                              subtitle: l10n.goldenHallRecommended,
                              image: "assets/images/pharaoh_head.jpg",
                            ),
                            _HighlightCard(
                              title: l10n.ancientPapyrus,
                              subtitle: l10n.westWingStory,
                              image: "assets/images/hieroglyphs.jpg",
                            ),
                            _HighlightCard(
                              title: l10n.canopicJars,
                              subtitle: l10n.southHallMummification,
                              image: "assets/images/canopic_jars.jpg",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Dots(count: 3, index: pageIndex),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // 6. Map Preview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.mapPreview.toUpperCase(), style: AppTextStyles.sectionTitle(innerContext)),
                            _LiveBadge(label: l10n.live),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 260,
                            decoration: BoxDecoration(
                              color: AppColors.cinematicSection,
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Stack(
                              children: [
                                // Grid Background
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _GridPainter(gridColor: Colors.white.withOpacity(0.025)),
                                  ),
                                ),
                                // Map Content (Simplified)
                                Center(
                                  child: Opacity(
                                    opacity: 0.15,
                                    child: Icon(Icons.museum, size: 140, color: Colors.white),
                                  ),
                                ),
                                // Robot Marker
                                AnimatedPositioned(
                                  duration: const Duration(seconds: 4),
                                  curve: Curves.easeInOut,
                                  left: robotX,
                                  top: robotY,
                                  child: ScaleTransition(
                                    scale: _robotScale,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryGold.withOpacity(0.4),
                                            blurRadius: 15,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.smart_toy, color: AppColors.darkInk, size: 16),
                                    ),
                                  ),
                                ),
                                // Map Overlay Info
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Row(
                                    children: [
                                      _LegendDot(color: AppColors.primaryGold, label: l10n.horusBot),
                                      const SizedBox(width: 20),
                                      _LegendDot(color: Colors.blueAccent, label: l10n.you),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => Navigator.pushNamed(innerContext, AppRoutes.map),
                                        child: Text(l10n.fullView, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                // 7. Did You Know
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.cinematicSection,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              l10n.didYouKnow.toUpperCase(),
                              style: AppTextStyles.sectionTitle(innerContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.didYouKnowFact,
                          style: AppTextStyles.body(innerContext).copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            _buildTopBar(innerContext, l10n),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.statNumber(context),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.helper(context),
          ),
        ],
      ),
    );
  }
}

class _NextStopBadge extends StatelessWidget {
  final String label;
  final String location;
  final String time;
  final VoidCallback onTap;
  const _NextStopBadge({required this.label, required this.location, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cinematicElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.near_me_rounded, color: AppColors.primaryGold, size: 32),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.sectionTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: AppTextStyles.cardTitle(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neutralDark, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppColors.cinematicCard,
              border: Border.all(
                color: widget.isHighlighted
                    ? AppColors.primaryGold.withOpacity(0.3 + (_glowCtrl.value * 0.4))
                    : Colors.white.withOpacity(0.05),
                width: widget.isHighlighted ? 1.5 : 1.0,
              ),
              boxShadow: [
                if (widget.isHighlighted)
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.1 + (_glowCtrl.value * 0.15)),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(widget.icon, color: AppColors.primaryGold, size: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.cardTitle(context),
                      ),
                    ),
                    if (widget.isHighlighted)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Online",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
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
                    colors: [Colors.black.withOpacity(0.95), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: AppTextStyles.body(context).copyWith(color: Colors.white70),
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
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGold : AppColors.neutralDark.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.alertRed.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: AppColors.alertRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.alertRed, letterSpacing: 1.5),
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
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.neutralMedium)),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;
  _GridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RobotStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final isOnline = tourProvider.robotState != RobotState.disconnected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.primaryGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Horus-Bot Status", style: AppTextStyles.cardTitle(context)),
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? "Online • At Jewelry Gallery" : "Offline",
                  style: AppTextStyles.helper(context),
                ),
              ],
            ),
          ),
          const Icon(Icons.bolt_rounded, color: AppColors.primaryGold, size: 16),
        ],
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



class _HorusFabState extends State<_HorusFab> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _glowCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) {
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
                color: AppColors.cinematicElevated,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.6 + (_glowCtrl.value * 0.4)), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.15 + (_glowCtrl.value * 0.25)),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.onlineStatus.replaceAll('● ', ''),
                            style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
