import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  static const List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '10:00 AM - 12:00 PM',
    '12:00 PM - 02:00 PM',
    '02:00 PM - 04:00 PM',
  ];

  Future<void> _selectDate(TicketProvider ticketProvider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ticketProvider.currentOrderDraft.visitDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ticketProvider.updateVisitDate(picked);
    }
  }

  Future<void> _checkout({
    required AuthProvider authProvider,
    required TicketProvider ticketProvider,
    required AppLocalizations l10n,
  }) async {
    if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ticketsLoginRequired)));
      return;
    }
    if (!ticketProvider.currentOrderDraft.hasMuseumEntry) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ticketsSelectMuseumEntryFirst)),
      );
      return;
    }
    if (!ticketProvider.isPersonalizedDraftComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ticketsCompletePersonalizedTourFirst)),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    final purchasedSet = await ticketProvider.checkoutFromDraft(
      userId: authProvider.currentUser!.id,
    );
    if (!mounted) return;
    if (purchasedSet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ticketProvider.ticketError ?? l10n.ticketsSelectMuseumEntryFirst,
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ticketsPurchaseComplete)));
    Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesModel>();
    final authProvider = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return AppMenuShell(
      title: 'HORUS-BOT',
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      backgroundColor: AppColors.baseBlack,
      hideDefaultAppBar: true,
      body: Builder(
        builder: (shellContext) => Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Stack(
            children: [
              authProvider.isLoggedIn
                  ? _buildPurchaseBuilder(
                      context,
                      ticketProvider,
                      authProvider,
                      l10n,
                      isArabic,
                    )
                  : _buildAccountGate(context, l10n, isArabic),
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: _TicketsHeader(
                  onMenu: () => AppMenuShell.of(shellContext)?.toggleMenu(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountGate(
    BuildContext context,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.screenBackground),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.fromSTEB(
            24,
            MediaQuery.paddingOf(context).top + 104,
            24,
            120,
          ),
          child: _GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.primaryGold,
                  size: 44,
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.ticketsAccountRequiredTitle,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.displayScreenTitle(
                    context,
                  ).copyWith(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.ticketsAccountRequiredBody,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.bodyText, height: 1.45),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _GoldButton(
                        label: l10n.login,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OutlineActionButton(
                        label: l10n.createAccount,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseBuilder(
    BuildContext context,
    TicketProvider ticketProvider,
    AuthProvider authProvider,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final draft = ticketProvider.currentOrderDraft;
    final formattedDate = isArabic
        ? DateFormat.yMMMMEEEEd('ar').format(draft.visitDate)
        : DateFormat('EEEE, MMM d, yyyy').format(draft.visitDate);

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.screenBackground),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsetsDirectional.fromSTEB(
                20,
                MediaQuery.paddingOf(context).top + 92,
                20,
                120,
              ),
              children: [
                _PageIntroCard(l10n: l10n, isArabic: isArabic),
                const SizedBox(height: 18),
                _VisitDetailsCard(
                  l10n: l10n,
                  formattedDate: formattedDate,
                  selectedTimeSlot: draft.timeSlot,
                  timeSlots: _timeSlots,
                  onDateTap: () => _selectDate(ticketProvider),
                  onTimeSlotChanged: ticketProvider.updateTimeSlot,
                  isArabic: isArabic,
                ),
                const SizedBox(height: 18),
                _MuseumEntryCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
                const SizedBox(height: 18),
                _RobotTourCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
                if (draft.robotTourType == RobotTourType.standard) ...[
                  const SizedBox(height: 18),
                  _StandardTourConfigCard(
                    l10n: l10n,
                    ticketProvider: ticketProvider,
                    isArabic: isArabic,
                  ),
                ],
                if (draft.robotTourType == RobotTourType.personalized) ...[
                  const SizedBox(height: 18),
                  _PersonalizedTourCard(l10n: l10n, isArabic: isArabic),
                ],
                const SizedBox(height: 18),
                _OrderSummaryCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  formattedDate: formattedDate,
                  isArabic: isArabic,
                ),
              ],
            ),
          ),
          _StickyCheckoutBar(
            l10n: l10n,
            ticketProvider: ticketProvider,
            onCheckout: () => _checkout(
              authProvider: authProvider,
              ticketProvider: ticketProvider,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketsHeader extends StatelessWidget {
  const _TicketsHeader({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: topPadding + 86,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 3, 16, 0),
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        _TicketsHeaderButton(
                          icon: Icons.menu_rounded,
                          onTap: onMenu,
                        ),
                        const Spacer(),
                        const SizedBox(width: 44, height: 44),
                      ],
                    ),
                    const IgnorePointer(child: _TicketsHeaderBrand()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketsHeaderBrand extends StatelessWidget {
  const _TicketsHeaderBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/icons/ankh.png', width: 18, height: 18),
        const SizedBox(width: 8),
        Text(
          'HORUS-BOT',
          style: AppTextStyles.premiumBrandTitle(context).copyWith(
            color: AppColors.primaryGold,
            fontSize: 17.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketsHeaderButton extends StatelessWidget {
  const _TicketsHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.cardGlass(0.48),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.goldBorder(0.18)),
          ),
          child: Icon(icon, color: AppColors.whiteTitle, size: 22),
        ),
      ),
    );
  }
}

class _PageIntroCard extends StatelessWidget {
  const _PageIntroCard({required this.l10n, required this.isArabic});

  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ticketsPlanVisitTitle,
            style: AppTextStyles.displayScreenTitle(
              context,
            ).copyWith(color: AppColors.primaryGold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ticketsPlanVisitSubtitle,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.bodyText, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _VisitDetailsCard extends StatelessWidget {
  const _VisitDetailsCard({
    required this.l10n,
    required this.formattedDate,
    required this.selectedTimeSlot,
    required this.timeSlots,
    required this.onDateTap,
    required this.onTimeSlotChanged,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final String formattedDate;
  final String selectedTimeSlot;
  final List<String> timeSlots;
  final VoidCallback onDateTap;
  final ValueChanged<String> onTimeSlotChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.ticketsVisitDetails,
      isArabic: isArabic,
      child: Column(
        children: [
          _TapRow(
            icon: Icons.calendar_today_rounded,
            label: l10n.visitDate,
            value: formattedDate,
            onTap: onDateTap,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.timeSlot,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.softGold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((slot) {
              return _ChoicePill(
                label: _localizedTimeSlot(slot, isArabic),
                selected: slot == selectedTimeSlot,
                onTap: () => onTimeSlotChanged(slot),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MuseumEntryCard extends StatelessWidget {
  const _MuseumEntryCard({
    required this.l10n,
    required this.ticketProvider,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.ticketsMuseumEntryTitle,
      subtitle: l10n.ticketsMuseumEntrySubtitle,
      isArabic: isArabic,
      child: Column(
        children: ticketProvider.visitorCategories.map((category) {
          final quantity = ticketProvider.quantityForCategory(category.id);
          return _CategoryQuantityRow(
            category: category,
            quantity: quantity,
            languageCode: isArabic ? 'ar' : 'en',
            onMinus: () => ticketProvider.decrementVisitorCategory(category.id),
            onPlus: () => ticketProvider.incrementVisitorCategory(category.id),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryQuantityRow extends StatelessWidget {
  const _CategoryQuantityRow({
    required this.category,
    required this.quantity,
    required this.languageCode,
    required this.onMinus,
    required this.onPlus,
  });

  final VisitorTicketCategory category;
  final int quantity;
  final String languageCode;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final note = category.eligibilityNote(languageCode);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  Directionality.of(context) == TextDirection.rtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  category.label(languageCode),
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${category.price.toStringAsFixed(2)}',
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.primaryGold),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.neutralMedium, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          _RoundIconButton(icon: Icons.remove_rounded, onTap: onMinus),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          _RoundIconButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _RobotTourCard extends StatelessWidget {
  const _RobotTourCard({
    required this.l10n,
    required this.ticketProvider,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final selected = ticketProvider.currentOrderDraft.robotTourType;
    return _SectionCard(
      title: l10n.ticketsRobotTourTitle,
      subtitle: l10n.ticketsRobotTourSubtitle,
      isArabic: isArabic,
      child: Column(
        children: [
          _TourOptionTile(
            title: l10n.ticketsNoRobotTour,
            subtitle: l10n.ticketsNoRobotTourDesc,
            icon: Icons.explore_outlined,
            selected: selected == RobotTourType.none,
            onTap: () => ticketProvider.selectRobotTourType(RobotTourType.none),
          ),
          _TourOptionTile(
            title: l10n.ticketsStandardTour,
            subtitle: l10n.ticketsStandardTourDesc,
            icon: Icons.route_rounded,
            selected: selected == RobotTourType.standard,
            onTap: () =>
                ticketProvider.selectRobotTourType(RobotTourType.standard),
          ),
          _TourOptionTile(
            title: l10n.ticketsPersonalizedTour,
            subtitle: l10n.ticketsPersonalizedTourDesc,
            icon: Icons.tune_rounded,
            selected: selected == RobotTourType.personalized,
            onTap: () =>
                ticketProvider.selectRobotTourType(RobotTourType.personalized),
          ),
        ],
      ),
    );
  }
}

class _StandardTourConfigCard extends StatelessWidget {
  const _StandardTourConfigCard({
    required this.l10n,
    required this.ticketProvider,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final config =
        ticketProvider.currentOrderDraft.standardTourConfig ??
        StandardTourConfig.defaultConfig;
    return _SectionCard(
      title: l10n.ticketsStandardConfigTitle,
      isArabic: isArabic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigLabel(l10n.duration),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [60, 90, 120].map((duration) {
              return _ChoicePill(
                label: l10n.ticketsDurationValue(duration),
                selected: config.durationMinutes == duration,
                onTap: () => ticketProvider.updateStandardTourConfig(
                  config.copyWith(durationMinutes: duration),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _ConfigLabel(l10n.language),
          Wrap(
            spacing: 8,
            children: [
              _ChoicePill(
                label: l10n.ticketsEnglish,
                selected: config.languageCode == 'en',
                onTap: () => ticketProvider.updateStandardTourConfig(
                  config.copyWith(languageCode: 'en'),
                ),
              ),
              _ChoicePill(
                label: l10n.ticketsArabic,
                selected: config.languageCode == 'ar',
                onTap: () => ticketProvider.updateStandardTourConfig(
                  config.copyWith(languageCode: 'ar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RouteSummary(text: l10n.ticketsRecommendedRoute),
        ],
      ),
    );
  }
}

class _PersonalizedTourCard extends StatelessWidget {
  const _PersonalizedTourCard({required this.l10n, required this.isArabic});

  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.ticketsPersonalizedSummaryTitle,
      isArabic: isArabic,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ticketsPersonalizedPhase3,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.bodyText, height: 1.4),
          ),
          const SizedBox(height: 14),
          _OutlineActionButton(
            label: l10n.ticketsCustomizeTour,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.tourCustomization),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.l10n,
    required this.ticketProvider,
    required this.formattedDate,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final String formattedDate;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final draft = ticketProvider.currentOrderDraft;
    return _SectionCard(
      title: l10n.ticketsOrderSummaryTitle,
      isArabic: isArabic,
      child: Column(
        children: [
          _SummaryLine(label: l10n.visitDate, value: formattedDate),
          _SummaryLine(
            label: l10n.timeSlot,
            value: _localizedTimeSlot(draft.timeSlot, isArabic),
          ),
          _SummaryLine(
            label: l10n.ticketsMuseumSubtotal,
            value: _money(ticketProvider.museumSubtotal),
          ),
          _SummaryLine(
            label: l10n.ticketsRobotSubtotal,
            value: _money(ticketProvider.robotTourSubtotal),
          ),
          const Divider(color: AppColors.darkDivider, height: 24),
          _SummaryLine(
            label: l10n.totalLabel,
            value: _money(ticketProvider.orderTotal),
            emphasized: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.ticketsMockCheckoutNote,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyCheckoutBar extends StatelessWidget {
  const _StickyCheckoutBar({
    required this.l10n,
    required this.ticketProvider,
    required this.onCheckout,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.cinematicNav,
        border: Border(top: BorderSide(color: AppColors.goldBorder(0.14))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.totalLabel, style: AppTextStyles.metadata(context)),
                  Text(
                    _money(ticketProvider.orderTotal),
                    style: AppTextStyles.displaySectionTitle(
                      context,
                    ).copyWith(fontSize: 22, color: AppColors.primaryGold),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: _GoldButton(
                label: ticketProvider.isCheckingOut
                    ? '${l10n.ticketsCheckout}...'
                    : l10n.ticketsCheckout,
                onTap: ticketProvider.isCheckingOut
                    ? () {}
                    : ticketProvider.canCheckoutDraft
                    ? onCheckout
                    : onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.isArabic,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: AppTextStyles.displaySectionTitle(
              context,
            ).copyWith(color: AppColors.softGold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium, height: 1.35),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardGlass(0.56),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.goldBorder(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.secondaryGlass(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder(0.12)),
        ),
        child: Row(
          textDirection: Directionality.of(context),
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    Directionality.of(context) == TextDirection.rtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.metadata(context)),
                  Text(
                    value,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.bodyPrimary(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_outlined,
              color: AppColors.softGold,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.18)
              : AppColors.secondaryGlass(0.30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryGold
                : AppColors.goldBorder(0.12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.metadata(context).copyWith(
            color: selected ? AppColors.primaryGold : AppColors.bodyText,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.secondaryGlass(0.42),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.goldBorder(0.18)),
        ),
        child: Icon(icon, color: AppColors.primaryGold, size: 18),
      ),
    );
  }
}

class _TourOptionTile extends StatelessWidget {
  const _TourOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryGold.withValues(alpha: 0.13)
                : AppColors.secondaryGlass(0.30),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryGold
                  : AppColors.goldBorder(0.12),
            ),
          ),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      Directionality.of(context) == TextDirection.rtl
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.start,
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      textAlign: TextAlign.start,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primaryGold : AppColors.bodyText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigLabel extends StatelessWidget {
  const _ConfigLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          label,
          style: AppTextStyles.metadata(
            context,
          ).copyWith(color: AppColors.softGold),
        ),
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryGlass(0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder(0.12)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: AppTextStyles.bodyPrimary(
          context,
        ).copyWith(color: AppColors.bodyText, height: 1.35),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ),
          Text(
            value,
            style: emphasized
                ? AppTextStyles.displaySectionTitle(
                    context,
                  ).copyWith(color: AppColors.primaryGold, fontSize: 18)
                : AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.darkInk,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.buttonLabel(context),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        side: const BorderSide(color: AppColors.primaryGold),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.buttonLabel(
          context,
        ).copyWith(color: AppColors.primaryGold),
      ),
    );
  }
}

String _money(double value) => '\$${value.toStringAsFixed(2)}';

String _localizedTimeSlot(String slot, bool isArabic) {
  if (!isArabic) return slot;
  return slot.replaceAll('AM', 'ص').replaceAll('PM', 'م');
}
