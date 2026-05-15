import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/tour_provider.dart';
import '../../services/visit_summary_repository.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/primary_button.dart';

class VisitSummaryScreen extends StatefulWidget {
  const VisitSummaryScreen({super.key});

  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  final VisitSummaryRepository _repository = VisitSummaryRepository();
  Future<VisitSummaryData>? _summaryFuture;
  String? _loadedSessionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionProvider = context.watch<AppSessionProvider>();
    final tourProvider = context.watch<TourProvider>();
    final sessionId =
        sessionProvider.activeSessionId ?? tourProvider.activeSessionId;
    if (_loadedSessionId != sessionId) {
      _loadedSessionId = sessionId;
      _summaryFuture = sessionId == null
          ? Future.value(
              const VisitSummaryData(
                session: null,
                robotTicket: null,
                photos: [],
                questions: [],
              ),
            )
          : _repository.load(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppMenuShell(
      title: l10n.visitSummary.toUpperCase(),
      backgroundColor: AppColors.darkBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: FutureBuilder<VisitSummaryData>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              );
            }
            if (snapshot.hasError) {
              return _StateMessage(
                icon: Icons.cloud_off_rounded,
                title: isArabic
                    ? 'تعذر تحميل ملخص الزيارة'
                    : 'Could not load visit summary',
                body: isArabic
                    ? 'تحقق من الاتصال وحاول مرة أخرى.'
                    : 'Check your connection and try again.',
              );
            }

            final data = snapshot.data;
            if (data == null || data.session == null) {
              return _StateMessage(
                icon: Icons.route_outlined,
                title: isArabic ? 'لا توجد جولة نشطة' : 'No tour session found',
                body: isArabic
                    ? 'سيظهر ملخص الزيارة بعد انتهاء جولة حورس.'
                    : 'Your visit summary appears after a Horus guided tour.',
              );
            }

            return _SummaryContent(data: data);
          },
        ),
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  final VisitSummaryData data;

  const _SummaryContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final isArabic = lang == 'ar';
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    final session = data.session!;
    final selectedIds = session.selectedExhibitIds;
    final visitedIds = session.visitedExhibitIds;
    final skippedIds = selectedIds
        .where((id) => !visitedIds.contains(id))
        .toList(growable: false);
    final completedIds = visitedIds
        .where((id) => selectedIds.isEmpty || selectedIds.contains(id))
        .toList(growable: false);
    final duration = _durationLabel(
      session.startedAt,
      session.completedAt ?? session.updatedAt,
      isArabic,
    );
    final endTime = session.completedAt == null
        ? (isArabic ? 'غير متاح' : 'Not available')
        : DateFormat.yMMMd(lang).add_jm().format(session.completedAt!);
    final ticket = data.robotTicket;
    final language = ticket?.languageCode == 'ar'
        ? (isArabic ? 'العربية' : 'Arabic')
        : (isArabic ? 'الإنجليزية' : 'English');
    final tourType = ticket == null
        ? (isArabic ? 'جولة حورس' : 'Horus tour')
        : ticket.tourType.name;
    final routeNames = selectedIds
        .map((id) => _exhibitName(exhibits, id, lang))
        .where((name) => name.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      child: Column(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  blurRadius: 34,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 72,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.congrats,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayArtifactTitle(context).copyWith(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'أنهى حورس جولتك وحفظ أبرز لحظاتها.'
                : 'Horus completed your tour and saved the highlights.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.helperText, height: 1.5),
          ),
          const SizedBox(height: 34),
          _MetricGrid(
            items: [
              _MetricItem(
                label: l10n.exhibitsVisited,
                value: '${visitedIds.length}',
                icon: Icons.museum_outlined,
              ),
              _MetricItem(
                label: isArabic ? 'اكتملت' : 'Completed',
                value: '${completedIds.length}',
                icon: Icons.task_alt_rounded,
              ),
              _MetricItem(
                label: isArabic ? 'تم تخطيها' : 'Skipped',
                value: '${skippedIds.length}',
                icon: Icons.skip_next_rounded,
              ),
              _MetricItem(
                label: l10n.totalTime,
                value: duration,
                icon: Icons.timer_outlined,
              ),
              _MetricItem(
                label: isArabic ? 'الصور' : 'Photos',
                value: '${data.photos.length}',
                icon: Icons.photo_camera_outlined,
              ),
              _MetricItem(
                label: isArabic ? 'الأسئلة' : 'Questions',
                value: '${data.questions.length}',
                icon: Icons.record_voice_over_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _DetailsPanel(
            rows: [
              _DetailRow(isArabic ? 'اللغة' : 'Language', language),
              _DetailRow(isArabic ? 'نوع الجولة' : 'Tour type', tourType),
              _DetailRow(isArabic ? 'وقت الانتهاء' : 'End time', endTime),
              _DetailRow(
                isArabic ? 'معرّف الجلسة' : 'Session',
                session.sessionId,
              ),
              _DetailRow(
                isArabic ? 'ملخص المسار' : 'Route summary',
                routeNames.isEmpty
                    ? (isArabic ? 'غير متاح' : 'Not available')
                    : routeNames.join(' • '),
              ),
            ],
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: l10n.shareVisit,
            onPressed: () {},
            icon: Icons.share,
            fullWidth: true,
          ),
          const SizedBox(height: 12),
          _OutlineAction(
            label: isArabic ? 'عرض ذكرياتي' : 'View My Memories',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.memories),
          ),
          const SizedBox(height: 12),
          _OutlineAction(
            label: l10n.done,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.mainHome),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }

  static String _exhibitName(List<Exhibit> exhibits, String id, String lang) {
    for (final exhibit in exhibits) {
      if (exhibit.id == id) return exhibit.getName(lang);
    }
    return id;
  }

  static String _durationLabel(
    DateTime? startedAt,
    DateTime? endedAt,
    bool isArabic,
  ) {
    if (startedAt == null || endedAt == null) {
      return isArabic ? 'غير متاح' : 'N/A';
    }
    final minutes = endedAt
        .difference(startedAt)
        .inMinutes
        .clamp(0, 9999)
        .toInt();
    if (minutes < 60) return isArabic ? '$minutes د' : '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return isArabic ? '$hours س $rest د' : '${hours}h ${rest}m';
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricItem> items;

  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.28,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _MetricCard(item: items[index]),
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;

  const _MetricCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.premiumGlassCard(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: AppColors.primaryGold, size: 24),
          const Spacer(),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge(
              context,
            ).copyWith(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.neutralMedium),
          ),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final List<_DetailRow> rows;

  const _DetailsPanel({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.secondaryGlassCard(radius: 20),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.label,
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(color: AppColors.neutralMedium),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.bodyPrimary(
                          context,
                        ).copyWith(color: Colors.white, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}

class _OutlineAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppDecorations.secondaryButton(),
        child: Text(label, style: AppTextStyles.buttonLabel(context)),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 54),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge(
                context,
              ).copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: AppColors.neutralMedium, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
