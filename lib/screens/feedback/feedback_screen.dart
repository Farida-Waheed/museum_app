import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../chat/chat_screen.dart'; // RoboGuideEntry
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  // Simple quick-tags for “what was this about?”
  final List<String> _tagsEn = [
    "Robot guide",
    "Exhibits",
    "Navigation",
    "Tickets",
    "Facilities",
  ];
  final List<String> _tagsAr = [
    "الروبوت",
    "المعارض",
    "الخريطة",
    "التذاكر",
    "الخدمات",
  ];

  final Set<int> _selectedTagIndexes = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(int index) {
    setState(() {
      if (_selectedTagIndexes.contains(index)) {
        _selectedTagIndexes.remove(index);
      } else {
        _selectedTagIndexes.add(index);
      }
    });
  }

  Future<void> _handleSubmit(bool isArabic) async {
    if (_rating == 0 && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "من فضلك أضف تقييماً أو تعليقاً أولاً."
                : "Please add a rating or a short comment first.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: send to backend / Firestore / whatever you use.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _rating = 0;
      _commentController.clear();
      _selectedTagIndexes.clear();
    });

    _showThankYouDialog(isArabic);
  }

  // ==== POPPING CARD DIALOG (like ticket checkout) ====
  void _showThankYouDialog(bool isArabic) {
    final l10n = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.feedbackSubmitted,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: _FeedbackThankYouDialog(isArabic: isArabic),
        );
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == "ar";
    final l10n = AppLocalizations.of(context)!;

    final tags = isArabic ? _tagsAr : _tagsEn;

    return AppMenuShell(
      title: l10n.feedback.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      floatingActionButton: const RoboGuideEntry(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER CARD
                  Container(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.feedback_outlined,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                  isArabic
                                      ? "كيف كانت زيارتك اليوم؟"
                                      : "How was your visit today?",
                                  style: AppTextStyles.titleMedium(context).copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "قيّم تجربتك مع المتحف وحوروس."
                                      : "Rate your experience with the museum and Horus-Bot.",
                                  style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // RATING CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cinematicCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (isArabic ? "التقييم العام" : "Overall rating").toUpperCase(),
                          style: AppTextStyles.displaySectionTitle(context),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            final isFilled = star <= _rating;
                            return IconButton(
                              onPressed: () =>
                                  setState(() => _rating = star),
                              icon: Icon(
                                isFilled
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color:
                                    isFilled ? AppColors.primaryGold : AppColors.neutralDark,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                        if (_rating > 0)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _ratingLabel(_rating, isArabic),
                                style: AppTextStyles.metadata(context).copyWith(
                                  color: AppColors.primaryGold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          isArabic
                              ? "اختر ما تريد التعليق عليه (اختياري):"
                              : "What is this feedback about? (optional)",
                          style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(tags.length, (i) {
                            final selected =
                                _selectedTagIndexes.contains(i);
                            return GestureDetector(
                              onTap: () => _toggleTag(i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primaryGold.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primaryGold
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  tags[i],
                                  style: AppTextStyles.metadata(context).copyWith(
                                    fontSize: 12,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                    color: selected
                                        ? AppColors.primaryGold
                                        : AppColors.neutralMedium,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // COMMENT CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cinematicCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (isArabic ? "أخبرنا المزيد (اختياري)" : "Tell us more (optional)").toUpperCase(),
                          style: AppTextStyles.displaySectionTitle(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? "ما الشيء الذي أعجبك أو تحتاج تحسينه؟"
                              : "What worked well or could be improved?",
                          style: AppTextStyles.metadata(context),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          style: AppTextStyles.bodyPrimary(context).copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: isArabic
                                ? "اكتب ملاحظاتك هنا..."
                                : "Write your feedback here...",
                            hintStyle: AppTextStyles.metadata(context).copyWith(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.02),
                            contentPadding: const EdgeInsets.all(16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primaryGold,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    isArabic
                        ? "تُستخدم الملاحظات للأبحاث وتحسين تجربة الزوار فقط."
                        : "Feedback is used only for research and improving the visitor experience.",
                    style: AppTextStyles.metadata(context).copyWith(fontSize: 11, color: Colors.white24),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // BOTTOM SUBMIT BAR
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkHeader,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _handleSubmit(isArabic),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.darkInk,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isArabic ? "إرسال الملاحظات" : "Submit feedback",
                          style: AppTextStyles.buttonLabel(context),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating, bool isArabic) {
    switch (rating) {
      case 5:
        return isArabic ? "ممتاز، شكراً لك!" : "Excellent, thank you!";
      case 4:
        return isArabic ? "تجربة رائعة." : "Great experience.";
      case 3:
        return isArabic ? "جيدة بشكل عام." : "Overall good.";
      case 2:
        return isArabic ? "تحتاج لبعض التحسين." : "Needs some improvement.";
      case 1:
        return isArabic ? "تجربة غير مرضية." : "Not a good experience.";
      default:
        return "";
    }
  }
}

// ================== POPUP CARD WIDGET ===================

class _FeedbackThankYouDialog extends StatelessWidget {
  final bool isArabic;

  const _FeedbackThankYouDialog({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? "تم إرسال الملاحظات" : "Feedback submitted",
              style: AppTextStyles.displayScreenTitle(context).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "شكراً لمساعدتك في تحسين حوروس وتجربة المتحف."
                  : "Thanks for helping us improve Horus-Bot and the museum visit.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: AppColors.helperText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? "إغلاق" : "Close",
                  style: AppTextStyles.buttonLabel(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
