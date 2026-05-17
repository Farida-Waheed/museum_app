import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/quiz.dart';
import '../../models/app_session_provider.dart';
import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/dialogs/premium_dialog.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class QuizScreen extends StatefulWidget {
  final String? exhibitId;
  const QuizScreen({super.key, this.exhibitId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    final all = MockDataService.getAllQuestions();
    _questions = widget.exhibitId != null
        ? all
              .where((question) => question.exhibitId == widget.exhibitId)
              .toList()
        : all;
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isAnswered = true;
      if (selectedIndex == _questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      final elapsed = DateTime.now();
      final points = _score * 10;
      final earnedBadges = <String>[];
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      if (_score == _questions.length) {
        earnedBadges.add(isArabic ? 'متعلم متميز' : 'Perfect Score');
      } else if (_score >= (_questions.length * 0.75).ceil()) {
        earnedBadges.add(isArabic ? 'مستكشف ذكي' : 'Quiz Warrior');
      }
      final result = QuizResult(
        id: widget.exhibitId != null
            ? widget.exhibitId!
            : 'general_${elapsed.millisecondsSinceEpoch}',
        exhibitId: widget.exhibitId ?? 'general',
        completedAt: elapsed,
        totalQuestions: _questions.length,
        correctAnswers: _score,
        pointsEarned: points,
        earnedBadges: earnedBadges,
      );
      Provider.of<AppSessionProvider>(
        context,
        listen: false,
      ).addQuizResult(result);
      if (widget.exhibitId != null) {
        Provider.of<TourProvider>(
          context,
          listen: false,
        ).recordQuizResult(widget.exhibitId!, _score);
      }
      _showResultDialog(result);
    }
  }

  void _showResultDialog(QuizResult result) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isPass = _score >= (_questions.length / 2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumDialog(
        title: isPass
            ? l10n.congrats
            : (isArabic ? 'استمر في التعلم!' : 'Keep Learning!'),
        showCloseButton: false,
        icon: Icon(
          isPass ? Icons.emoji_events_rounded : Icons.menu_book_rounded,
          color: AppColors.primaryGold,
          size: 32,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'لقد حصلت على $_score من ${_questions.length}'
                  : 'You scored $_score out of ${_questions.length}',
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white70, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'النقاط المكتسبة: ${result.pointsEarned}'
                  : 'Points earned: ${result.pointsEarned}',
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (result.earnedBadges.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                isArabic ? 'الشارات المكتسبة:' : 'Badges earned:',
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: result.earnedBadges
                    .map(
                      (badge) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.bodyPrimary(context).copyWith(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _selectedOptionIndex = null;
                _isAnswered = false;
              });
            },
            child: Text(
              isArabic ? 'إعادة' : 'Retry',
              style: AppTextStyles.buttonLabel(
                context,
              ).copyWith(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Go Back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkInk,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.done, style: AppTextStyles.buttonLabel(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    if (_questions.isEmpty) {
      return AppMenuShell(
        title: (isArabic ? 'اختبار المعلومات' : 'Museum Quiz').toUpperCase(),
        backgroundColor: AppColors.cinematicBackground,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: Center(
            child: Text(
              isArabic ? 'لا توجد أسئلة' : 'No questions',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final options = question.getOptions(prefs.language);

    return AppMenuShell(
      title: (isArabic ? 'اختبار المعلومات' : 'Museum Quiz').toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildProgressHeader(isArabic),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppDecorations.premiumGlassCard(radius: 24),
                        child: Text(
                          question.getQuestion(prefs.language),
                          style: AppTextStyles.titleLarge(context).copyWith(
                            fontSize: 20,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...List.generate(
                        options.length,
                        (i) => _buildOptionTile(
                          i,
                          options[i],
                          question.correctAnswerIndex,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(isArabic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic
                    ? 'السؤال ${_currentIndex + 1} من ${_questions.length}'
                    : 'Question ${_currentIndex + 1} of ${_questions.length}',
                style: AppTextStyles.displaySectionTitle(
                  context,
                ).copyWith(color: AppColors.neutralMedium, fontSize: 13),
              ),
              Text(
                '${((_currentIndex + 1) / _questions.length * 100).round()}%',
                style: AppTextStyles.displaySectionTitle(
                  context,
                ).copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 6,
              backgroundColor: AppColors.darkSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index, String text, int correctIndex) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = index == correctIndex;
    Color color = AppColors.darkSurface;
    Color border = AppColors.primaryGold.withOpacity(0.2);
    Widget? icon;

    if (_isAnswered) {
      if (isCorrect) {
        color = Colors.green.withOpacity(0.1);
        border = Colors.green;
        icon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
      } else if (isSelected) {
        color = AppColors.alertRed.withOpacity(0.1);
        border = AppColors.alertRed;
        icon = const Icon(Icons.cancel, color: AppColors.alertRed, size: 20);
      }
    } else if (isSelected) {
      border = AppColors.primaryGold;
      color = AppColors.primaryGold.withOpacity(0.05);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _checkAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.darkBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      color: isSelected ? AppColors.darkInk : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              if (icon != null) icon,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isAnswered ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkInk,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              _currentIndex == _questions.length - 1
                  ? (isArabic ? 'إنهاء' : 'FINISH')
                  : (isArabic ? 'السؤال التالي' : 'NEXT QUESTION'),
              style: AppTextStyles.buttonLabel(context),
            ),
          ),
        ),
      ),
    );
  }
}
