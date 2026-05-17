import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart';
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/museum_ticket.dart';
import '../../models/robot_tour_ticket.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import 'qr_scanner_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  String? _loadedUserId;
  String? _cancellingBookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (authProvider.isLoggedIn && userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TicketProvider>().loadUserTickets(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesModel>();
    final authProvider = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    final sessionProvider = context.watch<AppSessionProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isArabic = prefs.language == 'ar';

    return AppMenuShell(
      title: 'HORUS-BOT',
      backgroundColor: AppColors.baseBlack,
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: authProvider.isLoggedIn
              ? _buildWallet(
                  context,
                  ticketProvider,
                  exhibits,
                  sessionProvider,
                  l10n,
                  isArabic,
                  authProvider.currentUser?.id,
                )
              : _AccountRequiredState(l10n: l10n, isArabic: isArabic),
        ),
      ),
    );
  }

  Widget _buildWallet(
    BuildContext context,
    TicketProvider ticketProvider,
    List<Exhibit> exhibits,
    AppSessionProvider sessionProvider,
    AppLocalizations l10n,
    bool isArabic,
    String? userId,
  ) {
    final orders = ticketProvider.purchasedTicketSets;
    if (ticketProvider.isLoadingTickets && orders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 120),
          child: _GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryGold),
                const SizedBox(height: 18),
                Text(
                  isArabic ? 'جاري تحميل التذاكر...' : 'Loading tickets...',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.bodyText, height: 1.45),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (ticketProvider.ticketError != null && orders.isEmpty) {
      return _TicketLoadErrorState(
        message: ticketProvider.ticketError!,
        l10n: l10n,
        isArabic: isArabic,
        onRetry: userId == null
            ? null
            : () => context.read<TicketProvider>().loadUserTickets(userId),
      );
    }

    if (orders.isEmpty) {
      return _EmptyTicketsState(
        l10n: l10n,
        isArabic: isArabic,
        showSkippedNotice: ticketProvider.skippedTicketSetCount > 0,
      );
    }

    final sortedOrders = orders.toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
      children: [
        _IntroCard(
          title: l10n.myTicketsWalletTitle,
          subtitle: l10n.myTicketsWalletSubtitle,
          icon: Icons.confirmation_number_outlined,
          isArabic: isArabic,
        ),
        if (ticketProvider.ticketError != null) ...[
          const SizedBox(height: 12),
          _TicketErrorBanner(
            message: ticketProvider.ticketError!,
            l10n: l10n,
            onRetry: userId == null
                ? null
                : () => context.read<TicketProvider>().loadUserTickets(userId),
          ),
        ],
        if (ticketProvider.skippedTicketSetCount > 0) ...[
          const SizedBox(height: 12),
          _SkippedBookingsNotice(isArabic: isArabic),
        ],
        const SizedBox(height: 18),
        ...sortedOrders.map(
          (order) => Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 18),
            child: _OrderCard(
              order: order,
              exhibits: exhibits,
              sessionProvider: sessionProvider,
              l10n: l10n,
              isArabic: isArabic,
              isCancelling: _cancellingBookingId == order.id,
              onCancel: () => _confirmAndCancelBooking(
                context,
                ticketProvider,
                order,
                l10n,
                isArabic,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAndCancelBooking(
    BuildContext context,
    TicketProvider ticketProvider,
    PurchasedTicketSet order,
    AppLocalizations l10n,
    bool isArabic,
  ) async {
    if (_cancellingBookingId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: AppColors.cinematicSection,
          title: Text(isArabic ? 'إلغاء الحجز؟' : 'Cancel booking?'),
          content: Text(
            isArabic
                ? 'سيتم إلغاء تذكرة دخول المتحف وتذكرة جولة Horus-Bot المرتبطة بها.'
                : 'This will cancel your Museum Entry Ticket and linked Horus-Bot Tour Ticket.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(isArabic ? 'الاحتفاظ بالحجز' : 'Keep booking'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(isArabic ? 'إلغاء الحجز' : 'Cancel booking'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    setState(() => _cancellingBookingId = order.id);
    final ok = await context.read<TicketProvider>().cancelBooking(order);
    if (!context.mounted) return;
    setState(() => _cancellingBookingId = null);

    final error = context.read<TicketProvider>().ticketError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? l10n.bookingCancelled
              : _friendlyCancellationFailure(error, isArabic),
        ),
      ),
    );
  }
}

class _AccountRequiredState extends StatelessWidget {
  const _AccountRequiredState({required this.l10n, required this.isArabic});

  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 120),
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
                size: 46,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.myTicketsSignInTitle,
                textAlign: TextAlign.start,
                style: AppTextStyles.displayScreenTitle(
                  context,
                ).copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.myTicketsSignInBody,
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
                    child: _OutlineButton(
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
    );
  }
}

