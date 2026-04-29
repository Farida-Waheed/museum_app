import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

import '../../models/user_preferences.dart';
import '../../models/auth_provider.dart';
import '../../models/ticket_provider.dart';
import '../../models/museum_ticket.dart';
import '../../models/robot_tour_ticket.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final isArabic = prefs.language == 'ar';
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // If not logged in, show login prompt
    if (!authProvider.isLoggedIn) {
      return AppMenuShell(
        title: (l10n.myTickets ?? "My Tickets").toUpperCase(),
        backgroundColor: AppColors.darkBackground,
        bottomNavigationBar: const BottomNav(currentIndex: 3),
        body: _buildLoginRequiredState(context, isArabic, l10n),
      );
    }

    final museumTickets = ticketProvider.museumTickets;
    final robotTourTickets = ticketProvider.robotTourTickets;

    return AppMenuShell(
      title: (l10n.myTickets ?? "My Tickets").toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: ticketProvider.hasTickets
          ? _buildTicketsView(
              context,
              museumTickets,
              robotTourTickets,
              isArabic,
              theme,
              l10n,
            )
          : _buildEmptyState(context, isArabic, theme, l10n),
    );
  }

  Widget _buildTicketsView(
    BuildContext context,
    List<MuseumTicket> museumTickets,
    List<RobotTourTicket> robotTourTickets,
    bool isArabic,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // Museum Entry Tickets Section
        if (museumTickets.isNotEmpty) ...[
          Text(
            isArabic ? "تذاكر دخول المتحف" : "Museum Entry Tickets",
            style: AppTextStyles.displaySectionTitle(context),
          ),
          const SizedBox(height: 16),
          ...museumTickets.map(
            (ticket) =>
                _buildMuseumTicketCard(context, ticket, l10n, isArabic, theme),
          ),
          const SizedBox(height: 32),
        ],

        // Robot Tour Tickets Section
        if (robotTourTickets.isNotEmpty) ...[
          Text(
            isArabic ? "تذاكر جولة حورس-بوت" : "Horus-Bot Tour Tickets",
            style: AppTextStyles.displaySectionTitle(context),
          ),
          const SizedBox(height: 16),
          ...robotTourTickets.map(
            (ticket) => _buildRobotTourTicketCard(
              context,
              ticket,
              l10n,
              isArabic,
              theme,
            ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------
  // LOGIN REQUIRED STATE
  // -------------------------------------------------------
  Widget _buildLoginRequiredState(
    BuildContext context,
    bool isArabic,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 48,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loginToViewTickets ?? "Log in to view your tickets",
              style: AppTextStyles.titleLarge(
                context,
              ).copyWith(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accountRequired ??
                  "Create an account or log in to save your tickets, payments, and robot tour access.",
              textAlign: TextAlign.center,
              style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(l10n.login ?? 'Login'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.register);
              },
              child: Text(l10n.createAccount ?? 'Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // EMPTY STATE
  // -------------------------------------------------------
  Widget _buildEmptyState(
    BuildContext context,
    bool isArabic,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
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
              style: AppTextStyles.titleLarge(
                context,
              ).copyWith(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "عند شراء تذاكر من شاشة الحجز، ستظهر هنا لعرضها عند الدخول."
                  : "When you buy tickets from the booking screen, they will appear here for entry.",
              textAlign: TextAlign.center,
              style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // MUSEUM TICKET CARD
  // -------------------------------------------------------
  Widget _buildMuseumTicketCard(
    BuildContext context,
    MuseumTicket ticket,
    AppLocalizations l10n,
    bool isArabic,
    ThemeData theme,
  ) {
    final formattedDate = isArabic
        ? "${ticket.visitDate.day}-${ticket.visitDate.month}-${ticket.visitDate.year}"
        : "${ticket.visitDate.day}/${ticket.visitDate.month}/${ticket.visitDate.year}";

    final bool isActive = ticket.status == TicketStatus.active;

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
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
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
                        isArabic ? "تذكرة دخول المتحف" : "Museum entry ticket",
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${l10n.visitDate}: $formattedDate",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 13),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      Text(
                        "${l10n.timeSlot}: ${ticket.timeSlot}",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 13),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ticket.id,
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
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "\$${ticket.price.toStringAsFixed(2)}",
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontSize: 14, color: AppColors.primaryGold),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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

                // QR code
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
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "استخدم هذا الرمز عند بوابة المتحف"
                  : "Use this QR at the museum entrance",
              style: AppTextStyles.metadata(
                context,
              ).copyWith(fontSize: 12, color: AppColors.helperText),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // ROBOT TOUR TICKET CARD
  // -------------------------------------------------------
  Widget _buildRobotTourTicketCard(
    BuildContext context,
    RobotTourTicket ticket,
    AppLocalizations l10n,
    bool isArabic,
    ThemeData theme,
  ) {
    final bool isActive = ticket.status == TicketStatus.active;

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
          crossAxisAlignment: isArabic
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // TOP ROW: icon + title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.blue,
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
                        ticket.packageName,
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${isArabic ? "المدة" : "Duration"}: ${ticket.durationMinutes} ${isArabic ? "دقيقة" : "minutes"}",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 13),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.darkDivider),

            const SizedBox(height: 8),

            // Features
            Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? "المميزات المشمولة" : "Included Features",
                  style: AppTextStyles.metadata(context).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: ticket.includedFeatures.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 11, color: Colors.white70),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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

                // Start Tour Setup button
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.tourCustomization,
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: Text(
                      isArabic ? "إعداد الجولة" : "Start Tour Setup",
                      style: AppTextStyles.buttonLabel(
                        context,
                      ).copyWith(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "امسح رمز QR الموجود على روبوت حورس-بوت للاتصال"
                  : "Scan the QR on the physical Horus-Bot robot to connect",
              style: AppTextStyles.metadata(
                context,
              ).copyWith(fontSize: 12, color: AppColors.helperText),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
