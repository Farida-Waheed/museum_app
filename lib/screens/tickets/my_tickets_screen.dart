import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

import '../../models/user_preferences.dart';

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

    return AppMenuShell(
      title: (isArabic ? "تذاكري" : "My Tickets").toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: tickets.isEmpty
          ? _buildEmptyState(context, isArabic, theme)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
  Widget _buildEmptyState(BuildContext context, bool isArabic, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? "لا توجد تذاكر بعد" : "No tickets yet",
              style: AppTextStyles.titleLarge(context).copyWith(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "عند شراء تذاكر من شاشة الحجز، ستظهر هنا لعرضها عند الدخول."
                  : "When you buy tickets from the booking screen, they will appear here for entry.",
              textAlign: TextAlign.center,
              style: AppTextStyles.metadata(context).copyWith(
                fontSize: 13,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.museum_outlined,
                    color: AppColors.primaryGold,
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
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$type • $formattedDate",
                        style: AppTextStyles.metadata(context).copyWith(
                          fontSize: 13,
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
            const Divider(height: 1, color: AppColors.darkDivider),

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
                      style: AppTextStyles.metadata(context).copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket['id'] as String,
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: Colors.white,
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
                      style: AppTextStyles.metadata(context).copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: AppTextStyles.titleMedium(context).copyWith(
                        fontSize: 14,
                        color: AppColors.primaryGold,
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
                        : Colors.white.withOpacity(0.05),
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
                        color: isActive ? Colors.green : AppColors.helperText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isArabic
                            ? (isActive ? "سارية" : "منتهية")
                            : (isActive ? "Active" : "Expired"),
                        style: AppTextStyles.metadata(context).copyWith(
                          fontSize: 12,
                          color: isActive ? Colors.green : AppColors.helperText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // QR placeholder
                Row(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 28,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isArabic ? "إظهار رمز الدخول" : "Show entry code",
                      style: AppTextStyles.metadata(context).copyWith(
                        fontSize: 12,
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