class _EmptyTicketsState extends StatelessWidget {
  const _EmptyTicketsState({
    required this.l10n,
    required this.isArabic,
    this.showSkippedNotice = false,
  });

  final AppLocalizations l10n;
  final bool isArabic;
  final bool showSkippedNotice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSkippedNotice) ...[
              _SkippedBookingsNotice(isArabic: isArabic),
              const SizedBox(height: 12),
            ],
            _GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.wallet_outlined,
                    color: AppColors.primaryGold,
                    size: 46,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.myTicketsEmptyTitle,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.displayScreenTitle(
                      context,
                    ).copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.myTicketsEmptyBody,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.bodyPrimary(
                      context,
                    ).copyWith(color: AppColors.bodyText, height: 1.45),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: _GoldButton(
                      label: l10n.myTicketsBuyTickets,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.buyTickets),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketLoadErrorState extends StatelessWidget {
  const _TicketLoadErrorState({
    required this.message,
    required this.l10n,
    required this.isArabic,
    required this.onRetry,
  });

  final String message;
  final AppLocalizations l10n;
  final bool isArabic;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 120),
        child: _GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isArabic
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.primaryGold,
                size: 46,
              ),
              const SizedBox(height: 18),
              Text(
                l10n.myTicketsWalletTitle,
                textAlign: TextAlign.start,
                style: AppTextStyles.displayScreenTitle(
                  context,
                ).copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.start,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: AppColors.bodyText, height: 1.45),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: _GoldButton(label: l10n.retry, onTap: onRetry!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.exhibits,
    required this.sessionProvider,
    required this.l10n,
    required this.isArabic,
    required this.isCancelling,
    required this.onCancel,
  });

  final PurchasedTicketSet order;
  final List<Exhibit> exhibits;
  final AppSessionProvider sessionProvider;
  final AppLocalizations l10n;
  final bool isArabic;
  final bool isCancelling;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final museumTicket = order.museumTicket;
    final robotTicket = order.robotTourTicket;
    final date = museumTicket?.visitDate ?? robotTicket?.visitDate;
    final timeSlot = museumTicket?.timeSlot ?? robotTicket?.timeSlot;
    final formattedDate = _formatDate(date ?? order.purchasedAt, isArabic);
    final ticketProvider = context.watch<TicketProvider>();
    final canCancel = ticketProvider.isBookingCancellable(order);
    final blockedMessage = _cancellationBlockedMessage(
      ticketProvider,
      order,
      isArabic,
    );

    return _GlassCard(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _OrderHeader(
            order: order,
            visitDate: formattedDate,
            timeSlot: timeSlot == null
                ? l10n.myTicketsNotAvailable
                : _localizedTimeSlot(timeSlot, isArabic),
            l10n: l10n,
            isArabic: isArabic,
          ),
          const SizedBox(height: 16),
          if (museumTicket != null)
            _MuseumPassCard(
              ticket: museumTicket,
              l10n: l10n,
              isArabic: isArabic,
            ),
          if (robotTicket != null) ...[
            const SizedBox(height: 14),
            _RobotPassCard(
              ticket: robotTicket,
              exhibits: exhibits,
              sessionProvider: sessionProvider,
              l10n: l10n,
              isArabic: isArabic,
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: _OutlineButton(
                label: l10n.cancelBooking,
                onTap: onCancel,
                isLoading: isCancelling,
              ),
            ),
          ] else if (blockedMessage != null) ...[
            const SizedBox(height: 14),
            _MutedText(blockedMessage),
          ],
        ],
      ),
    );
  }
}

