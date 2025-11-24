import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // State Variables
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

    // Simulate backend delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _submitted = false;
          _rating = 0;
          _nameController.clear();
          _emailController.clear();
          _commentController.clear();
        });
      }
    });
  }

  // Helper for Star Labels
  String _getRatingLabel(int star, bool isArabic) {
    switch (star) {
      case 5: return isArabic ? "ممتاز!" : "Excellent!";
      case 4: return isArabic ? "عظيم!" : "Great!";
      case 3: return isArabic ? "جيد" : "Good";
      case 2: return isArabic ? "مقبول" : "Fair";
      case 1: return isArabic ? "سيء" : "Poor";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "الملاحظات" : "Feedback"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _submitted 
          ? _buildSuccessCard(isArabic) 
          : _buildFormCard(isArabic),
      ),
    );
  }

  // --- 1. Success View ---
  Widget _buildSuccessCard(bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? "شكراً لك!" : "Thank You!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic 
                ? "تم استلام ملاحظاتك بنجاح. نحن نقدر وقتك!"
                : "Your feedback has been submitted successfully. We appreciate your time!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Form View ---
  Widget _buildFormCard(bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              isArabic ? "أرسل ملاحظاتك" : "Submit Feedback",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic 
                ? "ساعدنا في تحسين تجربة المتحف من خلال مشاركة أفكارك."
                : "Help us improve your museum experience by sharing your thoughts.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            
            const SizedBox(height: 24),

            // Star Rating
            Text(isArabic ? "التقييم" : "Rating", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: starIndex <= _rating ? Colors.amber : Colors.grey[300],
                    size: 32,
                  ),
                  onPressed: () => setState(() => _rating = starIndex),
                );
              }),
            ),
            if (_rating > 0)
              Text(
                _getRatingLabel(_rating, isArabic),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),

            const SizedBox(height: 24),

            // Inputs
            _buildTextField(
              controller: _nameController,
              label: isArabic ? "الاسم (اختياري)" : "Your Name (Optional)",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: isArabic ? "البريد الإلكتروني (اختياري)" : "Your Email (Optional)",
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

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _rating == 0 ? null : _handleSubmit,
                icon: const Icon(Icons.send, size: 18),
                label: Text(isArabic ? "إرسال" : "Submit"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // --- 3. Post-Visit Resources ---
            Text(
              isArabic ? "مصادر ما بعد الزيارة" : "Post-Visit Resources",
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
              label: isArabic ? "مواد قراءة إضافية" : "Additional Reading Materials",
            ),
            const SizedBox(height: 12),
            _buildResourceButton(
              icon: Icons.school,
              label: isArabic ? "موارد تعليمية" : "Educational Resources",
            ),
          ],
        ),
      ),
    );
  }

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildResourceButton({required IconData icon, required String label}) {
    return OutlinedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloading resource..."))
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}