import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart'; // RoboGuideEntry

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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Feedback submitted',
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
    final theme = Theme.of(context);

    final tags = isArabic ? _tagsAr : _tagsEn;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      floatingActionButton: const RoboGuideEntry(),
      appBar: AppBar(
        title: Text(
          isArabic ? "الملاحظات" : "Feedback",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // HEADER CARD (matches TicketScreen style)
                  Card
                  (
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.feedback_outlined,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic
                                      ? "كيف كانت زيارتك اليوم؟"
                                      : "How was your visit today?",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "قيّم تجربتك مع المتحف وحوروس."
                                      : "Rate your experience with the museum and Horus-Bot.",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // RATING CARD
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? "التقييم العام" : "Overall rating",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                      isFilled ? Colors.amber[700] : Colors.grey,
                                  size: 34,
                                ),
                              );
                            }),
                          ),
                          if (_rating > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _ratingLabel(_rating, isArabic),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign:
                                    isArabic ? TextAlign.right : TextAlign.left,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            isArabic
                                ? "اختر ما تريد التعليق عليه (اختياري):"
                                : "What is this feedback about? (optional)",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: isArabic
                                ? WrapAlignment.end
                                : WrapAlignment.start,
                            children: List.generate(tags.length, (i) {
                              final selected =
                                  _selectedTagIndexes.contains(i);
                              return GestureDetector(
                                onTap: () => _toggleTag(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? theme.colorScheme.primary
                                            .withOpacity(0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    tags[i],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // COMMENT CARD
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? "أخبرنا المزيد (اختياري)"
                                : "Tell us more (optional)",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? "ما الشيء الذي أعجبك أو تحتاج تحسينه؟"
                                : "What worked well or could be improved?",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? "اكتب ملاحظاتك هنا..."
                                  : "Write your feedback here...",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    isArabic
                        ? "تُستخدم الملاحظات للأبحاث وتحسين تجربة الزوار فقط."
                        : "Feedback is used only for research and improving the visitor experience.",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),

                  const SizedBox(height: 80), // space above bottom button
                ],
              ),
            ),
          ),

          // BOTTOM SUBMIT BAR
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleSubmit(isArabic),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isArabic ? "إرسال الملاحظات" : "Submit feedback",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.check_rounded,
                  color: theme.colorScheme.primary,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isArabic ? "تم إرسال الملاحظات" : "Feedback submitted",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isArabic
                    ? "شكراً لمساعدتك في تحسين حوروس وتجربة المتحف."
                    : "Thanks for helping us improve Horus-Bot and the museum visit.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isArabic ? "إغلاق" : "Close",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