class _TicketErrorBanner extends StatelessWidget {
  const _TicketErrorBanner({
    required this.message,
    required this.l10n,
    required this.onRetry,
  });

  final String message;
  final AppLocalizations l10n;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alertRed.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.30)),
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.alertRed,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.bodyText, height: 1.35),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 10),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}

class _SkippedBookingsNotice extends StatelessWidget {
  const _SkippedBookingsNotice({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder(0.28)),
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryGold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic
                  ? 'تعذر عرض بعض الحجوزات القديمة.'
                  : 'Some older bookings could not be displayed.',
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.bodyText, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
    required this.visitDate,
    required this.timeSlot,
    required this.l10n,
    required this.isArabic,
  });

  final PurchasedTicketSet order;
  final String visitDate;
  final String timeSlot;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _SectionLabel(isArabic ? '\u0645\u0644\u062e\u0635 \u0627\u0644\u062d\u062c\u0632' : 'Booking summary'),
        const SizedBox(height: 10),
        Row(
          textDirection: Directionality.of(context),
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primaryGold,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.myTicketsOrderCode(_shortCode(order.id)),
                textAlign: TextAlign.start,
                style: AppTextStyles.displaySectionTitle(
                  context,
                ).copyWith(color: AppColors.softGold),
              ),
            ),
            _StatusPill(
              label: _paymentStatusLabel(l10n, order.paymentRecord.status),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoGrid(
          items: [
            _InfoItem(l10n.visitDate, visitDate),
            _InfoItem(l10n.timeSlot, timeSlot),
            _InfoItem(l10n.myTicketsTotalPaid, _money(order.totalAmount)),
            _InfoItem(
              l10n.paymentStatus,
              _paymentStatusLabel(l10n, order.paymentRecord.status),
            ),
            _InfoItem(
              l10n.myTicketsPurchasedAt,
              _formatDate(order.purchasedAt, false),
            ),
          ],
        ),
      ],
    );
  }
}

class _MuseumPassCard extends StatelessWidget {
  const _MuseumPassCard({
    required this.ticket,
    required this.l10n,
    required this.isArabic,
  });

