import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../../widgets/primary_button.dart';
import '../../core/services/permission_service.dart';

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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        PermissionService.checkAndRequestLocation(context, forcePrompt: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourProvider = Provider.of<TourProvider>(context, listen: false);
      if (tourProvider.currentExhibitId == null) {
        tourProvider.setCurrentExhibit(MockDataService.getAllExhibits().first.id);
      }
      _startSimulation();
    });
  }

  void _startSimulation() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final exhibitId = tourProvider.currentExhibitId;
    if (exhibitId == null) return;

    final allExhibits = MockDataService.getAllExhibits();
    final exhibit = allExhibits.firstWhere((e) => e.id == exhibitId, orElse: () => allExhibits.first);

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

  void _skipExhibit() {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final all = MockDataService.getAllExhibits();
    final currentIdx = all.indexWhere((e) => e.id == tourProvider.currentExhibitId);
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
    final currentExhibit = allExhibits.firstWhere((e) => e.id == tourProvider.currentExhibitId, orElse: () => allExhibits.first);
    final currentIdx = allExhibits.indexWhere((e) => e.id == currentExhibit.id);
    final nextExhibit = currentIdx < allExhibits.length - 1 ? allExhibits[currentIdx + 1] : null;

    return AppMenuShell(
      title: l10n.liveTour,
      subHeader: const RobotStatusBanner(),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            Text(l10n.currentStop, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          MockDataService.getExhibitImage(currentExhibit.id),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                            ),
                          ),
                          child: Text(
                            currentExhibit.getName(Localizations.localeOf(context).languageCode),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                            const Icon(Icons.smart_toy, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l10n.robotDescribing, style: const TextStyle(fontSize: 13))),
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
                Text(l10n.liveTranscript, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: isLast ? Colors.black : Colors.grey,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- NEXT UP ---
            if (nextExhibit != null) ...[
               Text(l10n.nextStopLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
               const SizedBox(height: 8),
               Card(
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                   side: BorderSide(color: Colors.grey.shade200),
                 ),
                 child: ListTile(
                   leading: ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: Image.asset(
                       MockDataService.getExhibitImage(nextExhibit.id),
                       width: 50,
                       height: 50,
                       fit: BoxFit.cover,
                     ),
                   ),
                   title: Text(nextExhibit.getName(Localizations.localeOf(context).languageCode)),
                   subtitle: Text(l10n.robotWaiting, style: const TextStyle(fontSize: 12)),
                   trailing: const Icon(Icons.chevron_right),
                   onTap: _skipExhibit,
                 ),
               ),
            ] else ...[
               PrimaryButton(
                 label: l10n.endTour,
                 onPressed: () => Navigator.pushReplacementNamed(context, '/summary'),
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
            isPulsing ? _PulsingDot(color: color) : Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
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

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
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

  const _ControlButton({required this.icon, required this.label, required this.onTap});

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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TourProgressTimeline extends StatelessWidget {
  final int currentIndex;
  final int total;
  final String label;

  const _TourProgressTimeline({required this.currentIndex, required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${currentIndex + 1} / $total", style: const TextStyle(color: Colors.grey)),
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
                  color: isCompleted ? Colors.blue : (isCurrent ? Colors.blue.withOpacity(0.3) : Colors.grey.shade200),
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
