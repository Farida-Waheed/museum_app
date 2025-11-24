import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';   // <-- USE GLOBAL NAV BAR

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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

    Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔥 USE GLOBAL NAV BAR, NO DUPLICATES
      bottomNavigationBar: const BottomNav(currentIndex: 3),

      appBar: AppBar(
        title: Text(
          isArabic ? "شراء التذاكر" : "Buy Tickets",
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet, color: Colors.blue),
            tooltip: isArabic ? "تذاكري" : "My Tickets",
            onPressed: () => Navigator.pushNamed(context, AppRoutes.myTickets),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // --- DATE CARD ---
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? "تاريخ الزيارة" : "Visit Date",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.blue),
                                const SizedBox(width: 12),
                                Text(
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                  isArabic ? "تغيير" : "Change",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- TICKET TYPES ---
                  Text(
                    isArabic ? "أنواع التذاكر" : "Ticket Types",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _ticketRow("Adult", isArabic ? "بالغ" : "Adult", "\$20", isArabic),
                  _ticketRow(
                      "Student", isArabic ? "طالب" : "Student", "\$15", isArabic),
                  _ticketRow("Child", isArabic ? "طفل" : "Child", "\$10", isArabic),

                  const SizedBox(height: 20),

                  _buildInfoCard(
                    icon: Icons.info_outline,
                    text: isArabic
                        ? "الأطفال دون سن 5 سنوات مجاناً"
                        : "Children under 5 enter for free.",
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

  // GLASS CARD ---------------------------------------------------
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.75),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // TICKET ROW ---------------------------------------------------
  Widget _ticketRow(
      String typeKey, String label, String price, bool isArabic) {
    int qty = _quantities[typeKey]!;

    return _buildGlassCard(
      child: Row(
        children: [
          // LABEL + PRICE
          Column(
            crossAxisAlignment:
                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(price, style: TextStyle(color: Colors.grey[600])),
            ],
          ),

          const Spacer(),

          // COUNTER
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => _updateQuantity(typeKey, -1),
                  color: qty > 0 ? Colors.black : Colors.grey,
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    "$qty",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _updateQuantity(typeKey, 1),
                  color: Colors.blue,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // INFO CARD ----------------------------------------------------
  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // CHECKOUT BAR -------------------------------------------------
  Widget _buildCheckoutBar(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "المجموع" : "Total",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "\$${_totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  _totalPrice > 0 ? () => _handleCheckout(isArabic) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isArabic ? "دفع الآن" : "Checkout",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
