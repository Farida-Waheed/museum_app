import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/quiz.dart';
import '../../models/tour_provider.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  final String? exhibitId; // Optional: specific quiz for an exhibit
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
    // For demo, if exhibitId is provided, just show 2 questions for that exhibit
    // If not, show all questions.
    final all = MockDataService.getAllQuestions();
    if (widget.exhibitId != null) {
      _questions = all.take(2).toList();
    } else {
      _questions = all;
    }
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
      if (widget.exhibitId != null) {
        Provider.of<TourProvider>(context, listen: false)
            .recordQuizResult(widget.exhibitId!, _score);
      }
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isPass = _score >= (_questions.length / 2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuizResultPopup(
        score: _score,
        total: _questions.length,
        isPass: isPass,
        l10n: l10n,
        onFinish: () {
          Navigator.pop(context); // Close Dialog
          Navigator.pop(context); // Go Back
        },
        onRetry: () {
          Navigator.pop(context); // Close Dialog
          setState(() {
            _currentIndex = 0;
            _score = 0;
            _selectedOptionIndex = null;
            _isAnswered = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final l10n = AppLocalizations.of(context)!;
    
    if (_questions.isEmpty) return Scaffold(body: Center(child: Text(isArabic ? "لا توجد أسئلة حالياً" : "No questions available")));

    final question = _questions[_currentIndex];
    final options = question.getOptions(prefs.language);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(isArabic ? "اختبار المعلومات" : "Museum Quiz", style: const TextStyle(color: Color(0xFFF5F1E8))),
        elevation: 0,
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFF5F1E8),
      ),
      body: Column(
        children: [
          // 1. Progress Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? "السؤال ${_currentIndex + 1} من ${_questions.length}" : "Question ${_currentIndex + 1} of ${_questions.length}",
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "${((_currentIndex + 1) / _questions.length * 100).round()}%",
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // 2. Question Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1912),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE6C068).withOpacity(0.2)),
                    ),
                    child: Text(
                      question.getQuestion(prefs.language),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.4, color: Color(0xFFF5F1E8)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Options
                  ...List.generate(options.length, (index) {
                    final isCorrect = index == question.correctAnswerIndex;
                    final isSelected = index == _selectedOptionIndex;

                    Color bgColor = const Color(0xFF1E1912);
                    Color borderColor = const Color(0xFFE6C068).withOpacity(0.2);
                    Color textColor = const Color(0xFFF5F1E8);
                    IconData? icon;

                    if (_isAnswered) {
                      if (isCorrect) {
                        bgColor = Colors.green.shade50;
                        borderColor = Colors.green.shade400;
                        textColor = Colors.green.shade900;
                        icon = Icons.check_circle_rounded;
                      } else if (isSelected) {
                        bgColor = Colors.red.shade50;
                        borderColor = Colors.red.shade400;
                        textColor = Colors.red.shade900;
                        icon = Icons.cancel_rounded;
                      } else {
                        textColor = Colors.grey.shade400;
                      }
                    } else if (isSelected) {
                      borderColor = const Color(0xFFE6C068);
                      bgColor = const Color(0xFFE6C068).withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _checkAnswer(index),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE6C068) : const Color(0xFF121212),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE6C068).withOpacity(0.2)),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF1E1912) : const Color(0xFFF5F1E8).withOpacity(0.6),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected || (_isAnswered && isCorrect) ? FontWeight.bold : FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (icon != null)
                                Icon(icon, color: icon == Icons.check_circle_rounded ? Colors.green : Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 3. Footer Action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1912),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAnswered ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6C068),
                    foregroundColor: const Color(0xFF1E1912),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentIndex == _questions.length - 1
                      ? l10n.done
                      : (isArabic ? "السؤال التالي" : "Next Question"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _QuizResultPopup extends StatelessWidget {
  final int score;
  final int total;
  final bool isPass;
  final AppLocalizations l10n;
  final VoidCallback onFinish;
  final VoidCallback onRetry;

  const _QuizResultPopup({
    required this.score,
    required this.total,
    required this.isPass,
    required this.l10n,
    required this.onFinish,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF1E1912),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE6C068), width: 1),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE6C068).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPass ? Icons.emoji_events_rounded : Icons.menu_book_rounded,
                color: const Color(0xFFE6C068),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPass ? l10n.congrats : (Localizations.localeOf(context).languageCode == 'ar' ? "استمر في التعلم!" : "Keep Learning!"),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFF5F1E8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              Localizations.localeOf(context).languageCode == 'ar'
                ? "لقد حصلت على $score من $total"
                : "You scored $score out of $total",
              style: TextStyle(color: const Color(0xFFF5F1E8).withOpacity(0.6), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE6C068),
                      side: const BorderSide(color: Color(0xFFE6C068)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(Localizations.localeOf(context).languageCode == 'ar' ? "إعادة" : "Retry"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6C068),
                      foregroundColor: const Color(0xFF1E1912),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(l10n.done),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
