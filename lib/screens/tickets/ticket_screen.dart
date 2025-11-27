import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Needed for modern date formatting

import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart'; // <-- USE GLOBAL NAV BAR

// Define a modern primary color for the app
const Color _kPrimaryColor = Color(0xFF1E88E5); // A vibrant Blue/Indigo
const Color _kPrimaryLight = Color(0xFF64B5F6);

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final Map<String, double> _prices = {
    'Adult': 20.0,
    'Student': 15.0,
    'Child': 10.0,
  };

  final Map<String, int> _quantities = {
    'Adult': 1,
    'Student': 0,
    'Child': 0,
  };

  DateTime _selectedDate = DateTime.now();

  double get _totalPrice {
    double total = 0;
    _quantities.forEach((type, qty) {
      total += _prices[type]! * qty;
    });
    return total;
  }

  int get _totalTickets {
    int total = 0;
    _quantities.forEach((_, qty) => total += qty);
    return total;
  }

  // UPDATED: Use a modern date picker theme
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Extended range
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _kPrimaryColor,
            colorScheme: const ColorScheme.light(primary: _kPrimaryColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _updateQuantity(String type, int change) {
    final newQty = _quantities[type]! + change;
    if (newQty >= 0) {
      setState(() => _quantities[type] = newQty);
    }
  }

  void _handleCheckout(bool isArabic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? "تم الشراء بنجاح! التذاكر محفوظة."
              : "Purchase successful! Tickets saved.",
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to My Tickets screen
    Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      backgroundColor: Colors.grey[50], // Very subtle background tone

      bottomNavigationBar: const BottomNav(currentIndex: 3),

      appBar: AppBar(
        title: Text(
          isArabic ? "شراء التذاكر" : "Buy Tickets",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1, // Slight elevation on the AppBar
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet, color: _kPrimaryColor),
            tooltip: isArabic ? "تذاكري" : "My Tickets",
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.myTickets),
          )
        ],
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
                  // --- HERO / INTRO SECTION ---
                  _buildHeroHeader(isArabic),
                  const SizedBox(height: 24),

                  // --- DATE SELECTION CARD (Modernized) ---
                  _buildSectionTitle(
                      isArabic ? "تاريخ الزيارة" : "Visit Date"),
                  const SizedBox(height: 12),
                  _buildDateSelectionCard(isArabic),

                  const SizedBox(height: 32),

                  // --- TICKET TYPES (Modernized) ---
                  _buildSectionTitle(
                      isArabic ? "أنواع التذاكر" : "Ticket Types"),
                  const SizedBox(height: 16),

                  _ticketRow(
                    "Adult",
                    isArabic ? "بالغ" : "Adult",
                    "\$20",
                    isArabic,
                    isPopular: true,
                  ),
                  const SizedBox(height: 10),
                  _ticketRow(
                    "Student",
                    isArabic ? "طالب" : "Student",
                    "\$15",
                    isArabic,
                  ),
                  const SizedBox(height: 10),
                  _ticketRow(
                    "Child",
                    isArabic ? "طفل" : "Child",
                    "\$10",
                    isArabic,
                  ),

                  const SizedBox(height: 24),

                  // SUMMARY CARD
                  _buildSummaryCard(isArabic),
                  const SizedBox(height: 16),

                  // INFO + ROBO TIP
                  _buildInfoCard(
                    icon: Icons.info_outline,
                    text: isArabic
                        ? "الأطفال دون سن 5 سنوات مجاناً."
                        : "Children under 5 enter for free.",
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isArabic
                        ? "🤖 تلميح: يمكن للروبوت مساعدتك في اختيار أفضل وقت للزيارة."
                        : "🤖 Tip: The Robo-Guide can help you choose the best time to visit.",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CHECKOUT BAR ---
          _buildCheckoutBar(isArabic),
        ],
      ),
    );
  }

  // CUSTOM WIDGETS ---------------------------------------------------

  // Consistent title style
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // HERO HEADER -----------------------------------------
  Widget _buildHeroHeader(bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.confirmation_number_rounded,
                color: _kPrimaryColor,
                size: 26,
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
                    isArabic ? "خطط زيارتك" : "Plan Your Visit",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isArabic
                        ? "اختر التاريخ وعدد التذاكر لجولتك في المتحف."
                        : "Choose your visit date and ticket types for the museum tour.",
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
    );
  }

  // UPDATED: Modern Date Selection Card (Arabic-aware)
  Widget _buildDateSelectionCard(bool isArabic) {
    final String formattedDateEn =
        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);
    final String formattedDateAr =
        DateFormat.yMMMMEEEEd('ar').format(_selectedDate);

    final String formattedDate =
        isArabic ? formattedDateAr : formattedDateEn;

    return Card(
      elevation: 2, // Subtle elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: _kPrimaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Use a TextButton for a cleaner look than a bordered button
              TextButton(
                onPressed: _selectDate,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isArabic ? "تغيير" : "Change",
                  style: const TextStyle(
                    color: _kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Ticket Row - cleaner, with “Most popular” and selected tint
  Widget _ticketRow(
    String typeKey,
    String label,
    String price,
    bool isArabic, {
    bool isPopular = false,
  }) {
    final int qty = _quantities[typeKey]!;
    final bool isSelected = qty > 0;

    return Card(
      elevation: isSelected ? 2 : 1, // Slightly more lift when selected
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isSelected
          ? _kPrimaryColor.withValues(alpha: 0.04)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // LABEL + PRICE + OPTIONAL CHIP
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: isArabic
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _kPrimaryLight.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? "الأكثر شهرة" : "Most popular",
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // UPDATED: SLEEK COUNTER
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100], // Slight contrast
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCounterButton(
                    icon: Icons.remove,
                    onPressed: qty > 0
                        ? () => _updateQuantity(typeKey, -1)
                        : null,
                    isMinus: true,
                  ),
                  Container(
                    width: 30,
                    alignment: Alignment.center,
                    child: Text(
                      "$qty",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCounterButton(
                    icon: Icons.add,
                    onPressed: () => _updateQuantity(typeKey, 1),
                    isMinus: false,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper for the modern counter button style
  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isMinus,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      color: onPressed == null
          ? Colors.grey[400]
          : (isMinus ? Colors.black87 : _kPrimaryColor),
    );
  }

  // SUMMARY CARD ------------------------------------------------
  Widget _buildSummaryCard(bool isArabic) {
    final String shortDate =
        DateFormat('d MMM yyyy').format(_selectedDate);

    final String summaryText = _totalTickets > 0
        ? (isArabic
            ? "$_totalTickets تذكرة • $shortDate"
            : "$_totalTickets ticket(s) • $shortDate")
        : (isArabic
            ? "لم تقم باختيار أي تذاكر بعد."
            : "No tickets selected yet.");

    final String hintText = _totalTickets > 0
        ? (isArabic
            ? "جاهز للدفع عندما تكون مستعداً."
            : "You’re ready to checkout when you’re ready.")
        : (isArabic
            ? "اختر نوعاً واحداً على الأقل من التذاكر للمتابعة."
            : "Select at least one ticket type to continue.");

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimaryColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _totalTickets > 0
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: _totalTickets > 0 ? Colors.green : _kPrimaryColor,
                size: 20,
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
                    summaryText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hintText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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

  // UPDATED: Info Card - Slightly refined style
  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kPrimaryColor.withValues(alpha: 0.08), // Use primary color accent
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _kPrimaryColor.withValues(alpha: 0.15),
        ), // Subtle border
      ),
      child: Row(
        children: [
          Icon(icon, color: _kPrimaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _kPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHECKOUT BAR - Refined Total display + subtle animation
  Widget _buildCheckoutBar(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false, // Ensure button is not padded by the top of the safe area
        child: Row(
          children: [
            Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "المجموع" : "Total",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "\$${_totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26, // Larger total price
                    fontWeight: FontWeight.bold,
                    color: _kPrimaryColor,
                  ),
                )
              ],
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _totalPrice > 0 ? 1.0 : 0.5,
              child: SizedBox(
                height: 54, // Consistent button height
                child: ElevatedButton.icon(
                  onPressed: _totalPrice > 0
                      ? () => _handleCheckout(isArabic)
                      : null,
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                  label: Text(
                    isArabic ? "دفع الآن" : "Checkout",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
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
