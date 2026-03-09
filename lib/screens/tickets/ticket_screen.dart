import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // 👈 for sound + haptics

import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // In a real app these would probably come from an API.
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  Future<void> _handleCheckout(bool isArabic) async {
    if (_totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "اختر تذكرة واحدة على الأقل للمتابعة."
                : "Please select at least one ticket to continue.",
          ),
        ),
      );
      return;
    }

    // 🔊 Small system feedback so it feels "live"
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    final shortDate = DateFormat('d MMM yyyy').format(_selectedDate);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Ticket confirmation',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: _TicketConfirmationDialog(
            isArabic: isArabic,
            totalTickets: _totalTickets,
            totalPrice: _totalPrice,
            shortDate: shortDate,
            onGoToTickets: () {
              Navigator.of(ctx, rootNavigator: true).pop(); // close dialog
              Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
            },
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
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
    final isArabic = prefs.language == 'ar';
    final theme = Theme.of(context);

    final String formattedDateEn =
        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);
    final String formattedDateAr =
        DateFormat.yMMMMEEEEd('ar').format(_selectedDate);
    final String formattedDate =
        isArabic ? formattedDateAr : formattedDateEn;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      appBar: AppBar(
        title: Text(
          isArabic ? "شراء التذاكر" : "Buy tickets",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            tooltip: isArabic ? "تذاكري" : "My tickets",
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.myTickets),
          ),
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
                  // Simple hero / context card (no heavy animation)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.museum_rounded,
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
                                      ? "تذاكر المتحف"
                                      : "Museum tickets",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "احجز دخولك واختر نوع التذاكر قبل الوصول."
                                      : "Reserve your entry and choose ticket types before you arrive.",
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

                  const SizedBox(height: 24),

                  // Visit date
                  Text(
                    isArabic ? "تاريخ الزيارة" : "Visit date",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _selectDate,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: theme.colorScheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              isArabic ? "تغيير" : "Change",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ticket types
                  Text(
                    isArabic ? "أنواع التذاكر" : "Ticket types",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ticketRow(
                    typeKey: "Adult",
                    label: isArabic ? "بالغ" : "Adult",
                    subtitle: isArabic
                        ? "العمر ١٢ سنة فأكثر"
                        : "Ages 12+",
                    price: _prices["Adult"]!,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 10),
                  _ticketRow(
                    typeKey: "Student",
                    label: isArabic ? "طالب" : "Student",
                    subtitle: isArabic
                        ? "مع بطاقة طالب سارية"
                        : "With valid student ID",
                    price: _prices["Student"]!,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 10),
                  _ticketRow(
                    typeKey: "Child",
                    label: isArabic ? "طفل" : "Child",
                    subtitle: isArabic
                        ? "العمر من ٥ إلى ١١ سنة"
                        : "Ages 5–11",
                    price: _prices["Child"]!,
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    isArabic
                        ? "الأطفال دون سن ٥ سنوات يدخلون مجاناً مع شخص بالغ."
                        : "Children under 5 enter for free with an adult.",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: isArabic
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _totalTickets > 0
                                      ? (isArabic
                                          ? "$_totalTickets تذكرة محددة"
                                          : "$_totalTickets ticket(s) selected")
                                      : (isArabic
                                          ? "لم يتم اختيار تذاكر بعد"
                                          : "No tickets selected yet"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "يمكنك تعديل العدد في أي وقت قبل الدفع."
                                      : "You can adjust quantities before checkout.",
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
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar (total + button)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "\$${_totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _totalPrice > 0
                            ? () => _handleCheckout(isArabic)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isArabic ? "متابعة" : "Continue",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- UI pieces -------------------

  Widget _ticketRow({
    required String typeKey,
    required String label,
    required String subtitle,
    required double price,
    required bool isArabic,
  }) {
    final theme = Theme.of(context);
    final int qty = _quantities[typeKey]!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: qty > 0
              ? theme.colorScheme.primary.withOpacity(0.7)
              : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: qty > 0
                        ? () => _updateQuantity(typeKey, -1)
                        : null,
                    color: qty > 0 ? Colors.black87 : Colors.grey[400],
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      "$qty",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => _updateQuantity(typeKey, 1),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== Confirmation Dialog ===================

class _TicketConfirmationDialog extends StatelessWidget {
  final bool isArabic;
  final int totalTickets;
  final double totalPrice;
  final String shortDate;
  final VoidCallback onGoToTickets;

  const _TicketConfirmationDialog({
    required this.isArabic,
    required this.totalTickets,
    required this.totalPrice,
    required this.shortDate,
    required this.onGoToTickets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                radius: 30,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isArabic ? "تم تأكيد التذاكر" : "Tickets confirmed",
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
                    ? "حجزنا لك $totalTickets تذكرة ليوم $shortDate."
                    : "We’ve reserved $totalTickets ticket(s) for $shortDate.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "${isArabic ? "المجموع: " : "Total: "}\$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGoToTickets,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isArabic ? "عرض تذاكري" : "View my tickets",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Center(
                child: Text(
                  isArabic ? "إغلاق" : "Close",
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
