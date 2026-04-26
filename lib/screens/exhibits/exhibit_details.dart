import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit_provider.dart';
import '../../models/tour_provider.dart';
import '../../core/utils/audio_player.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/robot_status_banner.dart';
import '../quiz/quiz_screen.dart'; // To navigate to quiz
import '../../widgets/dialogs/premium_dialog.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

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
  bool _quizPromptShown = false;

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

  void _toggleBookmark(
    Exhibit exhibit,
    AppLocalizations l10n,
    ExhibitProvider provider,
  ) {
    provider.toggleBookmark(exhibit.id);
    final isBookmarked = provider.isBookmarked(exhibit.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cinematicCard,
        content: Text(
          isBookmarked ? l10n.addedToBookmarks : l10n.removedFromBookmarks,
          style: AppTextStyles.bodyPrimary(
            context,
          ).copyWith(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exhibit = ModalRoute.of(context)!.settings.arguments as Exhibit;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final exhibitProvider = Provider.of<ExhibitProvider>(context);
    final tourProvider = Provider.of<TourProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final isBookmarked = exhibitProvider.isBookmarked(exhibit.id);
    final isArabic = prefs.language == 'ar';

    // Mark as visited when viewing details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TourProvider>(
        context,
        listen: false,
      ).setCurrentExhibit(exhibit.id);
      if (!_quizPromptShown &&
          !tourProvider.quizScores.containsKey(exhibit.id) &&
          !tourProvider.skippedQuizzes.contains(exhibit.id) &&
          !tourProvider.pendingQuizzes.contains(exhibit.id)) {
        _quizPromptShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PremiumDialog(
            title: l10n.quizPromptTitle,
            icon: const Icon(
              Icons.quiz_rounded,
              color: AppColors.primaryGold,
              size: 28,
            ),
            content: Text(
              l10n.quizPromptDescription,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  tourProvider.postponeQuiz(exhibit.id);
                },
                child: Text(
                  l10n.later,
                  style: AppTextStyles.buttonLabel(
                    context,
                  ).copyWith(color: Colors.white60),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/quiz', arguments: exhibit.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.takeNow,
                  style: AppTextStyles.buttonLabel(context),
                ),
              ),
            ],
          ),
        );
      }
    });

    final hasCompletedQuiz = tourProvider.quizScores.containsKey(exhibit.id);

    return AppMenuShell(
      subHeader: const RobotStatusBanner(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(
            exhibit,
            prefs.language,
            cs,
            l10n,
            isBookmarked,
            exhibitProvider,
          ),
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
                    l10n.description.toUpperCase(),
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exhibit.getDescription(prefs.language),
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      height: 1.6,
                      color: isDark ? AppColors.helperText : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Integrated Quiz Prompt
                  if (!hasCompletedQuiz)
                    _buildQuizPrompt(l10n, cs, exhibit.id, isArabic)
                  else
                    _buildQuizCompletedChip(
                      l10n,
                      cs,
                      tourProvider.quizScores[exhibit.id]!,
                      isArabic,
                    ),

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

  Widget _buildQuizPrompt(
    AppLocalizations l10n,
    ColorScheme cs,
    String exhibitId,
    bool isArabic,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.quiz_outlined,
                color: AppColors.primaryGold,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.takeQuickQuiz,
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.darkInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PremiumDialog(
                        title: isArabic ? "هل أنت مستعد؟" : "Are you ready?",
                        icon: const Icon(
                          Icons.quiz_outlined,
                          color: AppColors.primaryGold,
                        ),
                        content: Text(
                          isArabic
                              ? "أنهيت عرض توت عنخ آمون. هل تريد بدء الاختبار؟"
                              : "You finished the Tutankhamun exhibit. Ready to start the quiz?",
                          style: AppTextStyles.bodyPrimary(
                            context,
                          ).copyWith(color: Colors.white70, fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Provider.of<TourProvider>(
                                context,
                                listen: false,
                              ).skipQuiz(exhibitId);
                            },
                            child: Text(
                              isArabic ? "لاحقاً" : "Later",
                              style: AppTextStyles.buttonLabel(
                                context,
                              ).copyWith(color: Colors.white60),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      QuizScreen(exhibitId: exhibitId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGold,
                              foregroundColor: AppColors.darkInk,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.startQuiz,
                              style: AppTextStyles.buttonLabel(
                                context,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.startQuiz,
                    style: AppTextStyles.buttonLabel(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  Provider.of<TourProvider>(
                    context,
                    listen: false,
                  ).skipQuiz(exhibitId);
                },
                child: Text(
                  isArabic ? "تخطي" : "Skip",
                  style: AppTextStyles.buttonLabel(context).copyWith(
                    color: isDark ? Colors.white70 : AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompletedChip(
    AppLocalizations l10n,
    ColorScheme cs,
    int score,
    bool isArabic,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(
            isArabic ? "الاختبار مكتمل" : "Quiz Completed",
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            isArabic ? "النتيجة: $score" : "Score: $score",
            style: AppTextStyles.bodyPrimary(context).copyWith(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w900,
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
          style: AppTextStyles.displayArtifactTitle(
            context,
          ).copyWith(color: Colors.white, fontSize: 18),
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

  Widget _buildAudioCard(
    Exhibit exhibit,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : Colors.transparent,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
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
                  color: AppColors.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playController,
                  size: 32,
                  color: AppColors.primaryGold,
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
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.audioNarration,
                    style: AppTextStyles.metadata(context).copyWith(
                      fontSize: 12,
                      color: isDark ? AppColors.helperText : Colors.black54,
                    ),
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

  Widget _buildFactChips(
    Exhibit exhibit,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final facts = <Map<String, dynamic>>[
      {'icon': Icons.public, 'label': l10n.origin, 'value': 'Ancient Egypt'},
      {
        'icon': Icons.calendar_today,
        'label': l10n.period,
        'value': 'New Kingdom',
      },
      {'icon': Icons.location_on, 'label': l10n.gallery, 'value': 'Hall A'},
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
                style: AppTextStyles.metadata(context),
              ),
              backgroundColor: AppColors.primaryGold.withOpacity(0.1),
              labelStyle: AppTextStyles.metadata(
                context,
              ).copyWith(color: isDark ? Colors.white : Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.primaryGold.withOpacity(0.2)),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.addedToRoute)));
          },
          icon: const Icon(Icons.route),
          label: Text(
            l10n.addToMyRoute,
            style: AppTextStyles.buttonLabel(context).copyWith(fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGold,
            side: BorderSide(color: AppColors.primaryGold.withOpacity(0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.openingMap)));
          },
          icon: const Icon(Icons.map_outlined, color: AppColors.primaryGold),
          label: Text(
            l10n.viewOnMap,
            style: AppTextStyles.buttonLabel(
              context,
            ).copyWith(color: AppColors.primaryGold, fontSize: 14),
          ),
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
        ),
      ],
    );
  }
}
