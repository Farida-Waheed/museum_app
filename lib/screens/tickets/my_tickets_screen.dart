import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final theme = Theme.of(context);

    // Mock Purchased Tickets (replace later with real data)
    final tickets = [
      {
        'id': 'TKT-8923-AD',
        'date': '2025-12-24',
        'typeEn': 'Adult',
        'typeAr': 'بالغ',
        'price': 20.0,
        'status': 'active',
      },
      {
        'id': 'TKT-8924-CH',
        'date': '2025-12-24',
        'typeEn': 'Child',
        'typeAr': 'طفل',
        'price': 10.0,
        'status': 'active',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      appBar: AppBar(
        title: Text(
          isArabic ? "تذاكري" : "My tickets",
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: tickets.isEmpty
          ? _buildEmptyState(isArabic, theme)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final t = tickets[index];
                return _buildTicketCard(context, t, isArabic, theme);
              },
            ),
    );
  }

  // -------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------
  Widget _buildEmptyState(bool isArabic, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? "لا توجد تذاكر بعد" : "No tickets yet",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "عند شراء تذاكر من شاشة الحجز، ستظهر هنا لعرضها عند الدخول."
                  : "When you buy tickets from the booking screen, they will appear here for entry.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // TICKET CARD
  // -------------------------------------------------------
  Widget _buildTicketCard(
    BuildContext context,
    Map<String, dynamic> ticket,
    bool isArabic,
    ThemeData theme,
  ) {
    final String type =
        isArabic ? (ticket['typeAr'] as String) : (ticket['typeEn'] as String);

    final String dateStr = ticket['date'] as String;
    final DateTime? date =
        DateTime.tryParse(dateStr); // from "2025-12-24" style

    String formattedDate;
    if (date != null) {
      formattedDate = isArabic
          ? "${date.day}-${date.month}-${date.year}"
          : "${date.day}/${date.month}/${date.year}";
    } else {
      formattedDate = dateStr;
    }

    final double price = ticket['price'] as double;
    final String status = ticket['status'] as String;

    final bool isActive = status == 'active';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // TOP ROW: icon + title + date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.museum_outlined,
                    color: theme.colorScheme.primary,
                    size: 24,
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
                            ? "تذكرة دخول المتحف"
                            : "Museum entry ticket",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$type • $formattedDate",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        textAlign:
                            isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            const SizedBox(height: 8),

            // MIDDLE: ID + price + status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? "معرّف التذكرة" : "Ticket ID",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket['id'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isArabic ? "السعر" : "Price",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive
                            ? Icons.check_circle_outline
                            : Icons.history_toggle_off,
                        size: 16,
                        color: isActive ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isArabic
                            ? (isActive ? "سارية" : "منتهية")
                            : (isActive ? "Active" : "Expired"),
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.green : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // QR placeholder
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 28,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? "إظهار رمز الدخول" : "Show entry code",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
