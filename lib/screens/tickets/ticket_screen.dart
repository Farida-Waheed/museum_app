import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';

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
              Navigator.of(ctx, rootNavigator: true).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
            },
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
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

    final String formattedDateEn = DateFormat('EEEE, MMM d, yyyy').format(_selectedDate);
    final String formattedDateAr = DateFormat.yMMMMEEEEd('ar').format(_selectedDate);
    final String formattedDate = isArabic ? formattedDateAr : formattedDateEn;

    return AppMenuShell(
      title: isArabic ? "شراء التذاكر" : "Buy tickets",
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      backgroundColor: const Color(0xFFF8FAFC),
      actions: [
        IconButton(
          icon: const Icon(Icons.confirmation_number_outlined, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.museum_outlined, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? "تذاكر المتحف" : "Museum Tickets",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic ? "احجز تذاكرك قبل الوصول لتوفير الوقت." : "Book your tickets early to save time.",
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Date Selector
                  Text(
                    isArabic ? "اختر التاريخ" : "Select Date",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            isArabic ? "تغيير" : "Change",
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Ticket Types
                  Text(
                    isArabic ? "أنواع التذاكر" : "Ticket Types",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  _ticketRow("Adult", isArabic ? "بالغ" : "Adult", isArabic ? "١٢+ سنة" : "Ages 12+", _prices["Adult"]!, isArabic),
                  const SizedBox(height: 12),
                  _ticketRow("Student", isArabic ? "طالب" : "Student", isArabic ? "مع بطاقة سارية" : "With valid ID", _prices["Student"]!, isArabic),
                  const SizedBox(height: 12),
                  _ticketRow("Child", isArabic ? "طفل" : "Child", isArabic ? "٥-١١ سنة" : "Ages 5-11", _prices["Child"]!, isArabic),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isArabic ? "المجموع" : "Total", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      Text("\$${_totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _totalPrice > 0 ? () => _handleCheckout(isArabic) : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(isArabic ? "متابعة" : "Continue", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRow(String typeKey, String label, String subtitle, double price, bool isArabic) {
    final qty = _quantities[typeKey]!;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: qty > 0 ? primary.withOpacity(0.3) : Colors.grey.shade100),
        boxShadow: [
          if (qty > 0) BoxShadow(color: primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text("\$${price.toStringAsFixed(2)}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 20),
                  onPressed: qty > 0 ? () => _updateQuantity(typeKey, -1) : null,
                  color: qty > 0 ? Colors.black87 : Colors.grey.shade300,
                ),
                SizedBox(width: 24, child: Text("$qty", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () => _updateQuantity(typeKey, 1),
                  color: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? "تم تأكيد التذاكر" : "Tickets Confirmed",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic ? "حجزنا لك $totalTickets تذكرة ليوم $shortDate." : "Reserved $totalTickets ticket(s) for $shortDate.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onGoToTickets,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(isArabic ? "عرض تذاكري" : "View My Tickets", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? "إغلاق" : "Close", style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
