import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../app/router.dart'; // Import Router for navigation

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // Ticket Types & Prices
  final Map<String, double> _prices = {
    'Adult': 20.0,
    'Student': 15.0,
    'Child': 10.0,
  };

  // Selected Quantities
  final Map<String, int> _quantities = {
    'Adult': 1,
    'Student': 0,
    'Child': 0,
  };

  DateTime _selectedDate = DateTime.now();

  double get _totalPrice {
    double total = 0;
    _quantities.forEach((key, qty) {
      total += (_prices[key]! * qty);
    });
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateQuantity(String type, int change) {
    setState(() {
      int newQty = _quantities[type]! + change;
      if (newQty >= 0) {
        _quantities[type] = newQty;
      }
    });
  }

  void _handleCheckout(bool isArabic) {
    // 1. Show Success Message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? "تم الشراء بنجاح! التذاكر محفوظة." : "Purchase Successful! Tickets saved."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // 2. Navigate to Wallet (Replace current screen so back button goes Home)
    Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "شراء التذاكر" : "Buy Tickets"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        // --- NEW: Wallet Action Button ---
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Date Selector ---
                  Text(isArabic ? "تاريخ الزيارة" : "Visit Date", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Text(isArabic ? "تغيير" : "Change", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- 2. Ticket Types ---
                  Text(isArabic ? "أنواع التذاكر" : "Ticket Types", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTicketRow("Adult", isArabic ? "بالغ" : "Adult", "\$20", isArabic),
                  _buildTicketRow("Student", isArabic ? "طالب" : "Student", "\$15", isArabic),
                  _buildTicketRow("Child", isArabic ? "طفل" : "Child", "\$10", isArabic),
                  
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(child: Text(isArabic ? "الأطفال دون سن 5 سنوات مجاناً" : "Children under 5 enter for free.", style: TextStyle(color: Colors.blue[900]))),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // --- 3. Bottom Checkout Bar ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isArabic ? "المجموع" : "Total", style: const TextStyle(color: Colors.grey)),
                      Text(
                        "\$${_totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _totalPrice > 0 ? () => _handleCheckout(isArabic) : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(isArabic ? "دفع الآن" : "Checkout", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTicketRow(String typeKey, String label, String price, bool isArabic) {
    int qty = _quantities[typeKey]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(price, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => _updateQuantity(typeKey, -1),
                  color: qty > 0 ? Colors.black : Colors.grey,
                ),
                Container(
                  width: 30,
                  alignment: Alignment.center,
                  child: Text("$qty", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
}