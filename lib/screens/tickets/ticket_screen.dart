import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../models/user_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/text_styles.dart';
import '../../core/notifications/notification_trigger_service.dart';

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

  final Map<String, int> _quantities = {'Adult': 1, 'Student': 0, 'Child': 0};

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
    final l10n = AppLocalizations.of(context)!;
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
      barrierLabel: l10n.ticketConfirmation,
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

              // Schedule ticket reminder notification for visit day
              NotificationTriggerService().triggerTicketReminder(
                title: "Your Museum Visit Today",
                body: "Don't forget your tickets for today!",
                reminderTime: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  9, 0, // 9 AM on visit day
                ),
              );
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
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryGold.withOpacity(
                            0.1,
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

                  // Ticket Types
                  Text(
                    isArabic ? "أنواع التذاكر" : "Ticket Types",
                    style: AppTextStyles.displaySectionTitle(context),
                  ),
                  const SizedBox(height: 16),
                  _ticketRow(
                    "Adult",
                    isArabic ? "بالغ" : "Adult",
                    isArabic ? "١٢+ سنة" : "Ages 12+",
                    _prices["Adult"]!,
                    isArabic,
                  ),
                  const SizedBox(height: 12),
                  _ticketRow(
                    "Student",
                    isArabic ? "طالب" : "Student",
                    isArabic ? "مع بطاقة سارية" : "With valid ID",
                    _prices["Student"]!,
                    isArabic,
                  ),
                  const SizedBox(height: 12),
                  _ticketRow(
                    "Child",
                    isArabic ? "طفل" : "Child",
                    isArabic ? "٥-١١ سنة" : "Ages 5-11",
                    _prices["Child"]!,
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
              color: AppColors.darkHeader,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
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
                        "\$${_totalPrice.toStringAsFixed(2)}",
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
                        onPressed: _totalPrice > 0
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

  Widget _ticketRow(
    String typeKey,
    String label,
    String subtitle,
    double price,
    bool isArabic,
  ) {
    final qty = _quantities[typeKey]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: qty > 0
              ? AppColors.primaryGold.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          if (qty > 0)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.metadata(context).copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${price.toStringAsFixed(2)}",
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 20),
                  onPressed: qty > 0
                      ? () => _updateQuantity(typeKey, -1)
                      : null,
                  color: qty > 0 ? Colors.white70 : Colors.white24,
                ),
                SizedBox(
                  width: 24,
                  child: Text(
                    "$qty",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () => _updateQuantity(typeKey, 1),
                  color: AppColors.primaryGold,
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
              isArabic ? "تم تأكيد التذاكر" : "Tickets Confirmed",
              style: AppTextStyles.displayScreenTitle(
                context,
              ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? "حجزنا لك $totalTickets تذكرة ليوم $shortDate."
                  : "Reserved $totalTickets ticket(s) for $shortDate.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: AppColors.helperText,
                fontSize: 15,
                height: 1.4,
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
}
