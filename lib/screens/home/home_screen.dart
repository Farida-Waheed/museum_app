import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../models/tour_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../models/app_session_provider.dart' as session;
import '../../screens/tickets/qr_scanner_screen.dart';

const Color kBgBlack = Color(0xFF0A0A0A);
const Color kWarmBlack = Color(0xFF11100E);
const Color kCardDark = Color(0xFF1C1C1C);
const Color kCardGlass = Color(0xB31F1F1F);
const Color kGold = Color(0xFFC9A85A);
const Color kSoftGold = Color(0xFFE6C97A);
const Color kBronze = Color(0xFF8A6A2F);
const Color kTextWhite = Color(0xFFF5F1E8);
const Color kTextMuted = Color(0xFFB8B0A2);
const Color kTextDim = Color(0xFF7D766B);

Widget _buildGlassCard({required Widget child, double radius = 24}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: kCardGlass,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: kGold.withOpacity(0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: kGold.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final List<Exhibit> exhibits;
  late final ScrollController _scrollController;

  late final AnimationController _robotPulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _robotScale = Tween<double>(
    begin: 1.0,
    end: 1.15,
  ).animate(CurvedAnimation(parent: _robotPulseCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    exhibits = MockDataService.getAllExhibits();

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
      if (prefs.hasCompletedOnboarding && !prefs.hasSeenLocationPrompt) {
        await _requestInitialPermissions(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _robotPulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestInitialPermissions(BuildContext context) async {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (kIsWeb) {
      prefs.setHasSeenLocationPrompt(true);
      return;
    }

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

  Widget _buildPinnedTopRow(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandStyle = AppTextStyles.brandTitle(context, isDark: isDark);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => AppMenuShell.of(context)?.toggleMenu(),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/ankh.png', width: 20, height: 20),
                    const SizedBox(width: 8),
                    Text(
                      'HORUS-BOT',
                      style: brandStyle.copyWith(
                        color: AppColors.primaryGold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations l10n) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 300,
          width: double.infinity,
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                kBgBlack.withOpacity(0.35),
                kBgBlack.withOpacity(0.72),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Image.asset(
            'assets/images/museum_interior.jpg',
            fit: BoxFit.cover,
          ),
        ),
        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final double opacity = (1.0 - (_scrollController.offset / 150))
                .clamp(0.0, 1.0);
            return Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (AppLocalizations.of(context)?.exploreEgypt ?? 'EXPLORE')
                          .toUpperCase(),
                      style: AppTextStyles.bodySecondary(context).copyWith(
                        letterSpacing: 1.5,
                        fontSize: 11,
                        color: kTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.exploreEgypt,
                      style: AppTextStyles.displayHero(
                        context,
                      ).copyWith(fontSize: 28, color: kTextWhite),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(BuildContext context, AppLocalizations l10n) {
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final connectionText = sessionProvider.getConnectionStatusText(
      prefs.language,
    );

    final isConnected = sessionProvider.isRobotConnected;
    final statusColor = isConnected
        ? Colors.green
        : (sessionProvider.robotConnectionState ==
                  session.RobotConnectionState.connecting
              ? Colors.amber
              : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildGlassCard(
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  connectionText,
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTourSection(BuildContext context, AppLocalizations l10n) {
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    // If tour completed, show completed section
    if (sessionProvider.tourLifecycleState ==
        session.TourLifecycleState.completed) {
      return _buildCompletedTourSection(context, l10n, sessionProvider, prefs);
    }

    // If in active tour, show current stop
    if (sessionProvider.isInActiveTour) {
      return _buildActiveTourSection(context, l10n, sessionProvider, prefs);
    }

    // If visiting mode but not connected, show ready to connect
    if (sessionProvider.appUsageMode == session.AppUsageMode.visiting) {
      return _buildReadyToConnectSection(context, l10n, sessionProvider, prefs);
    }

    // Default: planning mode, show plan your visit
    return _buildPlanningSection(context, l10n, sessionProvider, prefs);
  }

  Widget _buildCompletedTourSection(
    BuildContext context,
    AppLocalizations l10n,
    session.AppSessionProvider sessionProvider,
    UserPreferencesModel prefs,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (prefs.language == 'ar' ? 'اكتملت الجولة' : 'Tour Completed')
                  .toUpperCase(),
              style: AppTextStyles.displaySectionTitle(
                context,
              ).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
            Text(
              prefs.language == 'ar'
                  ? 'شكراً لزيارتك مع حوروس-بوت'
                  : 'Thank you for your visit with Horus-Bot',
              style: AppTextStyles.displayArtifactTitle(
                context,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cinematicSection,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prefs.language == 'ar'
                          ? 'الجولة مكتملة بنجاح'
                          : 'Tour completed successfully',
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: prefs.language == 'ar' ? 'عرض الملخص' : 'View Summary',
              onPressed: () => Navigator.pushNamed(context, '/visit-summary'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningSection(
    BuildContext context,
    AppLocalizations l10n,
    session.AppSessionProvider sessionProvider,
    UserPreferencesModel prefs,
  ) {
    final title = prefs.language == 'ar'
        ? 'خطط زيارتك للمتحف'
        : 'Plan your museum visit';
    final subtitle = prefs.language == 'ar'
        ? 'اشترِ التذاكر، حضر جولتك، أو ابدأ عند الوصول.'
        : 'Buy tickets, prepare your tour, or start when you arrive.';
    final ticketsLabel = prefs.language == 'ar'
        ? 'عرض التذاكر'
        : 'View Tickets';
    final startTourLabel = prefs.language == 'ar'
        ? 'ابدأ جولتي'
        : 'Start My Tour';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.displayArtifactTitle(
                context,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: ticketsLabel,
                    icon: Icons.confirmation_number,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.tickets),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      sessionProvider.startVisiting();
                      if (sessionProvider.canStartRobotTour) {
                        if (sessionProvider.hasTourPreferences) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.qrScan,
                            arguments: QRScanMode.robotConnection,
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.tourCustomization,
                          );
                        }
                      } else {
                        Navigator.pushNamed(context, AppRoutes.tickets);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      startTourLabel,
                      style: AppTextStyles.buttonLabel(
                        context,
                      ).copyWith(color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyToConnectSection(
    BuildContext context,
    AppLocalizations l10n,
    session.AppSessionProvider sessionProvider,
    UserPreferencesModel prefs,
  ) {
    final title = prefs.language == 'ar'
        ? 'اتصل بحوروس-بوت'
        : 'Connect to Horus-Bot';
    final subtitle = prefs.language == 'ar'
        ? 'ابدأ جولتك الموجهة بالروبوت.'
        : 'Start your guided robot tour.';
    final scanLabel = prefs.language == 'ar'
        ? 'مسح رمز الروبوت'
        : 'Scan Robot QR';
    final ticketsLabel = prefs.language == 'ar'
        ? 'عرض التذاكر'
        : 'View Tickets';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.displayArtifactTitle(
                context,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: scanLabel,
                    icon: Icons.qr_code_scanner,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.qrScan,
                      arguments: QRScanMode.robotConnection,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.myTickets),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      ticketsLabel,
                      style: AppTextStyles.buttonLabel(
                        context,
                      ).copyWith(color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTourSection(
    BuildContext context,
    AppLocalizations l10n,
    session.AppSessionProvider sessionProvider,
    UserPreferencesModel prefs,
  ) {
    final currentExhibit = exhibits.firstWhere(
      (e) => e.id == sessionProvider.currentExhibitId,
      orElse: () => exhibits.isNotEmpty
          ? exhibits.first
          : Exhibit(
              id: '0',
              nameEn: 'Not Selected',
              nameAr: 'لم يتم تحديده',
              descriptionEn: '',
              descriptionAr: '',
              imageAsset: '',
              x: 0,
              y: 0,
            ),
    );

    final currentExhibitName = prefs.language == 'ar'
        ? currentExhibit.nameAr
        : currentExhibit.nameEn;
    final tourStateText = sessionProvider.getTourLifecycleText(prefs.language);

    final buttonLabel = prefs.language == 'ar'
        ? 'اتبع حوروس'
        : 'Follow Horus-Bot';
    final mapLabel = prefs.language == 'ar' ? 'عرض على الخريطة' : 'View Map';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (prefs.language == 'ar' ? 'المحطة الحالية' : 'Current Stop')
                  .toUpperCase(),
              style: AppTextStyles.displaySectionTitle(
                context,
              ).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
            Text(
              currentExhibitName,
              style: AppTextStyles.displayArtifactTitle(
                context,
              ).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cinematicSection,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tourStateText,
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: buttonLabel,
                    icon: Icons.directions_run,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.liveTour,
                      (r) => false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.map,
                      (r) => false,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: AppColors.primaryGold,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      mapLabel,
                      style: AppTextStyles.buttonLabel(
                        context,
                      ).copyWith(color: AppColors.primaryGold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourProgress(BuildContext context, AppLocalizations l10n) {
    final tourProvider = Provider.of<TourProvider>(context);
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    final visitedCount = tourProvider.visitedExhibitIds.length;
    final totalCount = exhibits.length;
    final progress = totalCount > 0 ? visitedCount / totalCount : 0.0;

    final progressLabel = prefs.language == 'ar'
        ? '$visitedCount / $totalCount قاعات تمت زيارتها'
        : '$visitedCount / $totalCount exhibits visited';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progressLabel,
              style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.cinematicSection,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final mapLabel = prefs.language == 'ar' ? 'الخريطة' : 'Map';
    final ticketsLabel = prefs.language == 'ar' ? 'التذاكر' : 'Tickets';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.map_outlined,
              label: mapLabel,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.map,
                (r) => false,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.confirmation_number_outlined,
              label: ticketsLabel,
              onTap: () => Navigator.pushNamed(context, AppRoutes.tickets),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionProvider = Provider.of<session.AppSessionProvider>(context);

    return AppMenuShell(
      hideDefaultAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.warmSurface,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      showChatButton: false,
      body: Builder(
        builder: (innerContext) => Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.2, -0.75),
                        radius: 1.05,
                        colors: [
                          AppColors.primaryGold.withOpacity(0.06),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.08),
                          Colors.transparent,
                          Colors.black.withOpacity(0.10),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildPinnedTopRow(innerContext, l10n),
                ),
                SliverToBoxAdapter(
                  child: _buildHeroSection(innerContext, l10n),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                // Only show connection status if not in planning mode
                if (sessionProvider.appUsageMode !=
                    session.AppUsageMode.planning)
                  SliverToBoxAdapter(
                    child: _buildConnectionStatus(innerContext, l10n),
                  ),
                if (sessionProvider.appUsageMode !=
                    session.AppUsageMode.planning)
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _buildCurrentTourSection(innerContext, l10n),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // Only show tour progress if in active tour
                if (sessionProvider.isInActiveTour)
                  SliverToBoxAdapter(
                    child: _buildTourProgress(innerContext, l10n),
                  ),
                if (sessionProvider.isInActiveTour)
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _buildQuickActions(innerContext, l10n),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
