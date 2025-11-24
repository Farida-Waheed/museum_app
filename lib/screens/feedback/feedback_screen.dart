import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _submitted = false;
        _rating = 0;
        _nameController.clear();
        _emailController.clear();
        _commentController.clear();
      });
    });
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

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ✅ USE GLOBAL NAVBAR — NO DUPLICATE CODE
      bottomNavigationBar: const BottomNav(currentIndex: 4),

      appBar: AppBar(
        title: Text(isArabic ? "الملاحظات" : "Feedback",
            style: const TextStyle(color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _submitted ? _buildSuccessCard(isArabic) : _buildFormCard(isArabic),
        ],
      ),
    );
  }

  // SUCCESS CARD ------------------------------------
  Widget _buildSuccessCard(bool isArabic) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.7),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                isArabic ? "شكراً لك!" : "Thank You!",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                isArabic
                    ? "تم استلام ملاحظاتك. نحن نقدر وقتك!"
                    : "Your feedback was received. We appreciate your time!",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              )
            ],
          ),
        ),
      ),
    );
  }

  // FORM CARD ------------------------------------
  Widget _buildFormCard(bool isArabic) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.75),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? "أرسل ملاحظاتك" : "Submit Feedback",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? "ساعدنا في تحسين تجربتك في المتحف."
                    : "Help us improve your museum experience.",
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // STAR RATING
              Text(
                isArabic ? "التقييم" : "Rating",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  final s = index + 1;
                  return IconButton(
                    icon: Icon(
                      s <= _rating ? Icons.star : Icons.star_border,
                      color: s <= _rating ? Colors.amber : Colors.grey[300],
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = s),
                  );
                }),
              ),

              if (_rating > 0)
                Text(
                  _getRatingLabel(_rating, isArabic),
                  style: const TextStyle(color: Colors.black54),
                ),

              const SizedBox(height: 24),

              _buildTextField(
                controller: _nameController,
                label: isArabic ? "الاسم (اختياري)" : "Name (Optional)",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: isArabic ? "البريد الإلكتروني (اختياري)" : "Email (Optional)",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _commentController,
                label: isArabic ? "التعليقات" : "Comments",
                icon: Icons.comment_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _rating == 0 ? null : _handleSubmit,
                  icon: const Icon(Icons.send),
                  label: Text(isArabic ? "إرسال" : "Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(),

              // RESOURCES
              const SizedBox(height: 20),

              Text(
                isArabic ? "مصادر إضافية" : "Extra Resources",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _buildResourceButton(
                icon: Icons.download,
                label: isArabic ? "تحميل ملخص الزيارة" : "Download Visit Summary",
              ),
              const SizedBox(height: 12),

              _buildResourceButton(
                icon: Icons.menu_book,
                label: isArabic ? "قراءة إضافية" : "Additional Reading",
              ),
              const SizedBox(height: 12),

              _buildResourceButton(
                icon: Icons.school,
                label: isArabic ? "مواد تعليمية" : "Educational Resources",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CUSTOM WIDGETS ------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildResourceButton({required IconData icon, required String label}) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(label)));
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
