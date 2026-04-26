import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../models/user_preferences.dart';
import '../../models/auth_provider.dart';
import '../../models/ticket_provider.dart';
import '../../models/tour_package.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../screens/tickets/qr_scanner_screen.dart';
import '../../widgets/bottom_nav.dart';
import '../../models/app_session_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/text_styles.dart';
import '../../core/notifications/notification_trigger_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  TourPackage? _selectedPackage;
  DateTime _selectedDate = DateTime.now();
  final String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  final int _visitorCount = 1;

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

  Future<void> _handleCheckout(bool isArabic) async {
    final l10n = AppLocalizations.of(context)!;
    final sessionProvider = Provider.of<AppSessionProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "يرجى اختيار باقة للمتابعة."
                : "Please select a package to continue.",
          ),
        ),
      );
      return;
    }

    // Check if user is logged in
    if (!authProvider.isLoggedIn) {
      _showAccountRequiredDialog(context);
      return;
    }

    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    // Buy the package
    ticketProvider.buyPackage(
      userId: authProvider.currentUser!.id,
      package: _selectedPackage!,
      visitDate: _selectedDate,
      timeSlot: _selectedTimeSlot,
      visitorCount: _visitorCount,
    );

    // Update session provider
    sessionProvider.setTicketStates(
      museumState: _selectedPackage!.includesMuseumEntry
          ? MuseumTicketState.active
          : MuseumTicketState.none,
      robotState: _selectedPackage!.includesRobotTour
          ? RobotTourTicketState.available
          : RobotTourTicketState.none,
    );

    final shortDate = DateFormat('d MMM yyyy').format(_selectedDate);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.ticketConfirmation,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: _PurchaseConfirmationDialog(
            isArabic: isArabic,
            package: _selectedPackage!,
            shortDate: shortDate,
            onGoToTickets: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
              // Schedule ticket reminder notification for visit day
              NotificationTriggerService().triggerTicketReminder(
                title: "Your Museum Visit Today",
                body: "Don't forget your tickets for today!",
                reminderTime: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  9,
                  0, // 9 AM on visit day
                ),
              );
            },
            onStartTourSetup: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              if (sessionProvider.canStartRobotTour) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.qrScan,
                  arguments: QRScanMode.robotConnection,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isArabic
                          ? "هذه التذكرة لا تشمل جولة الروبوت."
                          : "This ticket does not include a robot guided tour.",
                    ),
                  ),
                );
              }
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

    final String formattedDateEn = DateFormat(
      'EEEE, MMM d, yyyy',
    ).format(_selectedDate);
    final String formattedDateAr = DateFormat.yMMMMEEEEd(
      'ar',
    ).format(_selectedDate);
    final String formattedDate = isArabic ? formattedDateAr : formattedDateEn;

    return AppMenuShell(
      title: (isArabic ? "شراء التذاكر" : "Buy tickets").toUpperCase(),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      backgroundColor: AppColors.darkBackground,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.myTickets),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cinematicCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.darkBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryGold.withOpacity(
                            0.12,
                          ),
                          child: const Icon(
                            Icons.museum_outlined,
                            color: AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? "تذاكر المتحف" : "Museum Tickets",
                                style: AppTextStyles.titleMedium(
                                  context,
                                ).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? "احجز تذاكرك قبل الوصول لتوفير الوقت."
                                    : "Book your tickets early to save time.",
                                style: AppTextStyles.metadata(
                                  context,
                                ).copyWith(fontSize: 13),
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
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.darkDivider),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              formattedDate,
                              style: AppTextStyles.bodyPrimary(context)
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          Text(
                            isArabic ? "تغيير" : "Change",
                            style: AppTextStyles.displaySectionTitle(
                              context,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Museum Entry Section
                  Text(
                    isArabic ? "دخول المتحف" : "Museum Entry",
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 16),
                  _buildPackageCard(
                    TourPackage.mockPackages[0], // Museum Entry Only
                    isArabic,
                  ),

                  const SizedBox(height: 32),

                  // Horus-Bot Guided Tours Section
                  Text(
                    isArabic ? "جولات حورس-بوت" : "Horus-Bot Guided Tours",
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 16),
                  _buildPackageCard(
                    TourPackage.mockPackages[1], // Robot Tour Only
                    isArabic,
                  ),

                  const SizedBox(height: 32),

                  // Complete Experience Section
                  Text(
                    isArabic ? "التجربة الكاملة" : "Complete Experience",
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 16),
                  _buildPackageCard(
                    TourPackage.mockPackages[2], // Complete Bundle
                    isArabic,
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cinematicNav,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isArabic ? "المجموع" : "Total",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 13),
                      ),
                      Text(
                        "\$${_selectedPackage?.price.toStringAsFixed(2) ?? '0.00'}",
                        style: AppTextStyles.titleLarge(
                          context,
                        ).copyWith(fontSize: 24, color: AppColors.primaryGold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedPackage != null
                            ? () => _handleCheckout(isArabic)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.darkInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isArabic ? "متابعة" : "Continue",
                          style: AppTextStyles.buttonLabel(
                            context,
                          ).copyWith(fontSize: 16),
                        ),
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

  Widget _buildPackageCard(TourPackage package, bool isArabic) {
    final isSelected = _selectedPackage?.id == package.id;

    return InkWell(
      onTap: () => setState(() => _selectedPackage = package),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold.withOpacity(0.5)
                : AppColors.darkBorder,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isArabic ? package.name : package.name,
                            style: AppTextStyles.titleMedium(
                              context,
                            ).copyWith(fontSize: 16, color: Colors.white),
                          ),
                          if (package.recommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isArabic ? "موصى بها" : "Recommended",
                                style: AppTextStyles.metadata(context).copyWith(
                                  fontSize: 10,
                                  color: AppColors.primaryGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic ? package.subtitle : package.subtitle,
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 12, color: AppColors.helperText),
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$${package.price.toStringAsFixed(2)}",
                  style: AppTextStyles.titleMedium(context).copyWith(
                    fontSize: 18,
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: package.includedFeatures.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(16),
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
            if (!package.includesMuseumEntry) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? "تتطلب تذكرة دخول صالحة للمتحف"
                            : "Requires valid museum entry ticket",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (package.includesRobotTour) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.smart_toy_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic
                            ? "امسح رمز QR على الروبوت لبدء الجولة"
                            : "Scan robot QR to start guided tour",
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAccountRequiredDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountRequired),
        content: Text(l10n.accountRequiredForPurchase),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.continueAsGuest),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(l10n.login),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.register);
            },
            child: Text(l10n.createAccount),
          ),
        ],
      ),
    );
  }
}

