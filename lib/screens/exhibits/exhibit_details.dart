import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/audio_player.dart';
import '../../widgets/bottom_nav.dart';
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
  bool _isBookmarked = false;

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

  void _toggleAudio(Exhibit exhibit, bool isArabic) {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _playController.forward();
      // TODO: wire proper audio path, this is just a placeholder
      _audioService.playAudio('audio/${exhibit.id}.mp3');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "يتم تشغيل الشرح الصوتي..."
                : "Playing the audio guide...",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _playController.reverse();
      _audioService.stop();
    }
  }

  void _toggleBookmark(bool isArabic) {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? (isArabic
                    ? "تمت إضافة المعروض إلى قائمتك."
                    : "Exhibit added to your list.")
              : (isArabic
                    ? "تمت إزالة المعروض من قائمتك."
                    : "Exhibit removed from your list."),
        ),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exhibit = ModalRoute.of(context)!.settings.arguments as Exhibit;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // detail screen usually has no bottom nav, but we keep Horus-Bot entry
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      floatingActionButton: const RoboGuideEntry(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(exhibit, prefs.language, cs, isArabic),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  _buildAudioCard(exhibit, isArabic, cs),
                  const SizedBox(height: 24),
                  _buildFactChips(exhibit, isArabic, cs),
                  const SizedBox(height: 28),
                  Text(
                    isArabic ? "الوصف" : "Description",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exhibit.getDescription(prefs.language),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildRouteButtons(isArabic, cs),
                  const SizedBox(height: 32),
                ],
              ),
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
    bool isArabic,
  ) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: cs.surface,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () => _toggleBookmark(isArabic),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Text(
          exhibit.getName(language),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // TODO: replace with Exhibit image if you add an imagePath field.
            // e.g. Image.asset(exhibit.imagePath, fit: BoxFit.cover)
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

  Widget _buildAudioCard(Exhibit exhibit, bool isArabic, ColorScheme cs) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InkWell(
              onTap: () => _toggleAudio(exhibit, isArabic),
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
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "الشرح الصوتي" : "Audio guide",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? "اضغط للاستماع إلى شرح قصير."
                        : "Tap to listen to a short narration.",
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

  Widget _buildFactChips(Exhibit exhibit, bool isArabic, ColorScheme cs) {
    // You can later replace these with real fields from Exhibit
    final facts = <Map<String, dynamic>>[
      {
        'icon': Icons.public,
        'label': isArabic ? 'الأصل' : 'Origin',
        'value': 'Ancient Egypt',
      },
      {
        'icon': Icons.calendar_today,
        'label': isArabic ? 'الفترة' : 'Period',
        'value': 'New Kingdom',
      },
      {
        'icon': Icons.location_on,
        'label': isArabic ? 'المعرض' : 'Gallery',
        'value': 'Hall A',
      },
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
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

  Widget _buildRouteButtons(bool isArabic, ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            // TODO: wire to My Route screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? "أُضيفت هذه القطعة إلى مسارك."
                      : "Added to your route.",
                ),
              ),
            );
          },
          icon: const Icon(Icons.route),
          label: Text(isArabic ? "أضف إلى مساري" : "Add to my route"),
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
            // TODO: navigate to map zoomed into this gallery
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isArabic
                      ? "فتح الخريطة في قاعة هذه القطعة."
                      : "Opening the map at this gallery.",
                ),
              ),
            );
          },
          icon: const Icon(Icons.map_outlined),
          label: Text(isArabic ? "عرض على الخريطة" : "View on map"),
          style: TextButton.styleFrom(foregroundColor: cs.primary),
        ),
      ],
    );
  }
}
