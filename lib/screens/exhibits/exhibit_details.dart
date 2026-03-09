import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit_provider.dart';
import '../../models/tour_provider.dart';
import '../../core/utils/audio_player.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../chat/chat_screen.dart'; // RoboGuideEntry

class ExhibitDetailScreen extends StatefulWidget {
  const ExhibitDetailScreen({super.key});

  @override
  State<ExhibitDetailScreen> createState() => _ExhibitDetailScreenState();
}

class _ExhibitDetailScreenState extends State<ExhibitDetailScreen>
    with SingleTickerProviderStateMixin {
  final AudioGuideService _audioService = AudioGuideService();
  late final AnimationController _playController;

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _audioService.stop();
    _playController.dispose();
    super.dispose();
  }

  void _toggleAudio(Exhibit exhibit, AppLocalizations l10n) {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _playController.forward();
      // TODO: wire proper audio path, this is just a placeholder
      _audioService.playAudio('audio/${exhibit.id}.mp3');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.audioPlaying),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _playController.reverse();
      _audioService.stop();
    }
  }

  void _toggleBookmark(Exhibit exhibit, AppLocalizations l10n, ExhibitProvider provider) {
    provider.toggleBookmark(exhibit.id);
    final isBookmarked = provider.isBookmarked(exhibit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked ? l10n.addedToBookmarks : l10n.removedFromBookmarks,
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exhibit = ModalRoute.of(context)!.settings.arguments as Exhibit;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final exhibitProvider = Provider.of<ExhibitProvider>(context);
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isBookmarked = exhibitProvider.isBookmarked(exhibit.id);

    // Mark as visited when viewing details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tourProvider.setCurrentExhibit(exhibit.id);
    });

    return AppMenuShell(
      subHeader: const RobotStatusBanner(),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: const RoboGuideEntry(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(exhibit, prefs.language, cs, l10n, isBookmarked, exhibitProvider),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAudioCard(exhibit, l10n, cs),
                  const SizedBox(height: 24),
                  _buildFactChips(exhibit, l10n, cs),
                  const SizedBox(height: 28),
                  Text(
                    l10n.description,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exhibit.getDescription(prefs.language),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildQuizPrompt(l10n, cs),
                  const SizedBox(height: 28),
                  _buildRouteButtons(l10n, cs),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizPrompt(AppLocalizations l10n, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.quiz, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.takeQuickQuiz, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/quiz'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: Text(l10n.startQuiz),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------

  Widget _buildSliverAppBar(
    Exhibit exhibit,
    String language,
    ColorScheme cs,
    AppLocalizations l10n,
    bool isBookmarked,
    ExhibitProvider exhibitProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: cs.surface,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () => _toggleBookmark(exhibit, l10n, exhibitProvider),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          exhibit.getName(language),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/museum_interior.jpg', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- AUDIO CARD ----------

  Widget _buildAudioCard(Exhibit exhibit, AppLocalizations l10n, ColorScheme cs) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InkWell(
              onTap: () => _toggleAudio(exhibit, l10n),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playController,
                  size: 32,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.audioGuide,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.audioNarration,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- FACT CHIPS ----------

  Widget _buildFactChips(Exhibit exhibit, AppLocalizations l10n, ColorScheme cs) {
    final facts = <Map<String, dynamic>>[
      {
        'icon': Icons.public,
        'label': l10n.origin,
        'value': 'Ancient Egypt',
      },
      {
        'icon': Icons.calendar_today,
        'label': l10n.period,
        'value': 'New Kingdom',
      },
      {
        'icon': Icons.location_on,
        'label': l10n.gallery,
        'value': 'Hall A',
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: facts
          .map(
            (f) => Chip(
              avatar: Icon(f['icon'] as IconData, size: 18, color: cs.primary),
              label: Text(
                '${f['label']}: ${f['value']}',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: cs.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------- ROUTE / MAP BUTTONS ----------

  Widget _buildRouteButtons(AppLocalizations l10n, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.addedToRoute),
              ),
            );
          },
          icon: const Icon(Icons.route),
          label: Text(l10n.addToMyRoute),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.primary.withOpacity(0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.openingMap),
              ),
            );
          },
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.viewOnMap),
          style: TextButton.styleFrom(foregroundColor: cs.primary),
        ),
      ],
    );
  }
}
