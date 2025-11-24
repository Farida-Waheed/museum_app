import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // Mock Purchased Tickets
    final tickets = [
      {
        'id': 'TKT-8923-AD',
        'date': '2023-12-24',
        'type': isArabic ? 'بالغ' : 'Adult',
        'price': '\$20.00',
      },
      {
        'id': 'TKT-8924-CH',
        'date': '2023-12-24',
        'type': isArabic ? 'طفل' : 'Child',
        'price': '\$10.00',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "تذاكري" : "My Tickets"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return _buildTicketCard(context, tickets[index], isArabic);
        },
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, String> ticket, bool isArabic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        children: [
          // --- Top Part (Info) ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.museum_outlined, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? "تذكرة دخول المتحف" : "Museum Entry Ticket",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${ticket['type']} • ${ticket['date']}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Divider with Cutouts ---
          Stack(
            children: [
              const Divider(height: 1, color: Colors.grey),
              Positioned(
                left: -10,
                top: -10,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                ),
              ),
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                ),
              ),
            ],
          ),

          // --- Bottom Part (QR Code) ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "امسح للدخول" : "Scan to Enter",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket['id']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                    ),
                  ],
                ),
                // QR Code generated from Network API (No plugin needed)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${ticket['id']}",
                    width: 60,
                    height: 60,
                    loadingBuilder: (c, child, p) {
                      if (p == null) return child;
                      return Container(width: 60, height: 60, color: Colors.grey[100]);
                    },
                    errorBuilder: (c, e, s) => const Icon(Icons.qr_code_2, size: 60),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}