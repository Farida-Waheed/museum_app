import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/services/mock_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exhibit.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class TourCustomizationScreen extends StatefulWidget {
  const TourCustomizationScreen({super.key});

  @override
  State<TourCustomizationScreen> createState() =>
      _TourCustomizationScreenState();
}

class _TourCustomizationScreenState extends State<TourCustomizationScreen> {
  final Set<String> _selectedExhibitIds = {};
  final Set<String> _selectedThemes = {};
  final Set<String> _accessibilityNeeds = {};

  int? _durationMinutes;
  String? _languageCode;
  VisitorMode? _visitorMode;
  TourPace? _pace;
  bool _photoSpotsEnabled = true;
  bool _avoidCrowds = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<TicketProvider>().currentOrderDraft;
    final config =
        draft.personalizedTourConfig ?? PersonalizedTourConfig.defaultConfig;
    _selectedExhibitIds.addAll(config.selectedExhibitIds);
    _selectedThemes.addAll(config.selectedThemes);
    _accessibilityNeeds.addAll(config.accessibilityNeeds);
    _durationMinutes = config.durationMinutes;
    _languageCode = config.languageCode;
    _visitorMode = config.visitorMode;
    _pace = config.pace;
    _photoSpotsEnabled = config.photoSpotsEnabled;
    _avoidCrowds = config.avoidCrowds;
  }

  void _toggleSetValue(Set<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  void _save(AppLocalizations l10n) {
    if (_selectedExhibitIds.isEmpty) {
      _showValidation(l10n.tourCustomizeSelectExhibitError);
      return;
    }
    if (_durationMinutes == null) {
      _showValidation(l10n.tourCustomizeDurationError);
      return;
    }
    if (_languageCode == null) {
      _showValidation(l10n.tourCustomizeLanguageError);
      return;
    }
    if (_visitorMode == null) {
      _showValidation(l10n.tourCustomizeVisitorModeError);
      return;
    }
    if (_pace == null) {
      _showValidation(l10n.tourCustomizePaceError);
      return;
    }

    final config = PersonalizedTourConfig(
      selectedExhibitIds: _selectedExhibitIds.toList(),
      selectedThemes: _selectedThemes.toList(),
      durationMinutes: _durationMinutes!,
      languageCode: _languageCode!,
      accessibilityNeeds: _accessibilityNeeds.toList(),
      visitorMode: _visitorMode!,
      pace: _pace!,
      photoSpotsEnabled: _photoSpotsEnabled,
      avoidCrowds: _avoidCrowds,
    );
    context.read<TicketProvider>().updatePersonalizedTourConfig(config);
    Navigator.pop(context);
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName == 'ar';
    final exhibits = MockDataService.getAllExhibits();

    return AppMenuShell(
      title: 'HORUS-BOT',
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      backgroundColor: AppColors.baseBlack,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    20,
                    24,
                    20,
                    120,
                  ),
                  children: [
                    _IntroCard(l10n: l10n, isArabic: isArabic),
                    const SizedBox(height: 18),
                    _ExhibitSelectionCard(
                      l10n: l10n,
                      exhibits: exhibits,
                      selectedIds: _selectedExhibitIds,
                      isArabic: isArabic,
                      onToggle: (id) =>
                          _toggleSetValue(_selectedExhibitIds, id),
                    ),
                    const SizedBox(height: 18),
                    _ChipSectionCard(
                      title: l10n.tourCustomizeThemesTitle,
                      subtitle: l10n.tourCustomizeThemesSubtitle,
                      options: _themeOptions(l10n),
                      selectedIds: _selectedThemes,
                      isArabic: isArabic,
                      onToggle: (id) => _toggleSetValue(_selectedThemes, id),
                    ),
                    const SizedBox(height: 18),
                    _SingleChoiceSection<int>(
                      title: l10n.duration,
                      options: const [45, 60, 90, 120],
                      selected: _durationMinutes,
                      labelFor: (value) => l10n.ticketsDurationValue(value),
                      onSelected: (value) =>
                          setState(() => _durationMinutes = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _SingleChoiceSection<String>(
                      title: l10n.language,
                      options: const ['en', 'ar'],
                      selected: _languageCode,
                      labelFor: (value) => value == 'ar'
                          ? l10n.ticketsArabic
                          : l10n.ticketsEnglish,
                      onSelected: (value) =>
                          setState(() => _languageCode = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _ChipSectionCard(
                      title: l10n.tourCustomizeAccessibilityTitle,
                      subtitle: l10n.tourCustomizeAccessibilitySubtitle,
                      options: _accessibilityOptions(l10n),
                      selectedIds: _accessibilityNeeds,
                      isArabic: isArabic,
                      onToggle: (id) =>
                          _toggleSetValue(_accessibilityNeeds, id),
                    ),
                    const SizedBox(height: 18),
                    _SingleChoiceSection<VisitorMode>(
                      title: l10n.tourCustomizeVisitorModeTitle,
                      options: VisitorMode.values,
                      selected: _visitorMode,
                      labelFor: (mode) => _visitorModeLabel(l10n, mode),
                      onSelected: (value) =>
                          setState(() => _visitorMode = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _SingleChoiceSection<TourPace>(
                      title: l10n.tourCustomizePaceTitle,
                      options: TourPace.values,
                      selected: _pace,
                      labelFor: (pace) => _paceLabel(l10n, pace),
                      onSelected: (value) => setState(() => _pace = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _PreferenceSwitchCard(
                      title: l10n.tourCustomizePhotoSpotsTitle,
                      subtitle: l10n.tourCustomizePhotoSpotsSubtitle,
                      value: _photoSpotsEnabled,
                      onChanged: (value) =>
                          setState(() => _photoSpotsEnabled = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _PreferenceSwitchCard(
                      title: l10n.tourCustomizeAvoidCrowdsTitle,
                      subtitle: l10n.tourCustomizeAvoidCrowdsSubtitle,
                      value: _avoidCrowds,
                      onChanged: (value) =>
                          setState(() => _avoidCrowds = value),
                      isArabic: isArabic,
                    ),
                    const SizedBox(height: 18),
                    _SummaryCard(
                      l10n: l10n,
                      exhibitCount: _selectedExhibitIds.length,
                      themeCount: _selectedThemes.length,
                      durationMinutes: _durationMinutes,
                      languageCode: _languageCode,
                      visitorMode: _visitorMode,
                      pace: _pace,
                      photoSpotsEnabled: _photoSpotsEnabled,
                      avoidCrowds: _avoidCrowds,
                      isArabic: isArabic,
                    ),
                  ],
                ),
              ),
              _SaveBar(l10n: l10n, onSave: () => _save(l10n)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionItem {
  const _OptionItem({required this.id, required this.label});

  final String id;
  final String label;
}

String _safeLocalizedText(String localizedValue, String fallbackValue) {
  final looksCorrupted = RegExp(r'[ØÙÂâ]').hasMatch(localizedValue);
  return looksCorrupted ? fallbackValue : localizedValue;
}

List<_OptionItem> _themeOptions(AppLocalizations l10n) => [
  _OptionItem(id: 'ancient-kings', label: l10n.tourThemeAncientKings),
  _OptionItem(id: 'daily-life', label: l10n.tourThemeDailyLife),
  _OptionItem(id: 'mummies', label: l10n.tourThemeMummies),
  _OptionItem(id: 'symbols', label: l10n.tourThemeSymbols),
  _OptionItem(id: 'architecture', label: l10n.tourThemeArchitecture),
  _OptionItem(id: 'hidden-stories', label: l10n.tourThemeHiddenStories),
  _OptionItem(id: 'photo-highlights', label: l10n.tourThemePhotoHighlights),
];

List<_OptionItem> _accessibilityOptions(AppLocalizations l10n) => [
  _OptionItem(id: 'step-free', label: l10n.tourAccessStepFree),
  _OptionItem(id: 'fewer-stairs', label: l10n.tourAccessFewerStairs),
  _OptionItem(id: 'seating-breaks', label: l10n.tourAccessSeatingBreaks),
  _OptionItem(id: 'slower-narration', label: l10n.tourAccessSlowNarration),
  _OptionItem(id: 'high-contrast', label: l10n.tourAccessHighContrast),
  _OptionItem(id: 'audio-first', label: l10n.tourAccessAudioFirst),
];

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

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.l10n, required this.isArabic});

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
            l10n.tourCustomizeTitle,
            style: AppTextStyles.displayScreenTitle(
              context,
            ).copyWith(color: AppColors.primaryGold, fontSize: 24),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tourCustomizeSubtitle,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.bodyText, height: 1.45),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

class _ExhibitSelectionCard extends StatelessWidget {
  const _ExhibitSelectionCard({
    required this.l10n,
    required this.exhibits,
    required this.selectedIds,
    required this.isArabic,
    required this.onToggle,
  });

  final AppLocalizations l10n;
  final List<Exhibit> exhibits;
  final Set<String> selectedIds;
  final bool isArabic;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final lang = isArabic ? 'ar' : 'en';
    return _SectionCard(
      title: l10n.tourCustomizeExhibitsTitle,
      subtitle: l10n.tourCustomizeExhibitsSubtitle,
      isArabic: isArabic,
      child: Column(
        children: exhibits.map((exhibit) {
          final selected = selectedIds.contains(exhibit.id);
          final title = _safeLocalizedText(
            exhibit.getName(lang),
            exhibit.nameEn,
          );
          final subtitle = _safeLocalizedText(
            exhibit.getDescription(lang),
            exhibit.descriptionEn,
          );
          return _SelectableExhibitTile(
            title: title,
            subtitle: subtitle,
            imageAsset: exhibit.imageAsset,
            selected: selected,
            onTap: () => onToggle(exhibit.id),
          );
        }).toList(),
      ),
    );
  }
}

class _SelectableExhibitTile extends StatelessWidget {
  const _SelectableExhibitTile({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageAsset,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 58,
                    height: 58,
                    color: AppColors.secondaryGlass(0.4),
                    child: const Icon(
                      Icons.museum_outlined,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyPrimary(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primaryGold : AppColors.bodyText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipSectionCard extends StatelessWidget {
  const _ChipSectionCard({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedIds,
    required this.isArabic,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final List<_OptionItem> options;
  final Set<String> selectedIds;
  final bool isArabic;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      subtitle: subtitle,
      isArabic: isArabic,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return _ChoicePill(
            label: option.label,
            selected: selectedIds.contains(option.id),
            onTap: () => onToggle(option.id),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleChoiceSection<T> extends StatelessWidget {
  const _SingleChoiceSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
    required this.isArabic,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      isArabic: isArabic,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          return _ChoicePill(
            label: labelFor(option),
            selected: selected == option,
            onTap: () => onSelected(option),
          );
        }).toList(),
      ),
    );
  }
}

class _PreferenceSwitchCard extends StatelessWidget {
  const _PreferenceSwitchCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isArabic,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryGold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.l10n,
    required this.exhibitCount,
    required this.themeCount,
    required this.durationMinutes,
    required this.languageCode,
    required this.visitorMode,
    required this.pace,
    required this.photoSpotsEnabled,
    required this.avoidCrowds,
    required this.isArabic,
  });

  final AppLocalizations l10n;
  final int exhibitCount;
  final int themeCount;
  final int? durationMinutes;
  final String? languageCode;
  final VisitorMode? visitorMode;
  final TourPace? pace;
  final bool photoSpotsEnabled;
  final bool avoidCrowds;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l10n.tourCustomizeSummaryTitle,
      isArabic: isArabic,
      child: Column(
        children: [
          _SummaryLine(
            label: l10n.tourCustomizeSelectedExhibits,
            value: '$exhibitCount',
          ),
          _SummaryLine(
            label: l10n.tourCustomizeSelectedThemes,
            value: '$themeCount',
          ),
          _SummaryLine(
            label: l10n.duration,
            value: durationMinutes == null
                ? l10n.tourCustomizeNotSelected
                : l10n.ticketsDurationValue(durationMinutes!),
          ),
          _SummaryLine(
            label: l10n.language,
            value: languageCode == null
                ? l10n.tourCustomizeNotSelected
                : languageCode == 'ar'
                ? l10n.ticketsArabic
                : l10n.ticketsEnglish,
          ),
          _SummaryLine(
            label: l10n.tourCustomizeVisitorModeTitle,
            value: visitorMode == null
                ? l10n.tourCustomizeNotSelected
                : _visitorModeLabel(l10n, visitorMode!),
          ),
          _SummaryLine(
            label: l10n.tourCustomizePaceTitle,
            value: pace == null
                ? l10n.tourCustomizeNotSelected
                : _paceLabel(l10n, pace!),
          ),
          _SummaryLine(
            label: l10n.tourCustomizePhotoSpotsTitle,
            value: photoSpotsEnabled ? l10n.enabled : l10n.disabled,
          ),
          _SummaryLine(
            label: l10n.tourCustomizeAvoidCrowdsTitle,
            value: avoidCrowds ? l10n.enabled : l10n.disabled,
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.l10n, required this.onSave});

  final AppLocalizations l10n;
  final VoidCallback onSave;

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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkInk,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.tourCustomizeSave,
              style: AppTextStyles.buttonLabel(context),
            ),
          ),
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
            style: AppTextStyles.displaySectionTitle(
              context,
            ).copyWith(color: AppColors.softGold),
            textAlign: TextAlign.start,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium, height: 1.35),
              textAlign: TextAlign.start,
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
              textAlign: TextAlign.start,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
