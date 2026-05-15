import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart';
import '../../models/auth_provider.dart';
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
                  sessionProvider,
                  l10n,
                  isArabic,
                )
              : _AccountRequiredState(l10n: l10n, isArabic: isArabic),
        ),
      ),
    );
  }

  Widget _buildWallet(
    BuildContext context,
    TicketProvider ticketProvider,
    AppSessionProvider sessionProvider,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final orders = ticketProvider.purchasedTicketSets;
    if (ticketProvider.isLoadingTickets && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      );
    }

    if (orders.isEmpty) {
      return _EmptyTicketsState(l10n: l10n, isArabic: isArabic);
    }

    final sortedOrders = orders.toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
      children: [
        _IntroCard(
          title: l10n.myTicketsWalletTitle,
          subtitle: ticketProvider.ticketError ?? l10n.myTicketsWalletSubtitle,
          icon: Icons.confirmation_number_outlined,
          isArabic: isArabic,
        ),
        const SizedBox(height: 18),
        ...sortedOrders.map(
          (order) => Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 18),
            child: _OrderCard(
              order: order,
              sessionProvider: sessionProvider,
              l10n: l10n,
              isArabic: isArabic,
            ),
          ),
        ),
      ],
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
  const _EmptyTicketsState({required this.l10n, required this.isArabic});

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
                  onTap: () => Navigator.pushNamed(context, AppRoutes.tickets),
                ),
              ),
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
    required this.sessionProvider,
    required this.l10n,
    required this.isArabic,
  });

  final PurchasedTicketSet order;
  final AppSessionProvider sessionProvider;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final museumTicket = order.museumTicket;
    final robotTicket = order.robotTourTicket;
    final date = museumTicket?.visitDate ?? robotTicket?.visitDate;
    final timeSlot = museumTicket?.timeSlot ?? robotTicket?.timeSlot;
    final formattedDate = _formatDate(date ?? order.purchasedAt, isArabic);

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
              sessionProvider: sessionProvider,
              l10n: l10n,
              isArabic: isArabic,
            ),
          ],
          if (museumTicket?.status == TicketStatus.active &&
              robotTicket?.status == TicketStatus.active) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: _OutlineButton(
                label: 'Cancel booking',
                onTap: () async {
                  final ok = await context
                      .read<TicketProvider>()
                      .cancelBooking(order);
                  if (!context.mounted) return;
                  final error = context.read<TicketProvider>().ticketError;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Booking cancelled.'
                            : error ?? 'Unable to cancel this booking.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
  });

  final PurchasedTicketSet order;
  final String visitDate;
  final String timeSlot;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
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
            _StatusPill(label: _paymentStatusLabel(order.paymentRecord.status)),
          ],
        ),
        const SizedBox(height: 12),
        _InfoGrid(
          items: [
            _InfoItem(l10n.visitDate, visitDate),
            _InfoItem(l10n.timeSlot, timeSlot),
            _InfoItem(l10n.myTicketsTotalPaid, _money(order.totalAmount)),
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
    required this.sessionProvider,
    required this.l10n,
    required this.isArabic,
  });

  final RobotTourTicket ticket;
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
            ],
          ),
          const SizedBox(height: 14),
          _CodeBox(
            label: l10n.myTicketsRobotPassCode,
            code: ticket.qrCodeValue ?? ticket.id,
            helper: l10n.myTicketsRobotPairingSeparate,
          ),
          const SizedBox(height: 14),
          _RobotConfigSummary(ticket: ticket, l10n: l10n, isArabic: isArabic),
          const SizedBox(height: 14),
          _MutedText(l10n.myTicketsPhysicalRobotQrNote),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _RobotActionButton(
              sessionProvider: sessionProvider,
              l10n: l10n,
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
    required this.l10n,
    required this.isArabic,
  });

  final RobotTourTicket ticket;
  final AppLocalizations l10n;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    if (ticket.tourType == RobotTourType.personalized) {
      final config = ticket.personalizedTourConfig;
      if (config == null) {
        return _MutedText(l10n.myTicketsNoPreferencesSaved);
      }
      return Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _SectionLabel(l10n.myTicketsPreferencesSummary),
          const SizedBox(height: 8),
          _BreakdownLine(
            label: l10n.myTicketsSelectedExhibitsCount,
            value: '${config.selectedExhibitIds.length}',
          ),
          _BreakdownLine(
            label: l10n.myTicketsThemes,
            value: config.selectedThemes.isEmpty
                ? l10n.myTicketsNone
                : config.selectedThemes
                      .map((id) => _themeLabel(l10n, id))
                      .join(' • '),
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
                      .join(' • '),
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
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.myTicketsRouteSummary),
        const SizedBox(height: 8),
        _BreakdownLine(
          label: l10n.myTicketsRouteName,
          value: _standardRouteLabel(
            l10n,
            config?.routeName ?? ticket.packageName,
          ),
        ),
        _BreakdownLine(
          label: l10n.myTicketsRouteStops,
          value:
              '${config?.routeExhibitIds.length ?? ticket.selectedArtifactIds?.length ?? 0}',
        ),
      ],
    );
  }
}

class _RobotActionButton extends StatelessWidget {
  const _RobotActionButton({required this.sessionProvider, required this.l10n});

  final AppSessionProvider sessionProvider;
  final AppLocalizations l10n;

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
              arguments: QRScanMode.robotConnection,
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
  const _OutlineButton({required this.label, required this.onTap});

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

String _paymentStatusLabel(String status) {
  return status == 'pay_at_counter' ? 'Pay at counter' : status;
}

String _shortCode(String id) {
  if (id.length <= 8) return id;
  return id.substring(id.length - 8);
}

String _ticketStatusLabel(AppLocalizations l10n, TicketStatus status) {
  switch (status) {
    case TicketStatus.pending:
      return l10n.pending;
    case TicketStatus.active:
      return l10n.active;
    case TicketStatus.used:
      return l10n.myTicketsUsed;
    case TicketStatus.expired:
      return l10n.expired;
    case TicketStatus.cancelled:
      return l10n.myTicketsCancelled;
  }
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
      return 'Egyptian Arabic';
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
  return slot.replaceAll('AM', 'ص').replaceAll('PM', 'م');
}

String _standardRouteLabel(AppLocalizations l10n, String routeName) {
  if (routeName == StandardTourConfig.defaultConfig.routeName) {
    return l10n.myTicketsStandardRouteName;
  }
  return routeName;
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