  final MuseumTicket ticket;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final languageCode = isArabic ? 'ar' : 'en';
    return _PassSurface(
      icon: Icons.museum_outlined,
      title: l10n.myTicketsMuseumPassTitle,
      badge: l10n.myTicketsEntryQr,
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _InfoGrid(
            items: [
              _InfoItem(
                l10n.visitDate,
                _formatDate(ticket.visitDate, isArabic),
              ),
              _InfoItem(
                l10n.timeSlot,
                _localizedTimeSlot(ticket.timeSlot, isArabic),
              ),
              _InfoItem(l10n.status, _ticketStatusLabel(l10n, ticket.status)),
              _InfoItem(l10n.myTicketsTotalVisitors, '${ticket.visitorCount}'),
              _InfoItem(
                l10n.paymentStatus,
                _paymentStatusLabel(l10n, 'pay_at_counter'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionLabel(l10n.myTicketsCategoryBreakdown),
          const SizedBox(height: 8),
          if (ticket.lineItems.isEmpty)
            _MutedText(l10n.myTicketsNoCategoryBreakdown)
          else
            Column(
              children: ticket.lineItems
                  .map(
                    (item) => _BreakdownLine(
                      label: item.category.label(languageCode),
                      value: '${item.quantity}x',
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 14),
          _CodeBox(
            label: l10n.myTicketsMuseumGateCode,
            code: ticket.qrCodeValue,
            helper: l10n.myTicketsMuseumQrExplanation,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _GoldButton(
              label: l10n.myTicketsShowEntryQr,
              icon: Icons.qr_code_2_rounded,
              onTap: () => _showEntryCodeSheet(context, ticket, l10n, isArabic),
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotPassCard extends StatelessWidget {
  const _RobotPassCard({
    required this.ticket,
    required this.exhibits,
    required this.sessionProvider,
    required this.l10n,
    required this.isArabic,
  });

  final RobotTourTicket ticket;
  final List<Exhibit> exhibits;
  final AppSessionProvider sessionProvider;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _PassSurface(
      icon: Icons.smart_toy_outlined,
      title: l10n.myTicketsRobotPassTitle,
      badge: _tourTypeLabel(l10n, ticket.tourType),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _InfoGrid(
            items: [
              if (_routeTitle(ticket, isArabic) != null)
                _InfoItem(
                  isArabic ? '\u0627\u0644\u0645\u0633\u0627\u0631' : 'Route',
                  _routeTitle(ticket, isArabic)!,
                ),
              _InfoItem(l10n.tourType, _tourTypeLabel(l10n, ticket.tourType)),
              _InfoItem(
                l10n.duration,
                l10n.ticketsDurationValue(ticket.durationMinutes),
              ),
              _InfoItem(
                l10n.language,
                _languageLabel(l10n, ticket.languageCode),
              ),
              _InfoItem(l10n.status, _ticketStatusLabel(l10n, ticket.status)),
              _InfoItem(
                l10n.paymentStatus,
                _paymentStatusLabel(l10n, 'pay_at_counter'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CodeBox(
            label: l10n.myTicketsRobotPassCode,
            code: ticket.qrCodeValue ?? ticket.id,
            helper: l10n.myTicketsRobotPairingSeparate,
          ),
          const SizedBox(height: 14),
          _RobotConfigSummary(
            ticket: ticket,
            exhibits: exhibits,
            l10n: l10n,
            isArabic: isArabic,
          ),
          const SizedBox(height: 14),
          _MutedText(l10n.myTicketsPhysicalRobotQrNote),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _RobotActionButton(
              sessionProvider: sessionProvider,
              l10n: l10n,
              robotTourTicketId: ticket.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _RobotConfigSummary extends StatelessWidget {
  const _RobotConfigSummary({
    required this.ticket,
    required this.exhibits,
    required this.l10n,
    required this.isArabic,
  });

  final RobotTourTicket ticket;
  final List<Exhibit> exhibits;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (ticket.tourType == RobotTourType.personalized) {
      final config = ticket.personalizedTourConfig;
      if (config == null) {
        return _MutedText(l10n.myTicketsNoPreferencesSaved);
      }
      final selectedExhibitIds = _newBookingExhibitIds(
        config.selectedExhibitIds,
      );
      return Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.myTicketsPreferencesSummary),
          const SizedBox(height: 8),
          _BreakdownLine(
            label: l10n.myTicketsSelectedExhibitsCount,
            value: '${selectedExhibitIds.length}',
          ),
          if (selectedExhibitIds.isNotEmpty)
            _BreakdownLine(
              label: l10n.exhibits,
              value: _exhibitNames(
                exhibits,
                selectedExhibitIds,
                isArabic ? 'ar' : 'en',
              ),
            ),
          _BreakdownLine(
            label: l10n.myTicketsThemes,
            value: config.selectedThemes.isEmpty
                ? l10n.myTicketsNone
                : config.selectedThemes
                      .map((id) => _themeLabel(l10n, id))
                      .join(' \u2022 '),
          ),
          _BreakdownLine(
            label: l10n.myTicketsVisitorMode,
            value: _visitorModeLabel(l10n, config.visitorMode),
          ),
          _BreakdownLine(
            label: l10n.myTicketsPace,
            value: _paceLabel(l10n, config.pace),
          ),
          _BreakdownLine(
            label: l10n.myTicketsAccessibilityNeeds,
            value: config.accessibilityNeeds.isEmpty
                ? l10n.myTicketsNone
                : config.accessibilityNeeds
                      .map((id) => _accessibilityLabel(l10n, id))
                      .join(' \u2022 '),
          ),
          _BreakdownLine(
            label: l10n.myTicketsPhotoSpots,
            value: config.photoSpotsEnabled ? l10n.enabled : l10n.disabled,
          ),
          _BreakdownLine(
            label: l10n.myTicketsAvoidCrowds,
            value: config.avoidCrowds ? l10n.enabled : l10n.disabled,
          ),
        ],
      );
    }

    final config = ticket.standardTourConfig;
    final routeExhibitIds = _newBookingExhibitIds(
      config?.routeExhibitIds ?? ticket.selectedArtifactIds ?? const [],
    );
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.myTicketsRouteSummary),
        const SizedBox(height: 8),
        _BreakdownLine(
          label: l10n.myTicketsRouteName,
          value:
              _routeTitle(ticket, isArabic) ??
              _standardRouteLabel(
                l10n,
                config?.routeName ?? ticket.packageName,
              ),
        ),
        _BreakdownLine(
          label: l10n.myTicketsRouteStops,
          value: '${routeExhibitIds.length}',
        ),
        if (routeExhibitIds.isNotEmpty)
          _BreakdownLine(
            label: l10n.exhibits,
            value: _exhibitNames(
              exhibits,
              routeExhibitIds,
              isArabic ? 'ar' : 'en',
            ),
          ),
      ],
    );
  }
}

class _RobotActionButton extends StatelessWidget {
  const _RobotActionButton({
    required this.sessionProvider,
    required this.l10n,
    required this.robotTourTicketId,
  });

  final AppSessionProvider sessionProvider;
  final AppLocalizations l10n;
  final String robotTourTicketId;

  @override
  Widget build(BuildContext context) {
    final action = _robotActionFor(sessionProvider, l10n);
    return _GoldButton(
      label: action.label,
      icon: action.icon,
      onTap: () {
        switch (action.destination) {
          case _RobotActionDestination.qrScan:
            Navigator.pushNamed(
              context,
              AppRoutes.qrScan,
              arguments: {
                'mode': QRScanMode.robotConnection,
                'robotTourTicketId': robotTourTicketId,
              },
            );
            break;
          case _RobotActionDestination.liveTour:
            Navigator.pushNamed(context, AppRoutes.liveTour);
            break;
          case _RobotActionDestination.summary:
            Navigator.pushNamed(context, AppRoutes.summary);
            break;
          case _RobotActionDestination.none:
            break;
        }
      },
    );
  }
}

class _PassSurface extends StatelessWidget {
  const _PassSurface({
    required this.icon,
    required this.title,
    required this.badge,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String badge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryGlass(0.30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder(0.14)),
      ),
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              _MiniBadge(label: badge),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isArabic,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 36),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.start,
            style: AppTextStyles.displayScreenTitle(
              context,
            ).copyWith(color: AppColors.primaryGold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => Container(
              width: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardGlass(0.32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldBorder(0.10)),
              ),
              child: Column(
                crossAxisAlignment:
                    Directionality.of(context) == TextDirection.rtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    textAlign: TextAlign.start,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.neutralMedium, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyPrimary(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.label,
    required this.code,
    required this.helper,
  });

  final String label;
  final String code;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.baseBlack.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder(0.14)),
      ),
      child: Column(
        crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.start,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.softGold),
          ),
          const SizedBox(height: 6),
          SelectableText(
            code,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            helper,
            textAlign: TextAlign.start,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.neutralMedium, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _BreakdownLine extends StatelessWidget {
  const _BreakdownLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        textAlign: TextAlign.start,
        style: AppTextStyles.metadata(
          context,
        ).copyWith(color: AppColors.softGold, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: AppTextStyles.metadata(
        context,
      ).copyWith(color: AppColors.neutralMedium, height: 1.35),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _MiniBadge(label: label.toUpperCase());
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.goldBorder(0.25)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.metadata(context).copyWith(
          color: AppColors.primaryGold,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
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

class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label, overflow: TextOverflow.ellipsis)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.darkInk,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: DefaultTextStyle.merge(
        style: AppTextStyles.buttonLabel(context),
        child: child,
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGold,
        side: const BorderSide(color: AppColors.primaryGold),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGold,
              ),
            )
          : Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.buttonLabel(
                context,
              ).copyWith(color: AppColors.primaryGold),
            ),
    );
  }
}

void _showEntryCodeSheet(
  BuildContext context,
  MuseumTicket ticket,
  AppLocalizations l10n,
  bool isArabic,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 18, 18),
            child: _GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: Directionality.of(context),
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primaryGold,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.myTicketsEntryQr,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.displaySectionTitle(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _EntryQrPreview(data: ticket.qrCodeValue),
                  const SizedBox(height: 14),
                  _CodeBox(
                    label: l10n.myTicketsMuseumGateCode,
                    code: ticket.qrCodeValue,
                    helper: l10n.myTicketsUseAtGate,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: _GoldButton(
                      label: l10n.close,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _EntryQrPreview extends StatelessWidget {
  const _EntryQrPreview({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.goldBorder(0.30)),
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 210,
          gapless: false,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

_RobotAction _robotActionFor(
  AppSessionProvider sessionProvider,
  AppLocalizations l10n,
) {
  if (sessionProvider.isTourCompleted) {
    return _RobotAction(
      label: l10n.myTicketsViewSummary,
      icon: Icons.summarize_outlined,
      destination: _RobotActionDestination.summary,
    );
  }
  if (sessionProvider.isInActiveTour || sessionProvider.isTourPaused) {
    return _RobotAction(
      label: l10n.myTicketsContinueTour,
      icon: Icons.play_arrow_rounded,
      destination: _RobotActionDestination.liveTour,
    );
  }
  if (sessionProvider.isRobotConnected) {
    return _RobotAction(
      label: l10n.myTicketsOpenLiveTour,
      icon: Icons.smart_toy_outlined,
      destination: _RobotActionDestination.liveTour,
    );
  }
  return _RobotAction(
    label: l10n.startTourSetup,
    icon: Icons.qr_code_scanner_rounded,
    destination: _RobotActionDestination.qrScan,
  );
}

class _RobotAction {
  const _RobotAction({
    required this.label,
    required this.icon,
    required this.destination,
  });

  final String label;
  final IconData icon;
  final _RobotActionDestination destination;
}

enum _RobotActionDestination { qrScan, liveTour, summary, none }

String _formatDate(DateTime value, bool isArabic) {
  if (isArabic) {
    return DateFormat.yMMMd('ar').format(value);
  }
  return DateFormat('MMM d, yyyy').format(value);
}

String _money(double value) => '${value.toStringAsFixed(2)} EGP';

String _paymentStatusLabel(AppLocalizations l10n, String status) {
  return status == 'pay_at_counter' ? l10n.paymentStatusPayAtCounter : status;
}

String _shortCode(String id) {
  if (id.length <= 8) return id;
  return id.substring(id.length - 8);
}

String _ticketStatusLabel(AppLocalizations l10n, TicketStatus status) {
  final isArabic = l10n.localeName == 'ar';
  switch (status) {
    case TicketStatus.pending:
      return isArabic ? '\u0642\u064a\u062f \u0627\u0644\u062a\u062c\u0647\u064a\u0632' : 'Preparing';
    case TicketStatus.active:
      return isArabic ? '\u0646\u0634\u0637' : 'Active';
    case TicketStatus.paired:
      return isArabic ? '\u062a\u0645 \u0631\u0628\u0637 \u0627\u0644\u0631\u0648\u0628\u0648\u062a' : 'Paired';
    case TicketStatus.in_progress:
      return isArabic ? '\u0627\u0644\u062c\u0648\u0644\u0629 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629 \u062c\u0627\u0631\u064a\u0629' : 'In Progress';
    case TicketStatus.completed:
      return isArabic ? '\u0645\u0643\u062a\u0645\u0644' : 'Completed';
    case TicketStatus.used:
      return isArabic ? '\u0645\u0633\u062a\u062e\u062f\u0645\u0629' : 'Used';
    case TicketStatus.expired:
      return isArabic ? '\u0645\u0646\u062a\u0647\u064a\u0629' : 'Expired';
    case TicketStatus.cancelled:
      return isArabic ? '\u0645\u0644\u063a\u0627\u0629' : 'Cancelled';
  }
}

String _cancellationDeadlineMessage(bool isArabic) {
  return isArabic
      ? '\u064a\u0645\u0643\u0646\u0643 \u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u062d\u062c\u0632 \u062d\u062a\u0649 24 \u0633\u0627\u0639\u0629 \u0642\u0628\u0644 \u0645\u0648\u0639\u062f \u0627\u0644\u0632\u064a\u0627\u0631\u0629.'
      : 'Cancellation is available up to 24 hours before your visit.';
}

String? _cancellationBlockedMessage(
  TicketProvider ticketProvider,
  PurchasedTicketSet order,
  bool isArabic,
) {
  final museumTicket = order.museumTicket;
  final robotTicket = order.robotTourTicket;
  if (museumTicket == null || robotTicket == null) return null;
  if (museumTicket.status == TicketStatus.expired ||
      robotTicket.status == TicketStatus.expired) {
    return isArabic
        ? '\u0627\u0646\u062a\u0647\u0649 \u0645\u0648\u0639\u062f \u0647\u0630\u0647 \u0627\u0644\u062a\u0630\u0643\u0631\u0629\u060c \u0648\u0644\u0645 \u064a\u0639\u062f \u0627\u0644\u0625\u0644\u063a\u0627\u0621 \u0645\u062a\u0627\u062d\u0627\u064b.'
        : 'This ticket has expired, so cancellation is no longer available.';
  }
  if (robotTicket.status == TicketStatus.paired) {
    return isArabic
        ? '\u0644\u0627 \u064a\u0645\u0643\u0646 \u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u062d\u062c\u0632 \u0628\u0639\u062f \u0631\u0628\u0637 \u0627\u0644\u0631\u0648\u0628\u0648\u062a.'
        : 'Cancellation is unavailable after Robot Pairing.';
  }
  if (robotTicket.status == TicketStatus.in_progress) {
    return isArabic
        ? '\u0644\u0627 \u064a\u0645\u0643\u0646 \u0625\u0644\u063a\u0627\u0621 \u0627\u0644\u062d\u062c\u0632 \u0628\u0639\u062f \u0628\u062f\u0621 \u0627\u0644\u062c\u0648\u0644\u0629 \u0627\u0644\u0645\u0628\u0627\u0634\u0631\u0629.'
        : 'Cancellation is unavailable after the Live Tour starts.';
  }
  if (robotTicket.status == TicketStatus.completed) {
    return isArabic
        ? '\u0627\u0643\u062a\u0645\u0644\u062a \u0647\u0630\u0647 \u0627\u0644\u062c\u0648\u0644\u0629\u060c \u0648\u0644\u0645 \u064a\u0639\u062f \u0627\u0644\u0625\u0644\u063a\u0627\u0621 \u0645\u062a\u0627\u062d\u0627\u064b.'
        : 'This tour is complete, so cancellation is no longer available.';
  }
  if (museumTicket.status == TicketStatus.cancelled ||
      robotTicket.status == TicketStatus.cancelled) {
    return null;
  }
  if (museumTicket.status == TicketStatus.used) {
    return isArabic
        ? '\u062a\u0645 \u0627\u0633\u062a\u062e\u062f\u0627\u0645 \u062a\u0630\u0643\u0631\u0629 \u062f\u062e\u0648\u0644 \u0627\u0644\u0645\u062a\u062d\u0641\u060c \u0648\u0644\u0645 \u064a\u0639\u062f \u0627\u0644\u0625\u0644\u063a\u0627\u0621 \u0645\u062a\u0627\u062d\u0627\u064b.'
        : 'This Museum Entry Ticket has already been used.';
  }
  if (museumTicket.status == TicketStatus.active &&
      robotTicket.status == TicketStatus.active &&
      ticketProvider.isWithinCancellationDeadline(order)) {
    return _cancellationDeadlineMessage(isArabic);
  }
  return null;
}

String _friendlyCancellationFailure(String? error, bool isArabic) {
  if (error == _cancellationDeadlineMessage(false) ||
      error == _cancellationDeadlineMessage(true)) {
    return _cancellationDeadlineMessage(isArabic);
  }
  if (error != null && error.toLowerCase().contains('connection issue')) {
    return isArabic
        ? '\u062d\u062f\u062b\u062a \u0645\u0634\u0643\u0644\u0629 \u0641\u064a \u0627\u0644\u0627\u062a\u0635\u0627\u0644. \u064a\u0631\u062c\u0649 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0627\u0644\u0625\u0646\u062a\u0631\u0646\u062a \u0648\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
        : 'Connection issue. Please check your internet connection and try again.';
  }
  return isArabic
      ? '\u062d\u062f\u062b \u062e\u0637\u0623 \u0645\u0627. \u064a\u0631\u062c\u0649 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
      : 'Something went wrong. Please try again.';
}

String _tourTypeLabel(AppLocalizations l10n, RobotTourType tourType) {
  switch (tourType) {
    case RobotTourType.none:
      return l10n.ticketsNoRobotTour;
    case RobotTourType.standard:
      return l10n.ticketsStandardTour;
    case RobotTourType.personalized:
      return l10n.ticketsPersonalizedTour;
  }
}

String _languageLabel(AppLocalizations l10n, String languageCode) {
  switch (languageCode.toLowerCase().replaceAll('-', '_')) {
    case 'ar':
    case 'arabic':
      return l10n.ticketsArabic;
    case 'egyptian_arabic':
      return l10n.egyptianArabic;
    default:
      return l10n.ticketsEnglish;
  }
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

List<String> _newBookingExhibitIds(List<String> ids) =>
    ids.where((id) => id.startsWith('artifact_')).toList();

String _standardRouteLabel(AppLocalizations l10n, String routeName) {
  if (routeName == StandardTourConfig.defaultConfig.routeName) {
    return l10n.myTicketsStandardRouteName;
  }
  return routeName;
}

String? _routeTitle(RobotTourTicket ticket, bool isArabic) {
  final title = isArabic
      ? ticket.routeTitleAr ?? ticket.routeTitleEn
      : ticket.routeTitleEn ?? ticket.routeTitleAr;
  if (title == null || title.trim().isEmpty) return null;
  return title;
}

String _exhibitNames(List<Exhibit> exhibits, List<String> ids, String lang) {
  if (ids.isEmpty) return '';
  final byId = {for (final exhibit in exhibits) exhibit.id: exhibit};
  return ids.map((id) => byId[id]?.getName(lang) ?? id).join(' \u2022 ');
}

String _themeLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'ancient-kings':
      return l10n.tourThemeAncientKings;
    case 'daily-life':
      return l10n.tourThemeDailyLife;
    case 'mummies':
      return l10n.tourThemeMummies;
    case 'symbols':
      return l10n.tourThemeSymbols;
    case 'architecture':
      return l10n.tourThemeArchitecture;
    case 'hidden-stories':
      return l10n.tourThemeHiddenStories;
    case 'photo-highlights':
      return l10n.tourThemePhotoHighlights;
  }
  return id;
}

String _accessibilityLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'step-free':
      return l10n.tourAccessStepFree;
    case 'fewer-stairs':
      return l10n.tourAccessFewerStairs;
    case 'seating-breaks':
      return l10n.tourAccessSeatingBreaks;
    case 'slower-narration':
      return l10n.tourAccessSlowNarration;
    case 'high-contrast':
      return l10n.tourAccessHighContrast;
    case 'audio-first':
      return l10n.tourAccessAudioFirst;
  }
  return id;
}

String _visitorModeLabel(AppLocalizations l10n, VisitorMode mode) {
  switch (mode) {
    case VisitorMode.adult:
      return l10n.tourVisitorAdults;
    case VisitorMode.student:
      return l10n.tourVisitorStudents;
    case VisitorMode.kidsFamily:
      return l10n.tourVisitorKidsFamily;
    case VisitorMode.disabledVisitor:
      return l10n.tourVisitorDisabled;
  }
}

String _paceLabel(AppLocalizations l10n, TourPace pace) {
  switch (pace) {
    case TourPace.relaxed:
      return l10n.tourPaceRelaxed;
    case TourPace.normal:
      return l10n.tourPaceNormal;
    case TourPace.fast:
      return l10n.tourPaceFast;
  }
}
