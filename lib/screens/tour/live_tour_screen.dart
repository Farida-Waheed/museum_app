import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ask_the_guide_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class LiveTourScreen extends StatefulWidget {
  const LiveTourScreen({super.key});

  @override
  State<LiveTourScreen> createState() => _LiveTourScreenState();
}

class _LiveTourScreenState extends State<LiveTourScreen> {
  final List<String> _transcript = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _simTimer;
  bool _isGuided = true;
  bool _isPaused = false;

  final Map<String, String> _imageMap = {
    '1': 'assets/images/Grand Hall.jpg',
    '2': 'assets/images/Colossal Seated Statues.jpg',
    '3': 'assets/images/Gold-Covered Sandals.jpg',
  };

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _checkLocationPermission();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourProvider = Provider.of<TourProvider>(context, listen: false);
      if (tourProvider.currentExhibitId == null) {
        tourProvider.setCurrentExhibit(
          MockDataService.getAllExhibits().first.id,
        );
      }
      _startSimulation();
    });
  }

  void _startSimulation() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final exhibitId = tourProvider.currentExhibitId;
    if (exhibitId == null) return;

    final allExhibits = MockDataService.getAllExhibits();
    final exhibit = allExhibits.firstWhere(
      (e) => e.id == exhibitId,
      orElse: () => allExhibits.first,
    );

    final sentences = [
      "Welcome to the ${exhibit.nameEn}.",
      exhibit.descriptionEn,
      "This artifact is extremely significant to our history.",
      "Notice the intricate details on the surface.",
      "It was discovered during a major excavation.",
      "Let's move closer to observe the craftsmanship.",
    ];

    int index = 0;

    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || _isPaused) return;
      if (index >= sentences.length) {
        timer.cancel();
        return;
      }
      setState(() => _transcript.add(sentences[index]));
      index++;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isGuided = !_isGuided);
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _checkLocationPermission() async {
    if (kIsWeb) return;
    final status = await Permission.locationWhenInUse.status;
    if (!status.isGranted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.location_on_outlined,
          title: l10n.locationPermissionTitle,
          description: l10n.locationPermissionDesc,
          onAllow: () async {
            Navigator.pop(context);
            await Permission.locationWhenInUse.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    }
  }

  void _skipExhibit() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final all = MockDataService.getAllExhibits();
    final currentIdx = all.indexWhere(
      (e) => e.id == tourProvider.currentExhibitId,
    );
    if (currentIdx < all.length - 1) {
      tourProvider.setCurrentExhibit(all[currentIdx + 1].id);
      setState(() {
        _transcript.clear();
      });
      _startSimulation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final allExhibits = MockDataService.getAllExhibits();
    final currentExhibit = allExhibits.firstWhere(
      (e) => e.id == tourProvider.currentExhibitId,
      orElse: () => allExhibits.first,
    );
    final currentIdx = allExhibits.indexWhere((e) => e.id == currentExhibit.id);
    final nextExhibit = currentIdx < allExhibits.length - 1
        ? allExhibits[currentIdx + 1]
        : null;

    return AppMenuShell(
      title: l10n.liveTour.toUpperCase(),
      subHeader: const RobotStatusBanner(),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      floatingActionButton: AskTheGuideButton(
        screen: 'live_tour',
        currentExhibitId: tourProvider.currentExhibitId,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP STATUS BAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(
                  label: _isGuided ? l10n.guidedMode : l10n.selfPacedMode,
                  icon: _isGuided ? Icons.auto_awesome : Icons.person_outline,
                  color: Colors.blue,
                  onTap: _toggleMode,
                ),
                _StatusChip(
                  label: l10n.live,
                  icon: Icons.radio_button_checked,
                  color: Colors.red,
                  isPulsing: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- PROGRESS TIMELINE ---
            _TourProgressTimeline(
              currentIndex: currentIdx,
              total: allExhibits.length,
              label: l10n.tourProgress,
            ),
            const SizedBox(height: 24),

            // --- CURRENT STOP CARD ---
            Text(
              l10n.currentStop.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Image.asset(
                          _imageMap[currentExhibit.id] ??
                              'assets/images/museum_interior.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Text(
                            currentExhibit.getName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: AppTextStyles.displayArtifactTitle(
                              context,
                            ).copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.smart_toy,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.robotDescribing,
                                style: AppTextStyles.metadata(
                                  context,
                                ).copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ControlButton(
                              icon: _isPaused ? Icons.play_arrow : Icons.pause,
                              label: _isPaused ? l10n.resume : l10n.pause,
                              onTap: _togglePause,
                            ),
                            _ControlButton(
                              icon: Icons.skip_next,
                              label: l10n.skip,
                              onTap: _skipExhibit,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- LIVE TRANSCRIPT ---
            Row(
              children: [
                const Icon(Icons.subject, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  l10n.liveTranscript.toUpperCase(),
                  style: AppTextStyles.displaySectionTitle(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.cinematicSection,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _transcript.length,
                itemBuilder: (context, index) {
                  final isLast = index == _transcript.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _transcript[index],
                      style: AppTextStyles.bodyPrimary(context).copyWith(
                        fontSize: 14,
                        color: isLast ? Colors.white : AppColors.neutralMedium,
                        fontWeight: isLast
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- NEXT UP ---
            if (nextExhibit != null) ...[
              Text(
                l10n.nextStopLabel.toUpperCase(),
                style: AppTextStyles.displaySectionTitle(context),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                color: AppColors.cinematicCard,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _imageMap[nextExhibit.id] ??
                          'assets/images/museum_interior.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    nextExhibit.getName(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTextStyles.titleMedium(
                      context,
                    ).copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    l10n.robotWaiting,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.neutralMedium,
                  ),
                  onTap: _skipExhibit,
                ),
              ),
            ] else ...[
              PrimaryButton(
                label: l10n.endTour,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/summary'),
                fullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPulsing;
  final VoidCallback? onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    this.isPulsing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isPulsing
                ? _PulsingDot(color: color)
                : Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.metadata(context).copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon),
          iconSize: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.metadata(
            context,
          ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _TourProgressTimeline extends StatelessWidget {
  final int currentIndex;
  final int total;
  final String label;

  const _TourProgressTimeline({
    required this.currentIndex,
    required this.total,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context),
            ),
            Text(
              "${currentIndex + 1} / $total",
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(total, (index) {
            final isCompleted = index < currentIndex;
            final isCurrent = index == currentIndex;

            return Expanded(
              child: Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryGold
                      : (isCurrent
                            ? AppColors.primaryGold.withOpacity(0.3)
                            : AppColors.cinematicSection),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
