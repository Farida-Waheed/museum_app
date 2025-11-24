import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../widgets/bottom_nav.dart';   // <-- USE GLOBAL NAV BAR

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
      backgroundColor: Colors.grey[100],

      // 🔥 USE GLOBAL NAV BAR (index = 3)
      bottomNavigationBar: const BottomNav(currentIndex: 3),

      appBar: AppBar(
        title: Text(
          isArabic ? "تذاكري" : "My Tickets",
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          return _buildTicketCard(context, tickets[index], isArabic);
        },
      ),
    );
  }

  // -------------------------------------------------------
  // TICKET CARD
  // -------------------------------------------------------
  Widget _buildTicketCard(
      BuildContext context, Map<String, String> ticket, bool isArabic) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // --- TOP PART ---
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
                      child: const Icon(Icons.museum_outlined,
                          color: Colors.blue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? "تذكرة دخول المتحف"
                                : "Museum Entry Ticket",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${ticket['type']} • ${ticket['date']}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- DIVIDER WITH CUTOUTS ---
              Stack(
                children: [
                  const Divider(height: 1, color: Colors.grey),
                  Positioned(
                    left: -10,
                    top: -10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.grey[100], shape: BoxShape.circle),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Colors.grey[100], shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),

              // --- BOTTOM PART ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // QR TEXT + ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? "امسح للدخول" : "Scan to Enter",
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket['id']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    // QR CODE
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: Colors.grey.shade200, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${ticket['id']}",
                        width: 60,
                        height: 60,
                        loadingBuilder: (c, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                          );
                        },
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.qr_code_2, size: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
