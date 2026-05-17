import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/recommended_route.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../models/user_preferences.dart';
import '../../services/recommended_routes_service.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  static const List<String> _timeSlots = ['09:00', '11:00', '13:00', '15:00'];
  final RecommendedRoutesService _recommendedRoutesService =
      RecommendedRoutesService();
  List<RecommendedRoute> _recommendedRoutes = const [];
  List<String> _recommendedRouteWarnings = const [];
  bool _recommendedRoutesLoaded = false;
  String? _recommendedRoutesExhibitKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    final exhibitKey = exhibits.map((exhibit) => exhibit.id).join('|');
    if (exhibitKey == _recommendedRoutesExhibitKey) return;
    _recommendedRoutesExhibitKey = exhibitKey;
    _loadRecommendedRoutes(exhibits);
  }

  Future<void> _loadRecommendedRoutes(Iterable<Exhibit> exhibits) async {
    final result = await _recommendedRoutesService.load(exhibits: exhibits);
    if (!mounted) return;
    setState(() {
      _recommendedRoutes = result.routes
          .where((route) => route.isActive)
          .toList(growable: false);
      _recommendedRouteWarnings = result.warnings;
      _recommendedRoutesLoaded = true;
    });
    debugPrint(
      'count=${result.routes.length}; '
      'active=${_recommendedRoutes.length}; '
      'warnings=${result.warnings.join(' | ')}',
    );
    for (final warning in result.warnings) {
      debugPrint('Recommended route warning: $warning');
    }
  }

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

    final confirmed = await _confirmCashPayment(
      context: context,
      total: ticketProvider.orderTotal,
    );
    if (!confirmed) return;

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

  Future<bool> _confirmCashPayment({
    required BuildContext context,
    required double total,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cinematicCard,
          title: Text(
            AppLocalizations.of(dialogContext)!.cashPaymentAtCounterTitle,
          ),
          content: Text(
            AppLocalizations.of(
              dialogContext,
            )!.cashPaymentAtCounterBody(_money(total)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppLocalizations.of(dialogContext)!.review),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkInk,
              ),
              child: Text(AppLocalizations.of(dialogContext)!.confirmBooking),
            ),
          ],
        );
      },
    );
    return result ?? false;
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
      bottomNavigationBar: const BottomNav(currentIndex: 2),
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
                if (_recommendedRoutes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _RecommendedRoutesCard(
                    routes: _recommendedRoutes,
                    selectedRouteId: draft.recommendedRouteId,
                    onRouteSelected: ticketProvider.selectRecommendedRoute,
                    isArabic: isArabic,
                  ),
                ] else if (_recommendedRoutesLoaded) ...[
                  const SizedBox(height: 18),
                  _RecommendedRoutesFallbackCard(
                    warnings: _recommendedRouteWarnings,
                    isArabic: isArabic,
                  ),
                ],
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
                _NarrationLanguageCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
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
                const SizedBox(height: 18),
                _PaymentNoticeCard(isArabic: isArabic),
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
                  _money(category.price),
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

class _RecommendedRoutesCard extends StatelessWidget {
  const _RecommendedRoutesCard({
    required this.routes,
    required this.selectedRouteId,
    required this.onRouteSelected,
    required this.isArabic,
  });

