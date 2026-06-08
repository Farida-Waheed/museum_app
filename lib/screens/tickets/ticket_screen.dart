import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/pricing.dart';
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
  final ScrollController _scrollController = ScrollController();
  Timer? _slotRefreshTimer;
  bool _recommendedRoutesLoaded = false;
  String? _recommendedRoutesExhibitKey;

  @override
  void initState() {
    super.initState();
    _slotRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      _repairSelectedTimeSlot(context.read<TicketProvider>());
    });
  }

  @override
  void dispose() {
    _slotRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToBookingTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    final exhibitKey = exhibits.map((exhibit) => exhibit.id).join('|');
    if (exhibitKey == _recommendedRoutesExhibitKey) return;
    _recommendedRoutesExhibitKey = exhibitKey;
    _loadRecommendedRoutes(exhibits);
  }

  void _repairSelectedTimeSlot(TicketProvider ticketProvider) {
    final draft = ticketProvider.currentOrderDraft;
    if (_isFutureVisitSlot(draft.visitDate, draft.timeSlot)) return;
    for (final slot in _timeSlots) {
      if (_isFutureVisitSlot(draft.visitDate, slot)) {
        ticketProvider.updateTimeSlot(slot);
        return;
      }
    }
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
      firstDate: _todayDate(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ticketProvider.updateVisitDate(picked);
      if (!_isFutureVisitSlot(
        picked,
        ticketProvider.currentOrderDraft.timeSlot,
      )) {
        String? nextSlot;
        for (final slot in _timeSlots) {
          if (_isFutureVisitSlot(picked, slot)) {
            nextSlot = slot;
            break;
          }
        }
        if (nextSlot != null) ticketProvider.updateTimeSlot(nextSlot);
        _jumpToBookingTop();
      }
    }
  }

  Future<void> _checkout({
    required AuthProvider authProvider,
    required TicketProvider ticketProvider,
    required AppLocalizations l10n,
  }) async {
    if (ticketProvider.isCheckingOut) return;
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
    final draft = ticketProvider.currentOrderDraft;
    if (draft.visitorCount > BookingPricing.maxVisitorsPerBooking) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_visitorLimitMessage(_isArabic(context)))),
      );
      return;
    }
    if (!draft.isVisitTimeFuture()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_visitTimeValidationMessage(draft, _isArabic(context))),
        ),
      );
      return;
    }
    if (draft.timeSlot.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_dateTimeRequiredMessage(_isArabic(context)))),
      );
      return;
    }
    if (draft.robotTourType == RobotTourType.standard) {
      if (!_recommendedRoutesLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_routesLoadingMessage(_isArabic(context)))),
        );
        return;
      }
      if (!ticketProvider.isStandardDraftComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_standardRouteRequiredMessage(_isArabic(context))),
          ),
        );
        return;
      }
    }
    if (!ticketProvider.isPersonalizedDraftComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _personalizedExhibitRequiredMessage(_isArabic(context)),
          ),
        ),
      );
      return;
    }
    final narrationLanguage = draft.robotTourType == RobotTourType.personalized
        ? draft.personalizedTourConfig?.languageCode
        : draft.standardTourConfig?.languageCode;
    if (!TourNarrationLanguage.isSupported(narrationLanguage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_unsupportedTourLanguageMessage(_isArabic(context))),
        ),
      );
      return;
    }
    final narrationLanguageOther =
        draft.robotTourType == RobotTourType.personalized
        ? draft.personalizedTourConfig?.languageOther
        : draft.standardTourConfig?.languageOther;
    if (narrationLanguage == 'other' &&
        narrationLanguageOther?.trim().isNotEmpty != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_preferredLanguageRequiredMessage(_isArabic(context))),
        ),
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
            _friendlyBookingFailure(
              ticketProvider.ticketError,
              _isArabic(context),
            ),
          ),
        ),
      );
      return;
    }
    await _showBookingSuccess(context: context, isArabic: _isArabic(context));
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

  Future<void> _showBookingSuccess({
    required BuildContext context,
    required bool isArabic,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: AppColors.cinematicCard,
          title: Text(
            isArabic
                ? '\u062a\u0645 \u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062d\u062c\u0632'
                : 'Booking created successfully',
          ),
          content: Text(
            isArabic
                ? '\u062a\u0645 \u062a\u0623\u0643\u064a\u062f \u0627\u0644\u062d\u062c\u0632. \u064a\u0631\u062c\u0649 \u0627\u0644\u062f\u0641\u0639 \u0639\u0646\u062f \u0634\u0628\u0627\u0643 \u0627\u0644\u0645\u062a\u062d\u0641. \u062a\u0630\u0627\u0643\u0631\u0643 \u0645\u062a\u0627\u062d\u0629 \u0627\u0644\u0622\u0646 \u0641\u064a \u062a\u0630\u0627\u0643\u0631\u064a.'
                : 'Booking created successfully. Please pay at the museum counter to activate your QR code and Horus-Bot tour.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushReplacementNamed(context, AppRoutes.myTickets);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkInk,
              ),
              child: Text(
                isArabic
                    ? '\u0639\u0631\u0636 \u062a\u0630\u0627\u0643\u0631\u064a'
                    : 'Open My Tickets',
              ),
            ),
          ],
        ),
      ),
    );
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
      showChatButton: true,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: authProvider.isLoggedIn
            ? _buildPurchaseBuilder(
                context,
                ticketProvider,
                authProvider,
                l10n,
                isArabic,
              )
            : _buildAccountGate(context, l10n, isArabic),
      ),
    );
  }

  Widget _buildAccountGate(
    BuildContext context,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.cinematicBackground),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 144),
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
                const SizedBox(height: AppSpacing.cardGap),
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
                const SizedBox(height: AppSpacing.cardPaddingCompact),
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
      decoration: const BoxDecoration(color: AppColors.cinematicBackground),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.screenHorizontalCompact,
                20,
                AppSpacing.screenHorizontalCompact,
                156,
              ),
              children: [
                _PageIntroCard(l10n: l10n, isArabic: isArabic),
                const SizedBox(height: AppSpacing.cardGap),
                _MuseumEntryCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _RobotTourCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
                if (draft.robotTourType == RobotTourType.standard &&
                    _recommendedRoutes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _RecommendedRoutesCard(
                    routes: _recommendedRoutes,
                    selectedRouteId: draft.recommendedRouteId,
                    onRouteSelected: ticketProvider.selectRecommendedRoute,
                    isArabic: isArabic,
                  ),
                ] else if (draft.robotTourType == RobotTourType.standard &&
                    _recommendedRoutesLoaded) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _RecommendedRoutesFallbackCard(
                    warnings: _recommendedRouteWarnings,
                    isArabic: isArabic,
                  ),
                ] else if (draft.robotTourType == RobotTourType.standard) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _RecommendedRoutesLoadingCard(isArabic: isArabic),
                ],
                const SizedBox(height: AppSpacing.cardGap),
                _VisitDetailsCard(
                  l10n: l10n,
                  formattedDate: formattedDate,
                  selectedDate: draft.visitDate,
                  selectedTimeSlot: draft.timeSlot,
                  timeSlots: _timeSlots,
                  onDateTap: () => _selectDate(ticketProvider),
                  onTimeSlotChanged: (slot) {
                    ticketProvider.updateTimeSlot(slot);
                    _jumpToBookingTop();
                  },
                  isArabic: isArabic,
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _NarrationLanguageCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  isArabic: isArabic,
                ),
                if (draft.robotTourType == RobotTourType.personalized) ...[
                  const SizedBox(height: AppSpacing.cardGap),
                  _PersonalizedTourCard(
                    l10n: l10n,
                    isArabic: isArabic,
                    ticketProvider: ticketProvider,
                  ),
                ],
                const SizedBox(height: AppSpacing.cardGap),
                _OrderSummaryCard(
                  l10n: l10n,
                  ticketProvider: ticketProvider,
                  formattedDate: formattedDate,
                  isArabic: isArabic,
                ),
                const SizedBox(height: AppSpacing.cardGap),
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
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.premiumGold,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.darkInk,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.ticketsPlanVisitTitle,
            style: AppTextStyles.premiumScreenTitle(
              context,
            ).copyWith(color: AppColors.whiteTitle, fontSize: 24),
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
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.timeSlots,
    required this.onDateTap,
    required this.onTimeSlotChanged,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final String formattedDate;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final List<String> timeSlots;
  final VoidCallback onDateTap;
  final ValueChanged<String> onTimeSlotChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final noRemainingSlotsToday =
        _isToday(selectedDate) &&
        !timeSlots.any((slot) => _isFutureVisitSlot(selectedDate, slot));
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
          if (noRemainingSlotsToday) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _noRemainingVisitTimesMessage(isArabic),
                style: AppTextStyles.metadata(
                  context,
                ).copyWith(color: AppColors.neutralMedium),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeSlots.map((slot) {
              final isAvailable = _isFutureVisitSlot(selectedDate, slot);
              return _ChoicePill(
                label: _localizedTimeSlot(slot, isArabic),
                detailLabel: !isAvailable
                    ? (_isToday(selectedDate)
                          ? (isArabic ? '\u0645\u0631\u0651' : 'Passed')
                          : (isArabic
                                ? '\u063a\u064a\u0631 \u0645\u062a\u0627\u062d'
                                : 'Unavailable'))
                    : null,
                selected: slot == selectedTimeSlot && isAvailable,
                enabled: isAvailable,
                onTap: () {
                  if (!isAvailable) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isToday(selectedDate)
                              ? _pastVisitTimeMessage(isArabic)
                              : _futureVisitTimeMessage(isArabic),
                        ),
                      ),
                    );
                    return;
                  }
                  onTimeSlotChanged(slot);
                },
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
    final canAddVisitor =
        ticketProvider.draftVisitorCount < BookingPricing.maxVisitorsPerBooking;
    return _SectionCard(
      title: l10n.ticketsMuseumEntryTitle,
      subtitle: l10n.ticketsMuseumEntrySubtitle,
      isArabic: isArabic,
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _visitorLimitHelper(isArabic),
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.primaryGold),
            ),
          ),
          const SizedBox(height: 8),
          ...ticketProvider.visitorCategories.map((category) {
            final quantity = ticketProvider.quantityForCategory(category.id);
            return _CategoryQuantityRow(
              category: category,
              quantity: quantity,
              languageCode: isArabic ? 'ar' : 'en',
              canAdd: canAddVisitor,
              onMinus: () =>
                  ticketProvider.decrementVisitorCategory(category.id),
              onPlus: () {
                if (!ticketProvider.canIncrementVisitorCategory(category.id)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_visitorLimitMessage(isArabic))),
                  );
                  return;
                }
                ticketProvider.incrementVisitorCategory(category.id);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryQuantityRow extends StatelessWidget {
  const _CategoryQuantityRow({
    required this.category,
    required this.quantity,
    required this.languageCode,
    required this.canAdd,
    required this.onMinus,
    required this.onPlus,
  });

  final VisitorTicketCategory category;
  final int quantity;
  final String languageCode;
  final bool canAdd;
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
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: onPlus,
            enabled: canAdd,
          ),
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
                padding: const EdgeInsets.all(12),
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
          ? '\u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0642\u062a\u0631\u062d\u0629 \u063a\u064a\u0631 \u0645\u062a\u0627\u062d\u0629 \u062d\u0627\u0644\u064a\u0627\u064b.'
          : 'Recommended routes are currently unavailable.',
      isArabic: isArabic,
      child: _RouteSummary(
        text: warnings.isEmpty
            ? (isArabic
                  ? '\u064a\u062a\u0645 \u0639\u0631\u0636 \u0627\u0644\u0645\u062d\u062a\u0648\u0649 \u0627\u0644\u0645\u062a\u0627\u062d \u0627\u0644\u0645\u062d\u0641\u0648\u0638.'
                  : 'Showing available saved content.')
            : (isArabic
                  ? '\u064a\u062a\u0645 \u0639\u0631\u0636 \u0627\u0644\u0645\u062d\u062a\u0648\u0649 \u0627\u0644\u0645\u062a\u0627\u062d \u0627\u0644\u0645\u062d\u0641\u0648\u0638.'
                  : 'Showing available saved content.'),
      ),
    );
  }
}