class _PurchaseConfirmationDialog extends StatelessWidget {
  final bool isArabic;
  final TourPackage package;
  final String shortDate;
  final VoidCallback onGoToTickets;
  final VoidCallback onStartTourSetup;

  const _PurchaseConfirmationDialog({
    required this.isArabic,
    required this.package,
    required this.shortDate,
    required this.onGoToTickets,
    required this.onStartTourSetup,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: AppColors.primaryGold.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? "تم تأكيد الشراء" : "Purchase Confirmed",
              style: AppTextStyles.displayScreenTitle(
                context,
              ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "تم شراء ${package.name} ليوم $shortDate."
                  : "${package.name} purchased for $shortDate.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: AppColors.helperText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "ما تم شراؤه:" : "What's included:",
                    style: AppTextStyles.titleMedium(
                      context,
                    ).copyWith(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  if (package.includesMuseumEntry)
                    _buildIncludedItem(
                      isArabic ? "تذكرة دخول المتحف" : "Museum Entry Ticket",
                      Icons.museum_outlined,
                      Colors.blue,
                    ),
                  if (package.includesRobotTour)
                    _buildIncludedItem(
                      isArabic ? "تذكرة جولة الروبوت" : "Robot Tour Ticket",
                      Icons.smart_toy_outlined,
                      Colors.green,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onGoToTickets,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isArabic ? "عرض تذاكري" : "View My Tickets",
                  style: AppTextStyles.buttonLabel(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: onStartTourSetup,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primaryGold,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  foregroundColor: AppColors.primaryGold,
                ),
                child: Text(
                  isArabic ? "إعداد الجولة" : "Start Tour Setup",
                  style: AppTextStyles.buttonLabel(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isArabic ? "إغلاق" : "Close",
                style: AppTextStyles.metadata(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncludedItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
