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
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../models/user_preferences.dart';
import '../../models/tour_provider.dart';
import '../chat/chat_screen.dart';

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
  Timer? _factTimer;
  int _factIndex = 0;

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

    _factTimer = Timer.periodic(const Duration(seconds: 9), (timer) {
      if (mounted) {
        setState(() {
          _factIndex = (_factIndex + 1) % 4;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (mounted) {
        final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
        if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
          _requestInitialPermissions(context);
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
    _factTimer?.cancel();
    _pageCtrl.dispose();
    _robotPulseCtrl.dispose();
    _fabPulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions(BuildContext context) async {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (kIsWeb) {
      prefs.setHasSeenLocationPrompt(true);
      return;
    }

    // Contextual Notification Prompt on Home load
    final notifStatus = await Permission.notification.status;
    if (!notifStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.notifications_none_rounded,
          title: l10n.notificationPermissionTitle,
          description: l10n.notificationPermissionDesc,
          isHighContrast: prefs.isHighContrast,
          onAllow: () async {
            Navigator.pop(context);
            await Permission.notification.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    }

    // Contextual Location Prompt on Home load (for robot sync/nearby exhibits)
    final locStatus = await Permission.locationWhenInUse.status;
    if (!locStatus.isGranted && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.location_on_outlined,
          title: l10n.locationPermissionTitle,
          description: l10n.locationPermissionDesc,
          helperText: l10n.dataReassurance,
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
    } else {
      prefs.setHasSeenLocationPrompt(true);
    }
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

  Widget _buildSliverHeader(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandStyle = AppTextStyles.brandTitle(context, isDark: isDark);

    return SliverAppBar(
      expandedHeight: 520,
      pinned: true,
      backgroundColor: AppColors.cinematicNav,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () => AppMenuShell.of(context)?.toggleMenu(),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/ankh.png", width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            "HORUS",
            style: brandStyle.copyWith(color: AppColors.primaryGold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScan),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/museum_interior.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
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
                    l10n.exploreTheMuseum,
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
          ],
        ),
      ),
    );
  }

  Widget _buildNextStopCard(BuildContext context, AppLocalizations l10n) {
    return _NextStopBadge(
      label: l10n.nextStopLabel.toUpperCase(),
      location: l10n.tutankhamunHall,
      time: l10n.fiveMinutesAway,
      onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.liveTour, (r) => false),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final facts = [
      l10n.didYouKnowFact1,
      l10n.didYouKnowFact2,
      l10n.didYouKnowFact3,
      l10n.didYouKnowFact4,
    ];

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: Builder(
        builder: (innerContext) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Cinematic Header with Parallax Hero
            _buildSliverHeader(innerContext, l10n),

            // 2. Main Dashboard Content
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    right: 20,
                    child: _buildNextStopCard(innerContext, l10n),
                  ),
                  _buildSummaryStats(innerContext, l10n),
                ],
              ),
            ),

            // 3. Quick Actions
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
                            onTap: () => Navigator.pushNamedAndRemoveUntil(innerContext, AppRoutes.map, (r) => false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.play_circle_outline_rounded,
                            title: l10n.liveTour,
                            isHighlighted: true,
                            onTap: () => Navigator.pushNamedAndRemoveUntil(innerContext, AppRoutes.liveTour, (r) => false),
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
                    child: PageView.builder(
                      controller: _pageCtrl,
                      itemCount: exhibits.take(3).length,
                      onPageChanged: (i) => setState(() => pageIndex = i),
                      itemBuilder: (context, index) {
                        final e = exhibits[index];
                        return _HighlightCard(
                          title: e.getName(Localizations.localeOf(context).languageCode),
                          subtitle: l10n.goldenHallRecommended,
                          image: e.imageAsset,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: e),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Dots(count: 3, index: pageIndex),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 5. AI Assistant Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _HorusFab(
                  onPressed: () => showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    builder: (_) => const ChatScreen(isPopup: true),
                  ),
                  label: l10n.askTheGuide,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

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
                                child: const Icon(Icons.museum, size: 140, color: Colors.white),
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
                                    onPressed: () => Navigator.pushNamedAndRemoveUntil(innerContext, AppRoutes.map, (r) => false),
                                    child: Text(l10n.fullView, style: AppTextStyles.button(context).copyWith(color: AppColors.primaryGold, fontSize: 13)),
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

            // 7. Museum News
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(l10n.museumNews.toUpperCase(), style: AppTextStyles.sectionTitle(innerContext)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final item = news[index];
                        return _FeatureCard(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.events),
                          child: Container(
                            width: 300,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.source.toUpperCase(),
                                    style: const TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.title,
                                  style: AppTextStyles.cardTitle(context),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      "Read More",
                                      style: AppTextStyles.button(context).copyWith(color: AppColors.primaryGold, fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward, color: AppColors.primaryGold, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 8. Did You Know
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        facts[_factIndex],
                        key: ValueKey<int>(_factIndex),
                        style: AppTextStyles.body(innerContext).copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.7,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.55),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
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
  final IconData? icon;
  final String? title;
  final VoidCallback onTap;
  final bool isHighlighted;
  final Widget? child;

  const _FeatureCard({
    this.icon,
    this.title,
    required this.onTap,
    this.isHighlighted = false,
    this.child,
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
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
              child: widget.child ?? Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(widget.icon, color: AppColors.primaryGold, size: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title ?? "",
                            style: AppTextStyles.cardTitle(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
  final VoidCallback onTap;
  const _HighlightCard({required this.title, required this.subtitle, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
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
            style: AppTextStyles.sectionTitle(context).copyWith(fontSize: 11, color: AppColors.alertRed, letterSpacing: 1.5),
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
        Text(label, style: AppTextStyles.body(context).copyWith(fontSize: 13)),
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
    final l10n = AppLocalizations.of(context)!;

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
                    Text(l10n.guideStatus, style: AppTextStyles.cardTitle(context)),
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.alwaysAvailable,
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
    final l10n = AppLocalizations.of(context)!;
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
                        l10n.askTheGuide,
                        style: AppTextStyles.button(context).copyWith(color: Colors.white, fontSize: 14),
                      ),
                      Row(
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            l10n.alwaysAvailable,
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