class _RecommendedRoutesLoadingCard extends StatelessWidget {
  const _RecommendedRoutesLoadingCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: isArabic
          ? '\u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a \u0627\u0644\u0645\u0642\u062a\u0631\u062d\u0629'
          : 'Recommended Routes',
      subtitle: isArabic
          ? '\u062c\u0627\u0631\u064a \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a...'
          : 'Loading recommended routes...',
      isArabic: isArabic,
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic
                  ? '\u064a\u062a\u0645 \u062a\u062d\u0636\u064a\u0631 \u062e\u064a\u0627\u0631\u0627\u062a \u0627\u0644\u062c\u0648\u0644\u0629.'
                  : 'Preparing available tour options.',
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
    final languageOther = draft.robotTourType == RobotTourType.personalized
        ? draft.personalizedTourConfig?.languageOther
        : draft.standardTourConfig?.languageOther;
    return _SectionCard(
      title: l10n.language,
      subtitle: isArabic
          ? '\u0627\u062e\u062a\u0631 \u0644\u063a\u0629 \u0627\u0644\u0633\u0631\u062f \u0642\u0628\u0644 \u062a\u062e\u0635\u064a\u0635 \u0627\u0644\u062c\u0648\u0644\u0629 \u0623\u0648 \u062a\u0623\u0643\u064a\u062f\u0647\u0627.'
          : 'Choose the tour narration language before personalization or creating a booking.',
      isArabic: isArabic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfigLabel(l10n.language),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...TourNarrationLanguage.values.map(
                (language) => _ChoicePill(
                  label: TourNarrationLanguage.label(language, isArabic),
                  selected: languageCode == language,
                  onTap: () => ticketProvider.updateTourLanguage(language),
                ),
              ),
            ],
          ),
          if (languageCode == 'other') ...[
            const SizedBox(height: 12),
            TextFormField(
              initialValue: languageOther ?? '',
              onChanged: ticketProvider.updateTourLanguageOther,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: AppColors.whiteTitle),
              decoration: InputDecoration(
                labelText: isArabic
                    ? '\u0644\u063a\u0629 \u0623\u062e\u0631\u0649'
                    : 'Other language',
                hintText: isArabic
                    ? '\u0627\u0643\u062a\u0628 \u0627\u0644\u0644\u063a\u0629 \u0627\u0644\u062a\u064a \u062a\u0641\u0636\u0644\u0647\u0627'
                    : 'Type your preferred language',
                filled: true,
                fillColor: AppColors.cinematicCard.withValues(alpha: 0.48),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
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
  const _PersonalizedTourCard({
    required this.l10n,
    required this.isArabic,
    required this.ticketProvider,
  });

  final AppLocalizations l10n;
  final bool isArabic;
  final TicketProvider ticketProvider;

  @override
  Widget build(BuildContext context) {
    final config = ticketProvider.currentOrderDraft.personalizedTourConfig;
    final hasPlannerRoute =
        config != null &&
        (config.selectedExhibitIds.isNotEmpty ||
            config.selectedThemes.isNotEmpty ||
            config.accessibilityNeeds.isNotEmpty ||
            config.photoSpotsEnabled);
    return _SectionCard(
      title: hasPlannerRoute
          ? (isArabic
                ? 'جولة مخصصة من المخطط'
                : 'Personalized tour from planner')
          : l10n.ticketsPersonalizedSummaryTitle,
      isArabic: isArabic,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            hasPlannerRoute
                ? (isArabic
                      ? 'تم حفظ اختيارات المخطط. أكمل تاريخ الزيارة والوقت والدفع لتأكيد الحجز.'
                      : 'Your planner choices are attached. Complete visit details and payment confirmation to book.')
                : l10n.ticketsPersonalizedPhase3,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.bodyText, height: 1.4),
          ),
          if (hasPlannerRoute) ...[
            const SizedBox(height: 12),
            _SummaryLine(
              label: isArabic ? 'المعروضات' : 'Planner stops',
              value: '${config.selectedExhibitIds.length}',
            ),
            _SummaryLine(
              label: isArabic ? 'الاهتمامات' : 'Interests',
              value: '${config.selectedThemes.length}',
            ),
            _SummaryLine(
              label: isArabic ? 'المدة' : 'Duration',
              value: '${config.durationMinutes} min',
            ),
            _SummaryLine(
              label: isArabic ? 'نقاط الصور' : 'Photo stops',
              value: config.photoSpotsEnabled
                  ? (isArabic ? 'مفعلة' : 'Enabled')
                  : (isArabic ? 'غير مفعلة' : 'Disabled'),
            ),
          ],
          const SizedBox(height: 14),
          _OutlineActionButton(
            label: hasPlannerRoute
                ? (isArabic ? 'تعديل الخطة' : 'Edit planner choices')
                : l10n.ticketsCustomizeTour,
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
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.screenHorizontalCompact,
        12,
        AppSpacing.screenHorizontalCompact,
        22,
      ),
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
                    ? (Localizations.localeOf(context).languageCode == 'ar'
                          ? '\u062c\u0627\u0631\u064a \u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062d\u062c\u0632...'
                          : 'Creating booking...')
                    : l10n.ticketsCheckout,
                isLoading: ticketProvider.isCheckingOut,
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
            style: AppTextStyles.premiumSectionLabel(
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
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
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
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.secondaryGlassCard(
          radius: 16,
          opacity: 0.42,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyPrimary(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 8),
              child: Icon(
                Icons.edit_calendar_outlined,
                color: AppColors.softGold,
                size: 18,
              ),
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
    this.enabled = true,
    this.detailLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;
  final String? detailLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        foregroundPainter: !enabled
            ? _DashedRRectPainter(
                color: AppColors.neutralMedium.withValues(alpha: 0.45),
                radius: 16,
              )
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration:
              AppDecorations.secondaryGlassCard(
                radius: 16,
                opacity: 0.34,
              ).copyWith(
                color: !enabled
                    ? AppColors.secondaryGlass(0.18)
                    : selected
                    ? AppColors.primaryGold.withValues(alpha: 0.18)
                    : AppColors.secondaryGlass(0.34),
                border: Border.all(
                  color: !enabled
                      ? Colors.transparent
                      : selected
                      ? AppColors.primaryGold
                      : AppColors.goldBorder(0.14),
                ),
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.metadata(context).copyWith(
                  color: !enabled
                      ? AppColors.neutralMedium.withValues(alpha: 0.65)
                      : selected
                      ? AppColors.primaryGold
                      : AppColors.bodyText,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  decoration: !enabled ? TextDecoration.lineThrough : null,
                ),
              ),
              if (detailLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  detailLabel!,
                  style: AppTextStyles.metadata(context).copyWith(
                    color: AppColors.neutralMedium.withValues(alpha: 0.70),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 5).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

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
        child: Icon(
          icon,
          color: enabled
              ? AppColors.primaryGold
              : AppColors.primaryGold.withValues(alpha: 0.45),
          size: 18,
        ),
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
          padding: const EdgeInsets.all(12),
          decoration:
              AppDecorations.secondaryGlassCard(
                radius: 18,
                opacity: 0.36,
              ).copyWith(
                color: selected
                    ? AppColors.primaryGold.withValues(alpha: 0.13)
                    : AppColors.secondaryGlass(0.34),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryGold
                      : AppColors.goldBorder(0.14),
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
      padding: const EdgeInsets.all(12),
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
  const _GoldButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.darkInk,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkInk,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.buttonLabel(context),
                  ),
                ),
              ],
            )
          : Text(
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

bool _isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

DateTime _todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String _dateTimeRequiredMessage(bool isArabic) {
  return isArabic
      ? '\u064a\u0631\u062c\u0649 \u0627\u062e\u062a\u064a\u0627\u0631 \u062a\u0627\u0631\u064a\u062e \u0648\u0648\u0642\u062a \u0635\u0627\u0644\u062d\u064a\u0646.'
      : 'Please choose a valid date and time.';
}

bool _isToday(DateTime date) {
  final today = _todayDate();
  return date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;
}

bool _isFutureVisitSlot(DateTime date, String slot) {
  final startsAt = visitDateTimeFromParts(date, slot);
  return startsAt != null && startsAt.isAfter(DateTime.now());
}

String _futureVisitTimeMessage(bool isArabic) {
  return isArabic
      ? 'يرجى اختيار وقت زيارة قادم.'
      : 'Please choose a future visit time.';
}

String _pastVisitTimeMessage(bool isArabic) {
  return isArabic
      ? 'هذا الوقت قد مر بالفعل. يرجى اختيار وقت لاحق.'
      : 'This time has already passed. Please choose a later time.';
}

String _noRemainingVisitTimesMessage(bool isArabic) {
  return isArabic
      ? 'لا توجد مواعيد زيارة متاحة اليوم. يرجى اختيار تاريخ آخر.'
      : 'No remaining visit times are available today. Please choose another date.';
}

String _visitTimeValidationMessage(TicketOrderDraft draft, bool isArabic) {
  final allTodaySlotsPassed =
      _isToday(draft.visitDate) &&
      !_TicketScreenState._timeSlots.any(
        (slot) => _isFutureVisitSlot(draft.visitDate, slot),
      );
  if (allTodaySlotsPassed) return _noRemainingVisitTimesMessage(isArabic);
  if (_isToday(draft.visitDate)) return _pastVisitTimeMessage(isArabic);
  return _futureVisitTimeMessage(isArabic);
}

String _routesLoadingMessage(bool isArabic) {
  return isArabic
      ? '\u062c\u0627\u0631\u064a \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0633\u0627\u0631\u0627\u062a...'
      : 'Loading recommended routes...';
}

String _standardRouteRequiredMessage(bool isArabic) {
  return isArabic
      ? 'اختر مساراً مقترحاً للجولة القياسية.'
      : 'Choose a recommended route for the standard tour.';
}

String _personalizedExhibitRequiredMessage(bool isArabic) {
  return isArabic
      ? 'اختر معروضاً واحداً على الأقل لجولتك المخصصة.'
      : 'Choose at least one exhibit for your personalized tour.';
}

String _unsupportedTourLanguageMessage(bool isArabic) {
  return isArabic
      ? 'اختر لغة جولة مدعومة.'
      : 'Choose a supported tour language.';
}

String _visitorLimitMessage(bool isArabic) {
  return isArabic
      ? 'يمكن أن يشمل حجز Horus-Bot حتى ${BookingPricing.maxVisitorsPerBooking} زوار فقط.'
      : 'Each Horus-Bot booking can include up to ${BookingPricing.maxVisitorsPerBooking} visitors.';
}

String _visitorLimitHelper(bool isArabic) {
  return isArabic
      ? 'الحد الأقصى ${BookingPricing.maxVisitorsPerBooking} زوار لكل حجز.'
      : 'Maximum ${BookingPricing.maxVisitorsPerBooking} visitors per booking.';
}

String _friendlyBookingFailure(String? error, bool isArabic) {
  final lower = error?.toLowerCase() ?? '';
  if (lower.contains('please type your preferred language')) {
    return _preferredLanguageRequiredMessage(isArabic);
  }
  if (lower.contains('connection issue') || lower.contains('network')) {
    return isArabic
        ? '\u062d\u062f\u062b\u062a \u0645\u0634\u0643\u0644\u0629 \u0641\u064a \u0627\u0644\u0627\u062a\u0635\u0627\u0644. \u064a\u0631\u062c\u0649 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0627\u0644\u0625\u0646\u062a\u0631\u0646\u062a \u0648\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
        : 'Connection issue. Please check your internet connection and try again.';
  }
  return isArabic
      ? '\u062a\u0639\u0630\u0631 \u0625\u062a\u0645\u0627\u0645 \u0627\u0644\u062d\u062c\u0632. \u064a\u0631\u062c\u0649 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
      : 'We could not complete your booking. Please try again.';
}

String _preferredLanguageRequiredMessage(bool isArabic) {
  return isArabic
      ? '\u064a\u0631\u062c\u0649 \u0643\u062a\u0627\u0628\u0629 \u0627\u0644\u0644\u063a\u0629 \u0627\u0644\u062a\u064a \u062a\u0641\u0636\u0644\u0647\u0627.'
      : 'Please type your preferred language.';
}

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
