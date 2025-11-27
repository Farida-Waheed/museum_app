import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart'; // for RoboGuideEntry

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // Theme Color Constants – BLUE to match TicketScreen
  static const Color _primaryBlue = Colors.blue; // main blue
  static const Color _lightBlue = Color(0xFF64B5F6); // lighter blue for gradients

  int _rating = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // SUBMIT + SUCCESS DIALOG ------------------------------------
  void _handleSubmit(bool isArabic) async {
    if (_rating == 0) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    _rating = 0;
    _nameController.clear();
    _emailController.clear();
    _commentController.clear();
    setState(() => _isSubmitting = false);

    _showSuccessDialog(isArabic);
  }

  void _showSuccessDialog(bool isArabic) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 450),
          tween: Tween(begin: 0.8, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            contentPadding: const EdgeInsets.all(32),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isArabic ? "شكراً لك!" : "Thank You!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isArabic
                      ? "تم استلام ملاحظاتك. نحن نقدر وقتك!"
                      : "Your feedback was received. We appreciate your time!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isArabic ? "إغلاق" : "Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Rating Labels
  String _getRatingLabel(int star, bool isArabic) {
    switch (star) {
      case 5:
        return isArabic ? "ممتاز!" : "Excellent!";
      case 4:
        return isArabic ? "عظيم!" : "Great!";
      case 3:
        return isArabic ? "جيد" : "Good";
      case 2:
        return isArabic ? "مقبول" : "Fair";
      case 1:
        return isArabic ? "سيء" : "Poor";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == "ar";

    final colorScheme = Theme.of(context).colorScheme.copyWith(
          primary: _primaryBlue,
          secondary: _lightBlue,
        );

    return Scaffold(
      backgroundColor: Colors.grey[100], // same style as TicketScreen
      bottomNavigationBar: const BottomNav(currentIndex: 4),

      // 💬 SAME behavior/position as HomeScreen
      floatingActionButton: const RoboGuideEntry(),

      appBar: AppBar(
        title: Text(
          isArabic ? "الملاحظات" : "Feedback",
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormCard(isArabic, colorScheme),
        ],
      ),
    );
  }

  // FORM CARD ------------------------------------
  Widget _buildFormCard(bool isArabic, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Gradient header strip – BLUE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    _lightBlue,
                    _primaryBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  const Icon(Icons.feedback_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    isArabic ? "ملاحظاتك تهمّنا" : "Your Feedback Matters",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isArabic ? "أرسل ملاحظاتك" : "Submit Feedback",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic
                  ? "ساعدنا في تحسين تجربتك في المتحف."
                  : "Help us improve your museum experience.",
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 18),

            // Topic chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
              children: [
                _TagChip(label: isArabic ? "الجولة" : "Tour"),
                _TagChip(label: isArabic ? "الروبوت" : "Robot"),
                _TagChip(label: isArabic ? "المعارض" : "Exhibits"),
                _TagChip(label: isArabic ? "الخدمات" : "Facilities"),
              ],
            ),

            const SizedBox(height: 24),

            // STAR RATING
            Text(
              isArabic ? "التقييم" : "Rating",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment:
                    isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  final s = index + 1;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: s <= _rating ? 1.2 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: IconButton(
                          icon: Icon(
                            s <= _rating
                                ? Icons.star_rate_rounded
                                : Icons.star_border_rounded,
                            color: s <= _rating
                                ? Colors.amber[700]
                                : Colors.grey[300],
                            size: 36,
                          ),
                          onPressed: () => setState(() => _rating = s),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            if (_rating > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getRatingLabel(_rating, isArabic),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 28),

            _buildTextField(
              controller: _nameController,
              label: isArabic ? "الاسم (اختياري)" : "Name (Optional)",
              icon: Icons.person_outline,
              isArabic: isArabic,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _emailController,
              label:
                  isArabic ? "البريد الإلكتروني (اختياري)" : "Email (Optional)",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isArabic: isArabic,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _commentController,
              label: isArabic ? "التعليقات" : "Comments",
              icon: Icons.comment_outlined,
              maxLines: 4,
              isArabic: isArabic,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: 24),

            // SUBMIT BUTTON – BLUE like TicketScreen
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: (_rating == 0 || _isSubmitting)
                    ? null
                    : () => _handleSubmit(isArabic),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting
                      ? (isArabic ? "جاري الإرسال" : "Submitting...")
                      : (isArabic ? "إرسال" : "Submit"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),

            const SizedBox(height: 20),

            Text(
              isArabic ? "مصادر إضافية" : "Extra Resources",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildResourceButtonModern(
              icon: Icons.download_for_offline_rounded,
              label:
                  isArabic ? "تحميل ملخص الزيارة" : "Download Visit Summary",
            ),
            const SizedBox(height: 10),

            _buildResourceButtonModern(
              icon: Icons.menu_book_rounded,
              label: isArabic ? "قراءة إضافية" : "Additional Reading",
            ),
            const SizedBox(height: 10),

            _buildResourceButtonModern(
              icon: Icons.school_rounded,
              label: isArabic ? "مواد تعليمية" : "Educational Resources",
            ),

            const SizedBox(height: 16),
            Text(
              isArabic
                  ? "تحتاج مساعدة؟ يمكنك دائماً سؤال روبوت الدليل من الأسفل."
                  : "Need help? You can always ask the Robo-Guide from below.",
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TEXT FIELD ---------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isArabic,
    required ColorScheme colorScheme,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            isArabic ? null : Icon(icon, color: colorScheme.primary),
        suffixIcon:
            isArabic ? Icon(icon, color: colorScheme.primary) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2.0,
          ),
        ),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
      ),
    );
  }

  // RESOURCE BUTTON ----------------------------------------------
  Widget _buildResourceButtonModern({
    required IconData icon,
    required String label,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Navigating to: $label")));
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: _primaryBlue.withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple tag chip used at top of the form
class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