  final List<RecommendedRoute> routes;
  final String? selectedRouteId;
  final ValueChanged<RecommendedRoute> onRouteSelected;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: isArabic
          ? '\u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0642\u062a\u0631\u062d\u0629'
          : 'Recommended Routes',
      subtitle: isArabic
          ? '\u0627\u062e\u062a\u0631 \u0645\u0633\u0627\u0631\u0627 \u062c\u0627\u0647\u0632\u0627 \u0644\u0645\u0644\u0621 \u0645\u062d\u0637\u0627\u062a \u0627\u0644\u062c\u0648\u0644\u0629 \u0648\u062a\u0641\u0636\u064a\u0644\u0627\u062a\u0647\u0627.'
          : 'Choose a ready route to fill the tour stops and preferences.',
      isArabic: isArabic,
      child: Column(
        children: routes.map((route) {
          final selected = selectedRouteId == route.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onRouteSelected(route),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: Directionality.of(context),
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            route.title(isArabic ? 'ar' : 'en'),
                            textAlign: TextAlign.start,
                            style: AppTextStyles.bodyPrimary(
                              context,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? AppColors.primaryGold
                              : AppColors.bodyText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      route.description(isArabic ? 'ar' : 'en'),
                      textAlign: TextAlign.start,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${route.durationMin} min \u2022 ${route.artifactIds.length} stops',
                      textAlign: TextAlign.start,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.primaryGold),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecommendedRoutesFallbackCard extends StatelessWidget {
  const _RecommendedRoutesFallbackCard({
    required this.warnings,
    required this.isArabic,
  });

  final List<String> warnings;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: isArabic
          ? '\u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0642\u062a\u0631\u062d\u0629'
          : 'Recommended Routes',
      subtitle: isArabic
          ? '\u062a\u0639\u0630\u0631 \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0642\u062a\u0631\u062d\u0629. \u0631\u0627\u062c\u0639 \u0633\u062c\u0644 \u0627\u0644\u062a\u0637\u0628\u064a\u0642 \u0644\u0644\u062a\u0641\u0627\u0635\u064a\u0644.'
          : 'Recommended routes could not be loaded. Check the app log for details.',
      isArabic: isArabic,
      child: _RouteSummary(
        text: warnings.isEmpty
            ? 'Recommended routes list is empty.'
            : warnings.take(2).join(' | '),
      ),
    );
  }
}

class _NarrationLanguageCard extends StatelessWidget {
  const _NarrationLanguageCard({
    required this.l10n,
    required this.ticketProvider,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final TicketProvider ticketProvider;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final draft = ticketProvider.currentOrderDraft;
    final languageCode = draft.robotTourType == RobotTourType.personalized
        ? (draft.personalizedTourConfig?.languageCode ??
              PersonalizedTourConfig.defaultConfig.languageCode)
        : (draft.standardTourConfig?.languageCode ??
              StandardTourConfig.defaultConfig.languageCode);
    return _SectionCard(
      title: l10n.language,
      subtitle: isArabic
          ? '\u0627\u062e\u062a\u0631 \u0644\u063a\u0629 \u0627\u0644\u0633\u0631\u062f \u0642\u0628\u0644 \u062a\u062e\u0635\u064a\u0635 \u0627\u0644\u062c\u0648\u0644\u0629 \u0623\u0648 \u062a\u0623\u0643\u064a\u062f\u0647\u0627.'
          : 'Choose the tour narration language before personalization or checkout.',
      isArabic: isArabic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigLabel(l10n.language),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoicePill(
                label: l10n.ticketsEnglish,
                selected: languageCode == 'english',
                onTap: () => ticketProvider.updateTourLanguage('english'),
              ),
              _ChoicePill(
                label: l10n.ticketsArabic,
                selected: languageCode == 'arabic',
                onTap: () => ticketProvider.updateTourLanguage('arabic'),
              ),
              _ChoicePill(
                label: l10n.egyptianArabic,
                selected: languageCode == 'egyptian_arabic',
                onTap: () =>
                    ticketProvider.updateTourLanguage('egyptian_arabic'),
              ),
            ],
          ),
          if (draft.robotTourType == RobotTourType.standard) ...[
            const SizedBox(height: 16),
            _ConfigLabel(l10n.duration),
            _ChoicePill(
              label: l10n.ticketsDurationValue(
                StandardTourConfig.defaultConfig.durationMinutes,
              ),
              selected: true,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _RouteSummary(text: l10n.ticketsRecommendedRoute),
          ],
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
        ],
      ),
    );
  }
}

class _PaymentNoticeCard extends StatelessWidget {
  const _PaymentNoticeCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: isArabic ? '\u0627\u0644\u062f\u0641\u0639' : 'Payment',
      subtitle: isArabic
          ? '\u0627\u0644\u062d\u062c\u0632 \u0645\u062a\u0627\u062d \u0646\u0642\u062f\u0627 \u0641\u0642\u0637 \u062d\u0627\u0644\u064a\u0627. \u0633\u062a\u062f\u0641\u0639 \u0639\u0646\u062f \u0634\u0628\u0627\u0643 \u0627\u0644\u0645\u062a\u062d\u0641.'
          : 'Cash only for now. You will pay at the museum counter.',
      isArabic: isArabic,
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.primaryGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.paymentStatusPayAtCounter,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.bodyText),
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

String _money(double value) => '${value.toStringAsFixed(2)} EGP';

String _localizedTimeSlot(String slot, bool isArabic) {
  switch (slot) {
    case '09:00':
      return '09:00 - 11:00';
    case '11:00':
      return '11:00 - 13:00';
    case '13:00':
      return '13:00 - 15:00';
    case '15:00':
      return '15:00 - 17:00';
  }
  if (!isArabic) return slot;
  return slot.replaceAll('AM', '\u0635').replaceAll('PM', '\u0645');
}
