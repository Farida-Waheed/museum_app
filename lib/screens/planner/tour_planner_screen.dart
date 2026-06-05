import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/primary_button.dart';

class TourPlannerScreen extends StatefulWidget {
  const TourPlannerScreen({super.key});

  @override
  State<TourPlannerScreen> createState() => _TourPlannerScreenState();
}

class _TourPlannerScreenState extends State<TourPlannerScreen> {
  static const List<String> _interestOptions = [
    'Pharaohs',
    'Daily life',
    'Royal artifacts',
    'Mummies',
    'Architecture',
    'Mythology',
    'Kids friendly',
    'Short tour',
    'Photography spots',
  ];

  final Set<String> _selectedInterests = {'Royal artifacts'};
  final Set<String> _selectedExhibitIds = {};
  RobotTourType _tourType = RobotTourType.personalized;
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExhibitProvider>();
      if (provider.exhibits.isEmpty && !provider.isLoading) {
        provider.loadExhibits();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final exhibitProvider = context.watch<ExhibitProvider>();
    final exhibits = exhibitProvider.exhibits
        .where((exhibit) => exhibit.isActive)
        .toList();
    final recommended = _recommendedExhibits(exhibits);
    final selectedExhibits = exhibits
        .where((exhibit) => _selectedExhibitIds.contains(exhibit.id))
        .toList();
    final duration = _estimatedDuration(selectedExhibits);
    final price = _tourType == RobotTourType.personalized ? 350 : 200;

    return AppMenuShell(
      title: l10n.tourPlanner.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _HeroCard(isArabic: isArabic),
                const SizedBox(height: 18),
                _SectionCard(
                  title: isArabic ? 'نوع الجولة' : 'Tour type',
                  child: Row(
                    children: [
                      Expanded(
                        child: _TourTypeTile(
                          title: isArabic ? 'قياسية' : 'Standard',
                          subtitle: '200 EGP',
                          icon: Icons.route_rounded,
                          selected: _tourType == RobotTourType.standard,
                          onTap: () => setState(
                            () => _tourType = RobotTourType.standard,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TourTypeTile(
                          title: isArabic ? 'مخصصة' : 'Personalized',
                          subtitle: '350 EGP',
                          icon: Icons.tune_rounded,
                          selected: _tourType == RobotTourType.personalized,
                          emphasized: true,
                          onTap: () => setState(
                            () => _tourType = RobotTourType.personalized,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: isArabic ? 'اهتماماتك' : 'Interests',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _interestOptions.map((interest) {
                      final selected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            value
                                ? _selectedInterests.add(interest)
                                : _selectedInterests.remove(interest);
                            _generated = false;
                          });
                        },
                        selectedColor: AppColors.primaryGold,
                        checkmarkColor: AppColors.darkInk,
                        backgroundColor: AppColors.cinematicCard,
                        labelStyle: AppTextStyles.metadata(context).copyWith(
                          color: selected ? AppColors.darkInk : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primaryGold
                                : AppColors.goldBorder(0.16),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: isArabic ? 'اختر المعروضات' : 'Select exhibits',
                  child: exhibitProvider.isLoading && exhibits.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : exhibits.isEmpty
                      ? Text(
                          isArabic
                              ? 'لا توجد معروضات متاحة حاليا.'
                              : 'No exhibits are available right now.',
                          style: AppTextStyles.bodyPrimary(
                            context,
                          ).copyWith(color: AppColors.neutralMedium),
                        )
                      : Column(
                          children: exhibits.take(8).map((exhibit) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ExhibitCard(
                                exhibit: exhibit,
                                isArabic: isArabic,
                                selected: _selectedExhibitIds.contains(
                                  exhibit.id,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (_selectedExhibitIds.contains(
                                      exhibit.id,
                                    )) {
                                      _selectedExhibitIds.remove(exhibit.id);
                                    } else {
                                      _selectedExhibitIds.add(exhibit.id);
                                    }
                                    _generated = false;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: isArabic ? 'اقتراحات مناسبة' : 'Recommended for you',
                  child: recommended.isEmpty
                      ? Text(
                          isArabic
                              ? 'اختر اهتماماتك لعرض اقتراحات مناسبة.'
                              : 'Choose interests to see matching exhibits.',
                          style: AppTextStyles.bodyPrimary(
                            context,
                          ).copyWith(color: AppColors.neutralMedium),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: recommended.take(5).map((exhibit) {
                            return ActionChip(
                              label: Text(
                                exhibit.getName(isArabic ? 'ar' : 'en'),
                              ),
                              avatar: const Icon(Icons.add_rounded, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedExhibitIds.add(exhibit.id);
                                  _generated = false;
                                });
                              },
                              backgroundColor: AppColors.cinematicCard,
                              labelStyle: AppTextStyles.metadata(
                                context,
                              ).copyWith(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.goldBorder(0.16),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 18),
                _SummaryCard(
                  isArabic: isArabic,
                  tourType: _tourType,
                  interests: _selectedInterests.length,
                  exhibits: _selectedExhibitIds.length,
                  duration: duration,
                  price: price,
                  generated: _generated,
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _generated
                      ? (isArabic ? 'حجز هذه الجولة' : 'Book this tour')
                      : (isArabic ? 'إنشاء جولتي' : 'Generate my tour'),
                  onPressed: () {
                    if (_generated) {
                      _bookPlannedTour(
                        context,
                        exhibits: selectedExhibits.isEmpty
                            ? recommended.take(4).toList()
                            : selectedExhibits,
                      );
                    } else {
                      setState(() => _generated = true);
                    }
                  },
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Exhibit> _recommendedExhibits(List<Exhibit> exhibits) {
    if (_selectedInterests.isEmpty) return const [];
    final selected = _selectedInterests.map(_normalize).toSet();
    final matches = exhibits.where((exhibit) {
      if (_selectedExhibitIds.contains(exhibit.id)) return false;
      final tokens = <String>{
        _normalize(exhibit.category),
        ...exhibit.tags.map(_normalize),
        ...exhibit.themes.map(_normalize),
        if (exhibit.photoSpot) 'photography spots',
      };
      return tokens.any(
        (token) => selected.any(
          (interest) => token.contains(interest) || interest.contains(token),
        ),
      );
    }).toList();
    if (matches.isNotEmpty) return matches;
    return exhibits
        .where((exhibit) => !_selectedExhibitIds.contains(exhibit.id))
        .take(5)
        .toList();
  }

  int _estimatedDuration(List<Exhibit> exhibits) {
    if (exhibits.isEmpty) return 45;
    final total = exhibits.fold<int>(
      0,
      (sum, exhibit) => sum + (exhibit.recommendedDurationMin ?? 8),
    );
    return total.clamp(30, 75);
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('-', ' ');
  }

  void _bookPlannedTour(
    BuildContext context, {
    required List<Exhibit> exhibits,
  }) {
    final ticketProvider = context.read<TicketProvider>();
    final exhibitIds = exhibits.map((exhibit) => exhibit.id).toList();
    ticketProvider.resetOrderDraft();
    ticketProvider.setVisitorCategoryQuantity('egyptian-adult', 1);
    ticketProvider.selectRobotTourType(_tourType);
    if (_tourType == RobotTourType.personalized) {
      ticketProvider.updatePersonalizedTourConfig(
        PersonalizedTourConfig.defaultConfig.copyWith(
          selectedExhibitIds: exhibitIds,
          selectedThemes: _selectedInterests.toList(),
          durationMinutes: _estimatedDuration(exhibits),
          languageCode: Localizations.localeOf(context).languageCode == 'ar'
              ? 'arabic'
              : 'english',
          photoSpotsEnabled: exhibits.any((exhibit) => exhibit.photoSpot),
        ),
      );
    }
    Navigator.pushNamed(context, AppRoutes.buyTickets);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppDecorations.premiumGlassCard(
        radius: 24,
        highlighted: true,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.premiumGold,
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.darkInk),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'خطط لجولة Horus-Bot مخصصة'
                      : 'Plan a personalized Horus-Bot tour',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'اختر المعروضات والاهتمامات والوتيرة التي تريدها.'
                      : 'Choose the artifacts, themes, and pace you want Horus to guide you through.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.neutralMedium, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.premiumGlassCard(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.softGold, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TourTypeTile extends StatelessWidget {
  const _TourTypeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.16)
              : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected || emphasized
                ? AppColors.primaryGold
                : AppColors.goldBorder(0.16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.primaryGold : Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhibitCard extends StatelessWidget {
  const _ExhibitCard({
    required this.exhibit,
    required this.isArabic,
    required this.selected,
    required this.onTap,
  });

  final Exhibit exhibit;
  final bool isArabic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lang = isArabic ? 'ar' : 'en';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.14)
              : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primaryGold
                : AppColors.goldBorder(0.14),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ExhibitImage(exhibit: exhibit),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibit.getName(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    exhibit.category.isEmpty ? exhibit.floor : exhibit.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.neutralMedium),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.add_circle_outline,
              color: selected ? AppColors.primaryGold : AppColors.neutralMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExhibitImage extends StatelessWidget {
  const _ExhibitImage({required this.exhibit});

  final Exhibit exhibit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(gradient: AppGradients.premiumGold),
      child: const Icon(Icons.museum_rounded, color: AppColors.darkInk),
    );
    if (exhibit.imageUrl.isNotEmpty) {
      return Image.network(
        exhibit.imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    if (exhibit.imageAsset.isNotEmpty) {
      return Image.asset(
        exhibit.imageAsset,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    return placeholder;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isArabic,
    required this.tourType,
    required this.interests,
    required this.exhibits,
    required this.duration,
    required this.price,
    required this.generated,
  });

  final bool isArabic;
  final RobotTourType tourType;
  final int interests;
  final int exhibits;
  final int duration;
  final int price;
  final bool generated;

  @override
  Widget build(BuildContext context) {
    final typeLabel = tourType == RobotTourType.personalized
        ? (isArabic ? 'مخصصة' : 'Personalized')
        : (isArabic ? 'قياسية' : 'Standard');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.premiumGlassCard(
        radius: 18,
        highlighted: true,
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'ملخص الجولة' : 'Tour summary',
            style: AppTextStyles.titleMedium(
              context,
            ).copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: isArabic ? 'النوع' : 'Type', value: typeLabel),
          _SummaryLine(
            label: isArabic ? 'الاهتمامات' : 'Interests',
            value: '$interests',
          ),
          _SummaryLine(
            label: isArabic ? 'المعروضات' : 'Exhibits',
            value: '$exhibits',
          ),
          _SummaryLine(
            label: isArabic ? 'المدة' : 'Duration',
            value: '$duration min',
          ),
          _SummaryLine(
            label: isArabic ? 'سعر جولة الروبوت' : 'Robot tour price',
            value: '$price EGP',
          ),
          if (generated) ...[
            const SizedBox(height: 10),
            Text(
              isArabic
                  ? 'تم إنشاء المسار. يمكنك حجزه الآن.'
                  : 'Your route is ready. Book it with museum entry and robot tour selected.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: AppColors.softGold),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
