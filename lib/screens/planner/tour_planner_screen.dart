import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/ticket_order.dart';
import '../../models/ticket_provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/guest_prompt.dart';
import '../../widgets/primary_button.dart';

class TourPlannerScreen extends StatefulWidget {
  const TourPlannerScreen({super.key});

  @override
  State<TourPlannerScreen> createState() => _TourPlannerScreenState();
}

class _TourPlannerScreenState extends State<TourPlannerScreen> {
  static const String _prefsKey = 'tour_planner_draft_v2';
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
  static const List<String> _accessibilityOptions = [
    'Family Friendly',
    'Rest Stops Preferred',
  ];
  static const List<_DurationOption> _durationOptions = [
    _DurationOption('Express', 30, 6),
    _DurationOption('Standard', 45, 9),
    _DurationOption('Extended', 60, 12),
    _DurationOption('Full Experience', 90, 18),
  ];

  final Set<String> _selectedInterests = {};
  final Set<String> _selectedExhibitIds = {};
  final Set<String> _accessibilityPreferences = {};
  RobotTourType _tourType = RobotTourType.personalized;
  int _durationMinutes = 45;
  bool _includePhotoStops = true;
  bool _generated = false;
  bool _showValidation = false;
  bool _showAllExhibits = false;
  String? _inlineMessage;
  List<Exhibit> _generatedRoute = const [];

  @override
  void initState() {
    super.initState();
    _restoreDraft();
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
    final authProvider = context.watch<AuthProvider>();
    final exhibitProvider = context.watch<ExhibitProvider>();
    final exhibits = exhibitProvider.exhibits
        .where((exhibit) => exhibit.isActive)
        .toList();
    final filteredExhibits = _filteredExhibits(exhibits);
    final visibleExhibits = _showAllExhibits ? exhibits : filteredExhibits;
    final selectedExhibits = exhibits
        .where((exhibit) => _selectedExhibitIds.contains(exhibit.id))
        .toList();
    final recommended = _recommendedExhibits(exhibits);
    final routePreview = _generated ? _generatedRoute : selectedExhibits;
    final price = _tourType == RobotTourType.personalized ? 350 : 200;
    final matchScore = _matchScore(routePreview, recommended);
    final languageLabel = _tourLanguageLabel(context);

    if (!authProvider.isLoggedIn) {
      return AppMenuShell(
        title: l10n.tourPlanner.toUpperCase(),
        backgroundColor: AppColors.cinematicBackground,
        bottomNavigationBar: const BottomNav(currentIndex: 0),
        showChatButton: true,
        body: DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.cinematicBackground),
          child: GuestPrompt(
            icon: Icons.route_outlined,
            title: 'Plan Your Horus-Bot Tour',
            body:
                'Sign in to create and save a personalized route through the museum.',
            primaryLabel: l10n.login,
            secondaryLabel: l10n.createAccount,
            tertiaryLabel: l10n.exhibits,
            onTertiary: () => Navigator.pushNamed(context, AppRoutes.exhibits),
          ),
        ),
      );
    }

    return AppMenuShell(
      title: l10n.tourPlanner.toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      showChatButton: true,
      body: Container(
        decoration: const BoxDecoration(color: AppColors.cinematicBackground),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.screenHorizontalCompact,
              20,
              AppSpacing.screenHorizontalCompact,
              176,
            ),
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                const _HeroCard(),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionCard(
                  title: 'Tour type',
                  child: Row(
                    children: [
                      Expanded(
                        child: _TourTypeTile(
                          title: 'Standard',
                          subtitle: 'Recommended route - 200 EGP',
                          icon: Icons.route_rounded,
                          selected: _tourType == RobotTourType.standard,
                          onTap: () => _updateDraft(() {
                            _tourType = RobotTourType.standard;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TourTypeTile(
                          title: 'Personalized',
                          subtitle: 'Custom exhibits and interests - 350 EGP',
                          icon: Icons.tune_rounded,
                          selected: _tourType == RobotTourType.personalized,
                          emphasized: true,
                          onTap: () => _updateDraft(() {
                            _tourType = RobotTourType.personalized;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _SectionCard(
                  title: 'Tour duration',
                  subtitle:
                      'Duration controls the number of stops Horus plans.',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _durationOptions.map((option) {
                      return _DurationChip(
                        option: option,
                        selected: _durationMinutes == option.minutes,
                        onTap: () => _changeDuration(option.minutes),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _SectionCard(
                  title: 'Interests',
                  subtitle: 'Select what you want Horus to focus on.',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _interestOptions.map((interest) {
                      final selected = _selectedInterests.contains(interest);
                      return _PlannerChip(
                        label: interest,
                        selected: selected,
                        onSelected: (value) => _updateDraft(() {
                          _showAllExhibits = false;
                          value
                              ? _selectedInterests.add(interest)
                              : _selectedInterests.remove(interest);
                        }),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _SectionCard(
                  title: 'Accessibility preferences',
                  subtitle:
                      'These preferences are saved with the generated tour plan.',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _accessibilityOptions.map((option) {
                      final selected = _accessibilityPreferences.contains(
                        option,
                      );
                      return _PlannerChip(
                        label: option,
                        selected: selected,
                        onSelected: (value) => _updateDraft(() {
                          value
                              ? _accessibilityPreferences.add(option)
                              : _accessibilityPreferences.remove(option);
                        }),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _PhotoExperienceCard(
                  enabled: _includePhotoStops,
                  onChanged: (value) => _updateDraft(() {
                    _includePhotoStops = value;
                  }),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _SectionCard(
                  title: 'Select exhibits',
                  subtitle: _exhibitFilterNote(
                    visibleCount: visibleExhibits.length,
                    totalCount: exhibits.length,
                  ),
                  child: exhibitProvider.isLoading && exhibits.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : exhibits.isEmpty
                      ? const _EmptyText(
                          text: 'No exhibits are available right now.',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SelectionCounter(
                              selected: _selectedExhibitIds.length,
                              max: _targetStopsForDuration(),
                            ),
                            const SizedBox(height: 12),
                            if (!_showAllExhibits &&
                                visibleExhibits.length < exhibits.length) ...[
                              _TextAction(
                                label: 'Show all exhibits',
                                onTap: () => setState(() {
                                  _showAllExhibits = true;
                                  _inlineMessage = null;
                                }),
                              ),
                              const SizedBox(height: 12),
                            ],
                            ...visibleExhibits.map((exhibit) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ExhibitCard(
                                  exhibit: exhibit,
                                  isArabic: isArabic,
                                  selected: _selectedExhibitIds.contains(
                                    exhibit.id,
                                  ),
                                  onTap: () => _toggleExhibit(exhibit.id),
                                ),
                              );
                            }),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                _SectionCard(
                  title: 'Recommended for you',
                  subtitle: 'Based on selected interests and exhibit data.',
                  child: recommended.isEmpty
                      ? const _EmptyText(
                          text: 'Choose interests to see matching exhibits.',
                        )
                      : Column(
                          children: recommended.take(4).map((exhibit) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _RecommendationCard(
                                exhibit: exhibit,
                                isArabic: isArabic,
                                reason: _recommendationReason(exhibit),
                                onAdd: () =>
                                    _toggleExhibit(exhibit.id, addOnly: true),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                if (_showValidation) ...[
                  _PlannerNotice(
                    text:
                        _inlineMessage ??
                        'Select at least one interest or exhibit to generate your Horus-Bot tour.',
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                ] else if (_inlineMessage != null) ...[
                  _PlannerNotice(text: _inlineMessage!),
                  const SizedBox(height: AppSpacing.cardGap),
                ],
                if (_generated) ...[
                  _GeneratedRouteCard(
                    route: _generatedRoute,
                    duration: _durationMinutes,
                    tourType: _tourType,
                    matchScore: matchScore,
                    reasons: _routeReasons(
                      routePreview: _generatedRoute,
                      recommended: recommended,
                    ),
                    includePhotoStops: _includePhotoStops,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                ],
                _SummaryCard(
                  isArabic: isArabic,
                  tourType: _tourType,
                  interests: _selectedInterests.length,
                  exhibits: routePreview.length,
                  duration: _durationMinutes,
                  accessibility: _accessibilityPreferences.toList(),
                  photoStopsEnabled: _includePhotoStops,
                  price: price,
                  generated: _generated,
                  languageLabel: languageLabel,
                  matchScore: matchScore,
                ),
                const SizedBox(height: AppSpacing.cardGap),
                PrimaryButton(
                  label: _generated ? 'Book this tour' : 'Generate my tour',
                  onPressed: () {
                    if (_generated) {
                      _bookPlannedTour(context, exhibits: _generatedRoute);
                    } else {
                      _generateRoute(
                        selectedExhibits: selectedExhibits,
                        recommended: recommended,
                        allExhibits: exhibits,
                      );
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

  void _updateDraft(VoidCallback update) {
    setState(() {
      update();
      _generated = false;
      _showValidation = false;
      _inlineMessage = null;
      _persistDraft();
    });
  }

  void _toggleExhibit(String exhibitId, {bool addOnly = false}) {
    final selected = _selectedExhibitIds.contains(exhibitId);
    if (!selected && _selectedExhibitIds.length >= _targetStopsForDuration()) {
      setState(() {
        _generated = false;
        _showValidation = false;
        _inlineMessage =
            'This duration supports up to ${_targetStopsForDuration()} stops.';
      });
      return;
    }
    _updateDraft(() {
      if (addOnly || !selected) {
        _selectedExhibitIds.add(exhibitId);
      } else {
        _selectedExhibitIds.remove(exhibitId);
      }
    });
  }

  void _changeDuration(int minutes) {
    setState(() {
      _durationMinutes = minutes;
      final maxStops = _targetStopsForDuration();
      if (_selectedExhibitIds.length > maxStops) {
        final kept = _selectedExhibitIds.take(maxStops).toList();
        _selectedExhibitIds
          ..clear()
          ..addAll(kept);
        _inlineMessage =
            'Your route was adjusted to fit the selected duration.';
      } else {
        _inlineMessage = null;
      }
      _generated = false;
      _showValidation = false;
      _persistDraft();
    });
  }

  void _generateRoute({
    required List<Exhibit> selectedExhibits,
    required List<Exhibit> recommended,
    required List<Exhibit> allExhibits,
  }) {
    if (_selectedInterests.isEmpty && selectedExhibits.isEmpty) {
      setState(() {
        _showValidation = true;
        _inlineMessage =
            'Select at least one interest or exhibit to generate your Horus-Bot tour.';
        _generated = false;
      });
      return;
    }

    final route = <Exhibit>[...selectedExhibits];
    final targetStops = _targetStopsForDuration();
    final candidates = <Exhibit>[
      if (_includePhotoStops)
        ...recommended.where((exhibit) => exhibit.photoSpot),
      ...recommended,
      ...allExhibits,
    ];
    for (final exhibit in candidates) {
      if (route.length >= targetStops) break;
      if (!route.any((item) => item.id == exhibit.id)) route.add(exhibit);
    }

    setState(() {
      _generatedRoute = route.take(targetStops).toList();
      _generated = true;
      _showValidation = false;
      _inlineMessage = null;
      _persistDraft();
    });
  }

  List<Exhibit> _filteredExhibits(List<Exhibit> exhibits) {
    if (_selectedInterests.isEmpty ||
        _selectedInterests.length >= _interestOptions.length) {
      return exhibits;
    }
    final filtered = exhibits.where(_matchesSelectedInterests).toList();
    return filtered.isEmpty ? exhibits : filtered;
  }

  List<Exhibit> _recommendedExhibits(List<Exhibit> exhibits) {
    if (_selectedInterests.isEmpty) return const [];
    final selected = _selectedInterests.map(_normalize).toSet();
    final matches = exhibits.where((exhibit) {
      if (_selectedExhibitIds.contains(exhibit.id)) return false;
      final tokens = _exhibitTokens(exhibit);
      return tokens.any(
        (token) => selected.any((interest) {
          return token.contains(interest) || interest.contains(token);
        }),
      );
    }).toList();
    if (matches.isNotEmpty) return matches;
    return exhibits
        .where((exhibit) => !_selectedExhibitIds.contains(exhibit.id))
        .take(5)
        .toList();
  }

  String _recommendationReason(Exhibit exhibit) {
    final tokens = <String>{
      _normalize(exhibit.category),
      ...exhibit.tags.map(_normalize),
      ...exhibit.themes.map(_normalize),
      if (exhibit.photoSpot) 'photography spots',
    };
    for (final interest in _selectedInterests) {
      final normalized = _normalize(interest);
      if (tokens.any(
        (token) => token.contains(normalized) || normalized.contains(token),
      )) {
        return 'Matches $interest';
      }
    }
    if (_includePhotoStops && exhibit.photoSpot) {
      return 'Includes photo opportunity';
    }
    return 'Related to selected themes';
  }

  bool _matchesSelectedInterests(Exhibit exhibit) {
    if (_selectedInterests.isEmpty) return true;
    final selected = _selectedInterests.map(_normalize).toSet();
    final tokens = _exhibitTokens(exhibit);
    return tokens.any((token) {
      return selected.any(
        (interest) => token.contains(interest) || interest.contains(token),
      );
    });
  }

  Set<String> _exhibitTokens(Exhibit exhibit) {
    final text = [
      exhibit.nameEn,
      exhibit.nameAr,
      exhibit.category,
      exhibit.floor,
      exhibit.descriptionEn,
      exhibit.descriptionAr,
    ].map(_normalize).join(' ');
    final tokens = <String>{
      _normalize(exhibit.category),
      ...exhibit.tags.map(_normalize),
      ...exhibit.themes.map(_normalize),
      if (exhibit.photoSpot) 'photography spots',
      if (text.contains('pharaoh') || text.contains('king')) 'pharaohs',
      if (text.contains('royal') || text.contains('king')) 'royal artifacts',
      if (text.contains('mumm')) 'mummies',
      if (text.contains('architect') || text.contains('column')) 'architecture',
      if (text.contains('daily') || text.contains('life')) 'daily life',
      if (text.contains('myth') || text.contains('god')) 'mythology',
    };
    return tokens.where((token) => token.isNotEmpty).toSet();
  }

  String _exhibitFilterNote({
    required int visibleCount,
    required int totalCount,
  }) {
    if (_showAllExhibits || _selectedInterests.isEmpty) {
      return 'Showing all available exhibits. Selected: ${_selectedExhibitIds.length} / ${_targetStopsForDuration()} stops.';
    }
    final interests = _selectedInterests.join(', ');
    final exactMatches = _filteredExhibitMatchCount();
    if (exactMatches == 0) {
      return 'No exact matches. Showing all exhibits so you can still build your tour. Selected: ${_selectedExhibitIds.length} / ${_targetStopsForDuration()} stops.';
    }
    return 'Showing exhibits matching: $interests. Selected: ${_selectedExhibitIds.length} / ${_targetStopsForDuration()} stops. $visibleCount of $totalCount shown.';
  }

  int _filteredExhibitMatchCount() {
    final exhibitProvider = context.read<ExhibitProvider>();
    final exhibits = exhibitProvider.exhibits
        .where((exhibit) => exhibit.isActive)
        .toList();
    return exhibits.where(_matchesSelectedInterests).length;
  }

  List<String> _routeReasons({
    required List<Exhibit> routePreview,
    required List<Exhibit> recommended,
  }) {
    final reasons = <String>[];
    for (final interest in _selectedInterests.take(2)) {
      reasons.add('Matches $interest');
    }
    if (_selectedExhibitIds.isNotEmpty) {
      reasons.add('Includes selected exhibits');
    }
    if (recommended.isNotEmpty) {
      reasons.add('Includes museum highlights');
    }
    reasons.add('Fits $_durationMinutes minute duration');
    if (_includePhotoStops &&
        routePreview.any((exhibit) => exhibit.photoSpot)) {
      reasons.add('Includes recommended photo stops');
    }
    if (_accessibilityPreferences.isNotEmpty) {
      reasons.add('Stores accessibility preferences');
    }
    return reasons.take(6).toList();
  }

  int _matchScore(List<Exhibit> routePreview, List<Exhibit> recommended) {
    var score = 62;
    score += (_selectedInterests.length * 6).clamp(0, 18);
    score += (_selectedExhibitIds.length * 5).clamp(0, 15);
    final recommendedIds = recommended.map((exhibit) => exhibit.id).toSet();
    final aligned = routePreview.where((exhibit) {
      return recommendedIds.contains(exhibit.id) ||
          _selectedExhibitIds.contains(exhibit.id);
    }).length;
    if (routePreview.isNotEmpty) {
      score += ((aligned / routePreview.length) * 12).round();
    }
    if (_includePhotoStops &&
        routePreview.any((exhibit) => exhibit.photoSpot)) {
      score += 5;
    }
    if (_accessibilityPreferences.isNotEmpty) score += 3;
    return score.clamp(0, 98);
  }

  int _targetStopsForDuration() {
    return _durationOptions
        .firstWhere(
          (option) => option.minutes == _durationMinutes,
          orElse: () => _durationOptions[1],
        )
        .targetStops;
  }

  String _tourLanguageLabel(BuildContext context) {
    final draft = context.watch<TicketProvider>().currentOrderDraft;
    final code = _tourType == RobotTourType.personalized
        ? draft.personalizedTourConfig?.languageCode
        : draft.standardTourConfig?.languageCode;
    final normalized =
        TourNarrationLanguage.normalize(code) ??
        (Localizations.localeOf(context).languageCode == 'ar'
            ? 'arabic'
            : 'english');
    return TourNarrationLanguage.label(
      normalized,
      Localizations.localeOf(context).languageCode == 'ar',
    );
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('-', ' ');
  }

  void _bookPlannedTour(
    BuildContext context, {
    required List<Exhibit> exhibits,
  }) {
    final route = exhibits.isEmpty ? _generatedRoute : exhibits;
    final ticketProvider = context.read<TicketProvider>();
    final authProvider = context.read<AuthProvider>();
    final exhibitIds = route.map((exhibit) => exhibit.id).toList();
    final languageCode =
        ticketProvider.currentOrderDraft.personalizedTourConfig?.languageCode ??
        ticketProvider.currentOrderDraft.standardTourConfig?.languageCode ??
        (Localizations.localeOf(context).languageCode == 'ar'
            ? 'arabic'
            : 'english');
    ticketProvider.resetOrderDraft();
    ticketProvider.setVisitorCategoryQuantity('egyptian-adult', 1);
    ticketProvider.selectRobotTourType(_tourType);
    if (_tourType == RobotTourType.personalized) {
      ticketProvider.updatePersonalizedTourConfig(
        PersonalizedTourConfig.defaultConfig.copyWith(
          selectedExhibitIds: exhibitIds,
          selectedThemes: _selectedInterests.toList(),
          durationMinutes: _durationMinutes,
          languageCode: languageCode,
          accessibilityNeeds: _accessibilityPreferences.toList(),
          photoSpotsEnabled: _includePhotoStops,
        ),
      );
    } else {
      ticketProvider.updateStandardTourConfig(
        StandardTourConfig.defaultConfig.copyWith(
          durationMinutes: _durationMinutes,
          languageCode: languageCode,
          routeName: 'Planned Horus-Bot Route',
          routeExhibitIds: exhibitIds.isEmpty
              ? StandardTourConfig.defaultConfig.routeExhibitIds
              : exhibitIds,
        ),
      );
    }
    _persistDraft();
    if (!authProvider.isLoggedIn) {
      Navigator.pushNamed(
        context,
        AppRoutes.login,
        arguments: {'redirect': AppRoutes.buyTickets},
      );
      return;
    }
    Navigator.pushNamed(context, AppRoutes.buyTickets);
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _tourType = data['tourType'] == RobotTourType.standard.name
            ? RobotTourType.standard
            : RobotTourType.personalized;
        _durationMinutes = data['durationMinutes'] is int
            ? data['durationMinutes'] as int
            : 45;
        _includePhotoStops = data['includePhotoStops'] as bool? ?? true;
        _selectedInterests
          ..clear()
          ..addAll(_stringList(data['interests']));
        _selectedExhibitIds
          ..clear()
          ..addAll(_stringList(data['exhibitIds']));
        _accessibilityPreferences
          ..clear()
          ..addAll(_supportedAccessibilityValues(data['accessibility']));
      });
    } catch (_) {
      return;
    }
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'tourType': _tourType.name,
        'durationMinutes': _durationMinutes,
        'includePhotoStops': _includePhotoStops,
        'interests': _selectedInterests.toList(),
        'exhibitIds': _selectedExhibitIds.toList(),
        'accessibility': _accessibilityPreferences.toList(),
      }),
    );
  }

  List<String> _supportedAccessibilityValues(Object? value) {
    final allowed = _accessibilityOptions.toSet();
    return _stringList(value).where(allowed.contains).toList();
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class _DurationOption {
  const _DurationOption(this.label, this.minutes, this.targetStops);

  final String label;
  final int minutes;
  final int targetStops;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.goldBorder(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/colossal-statue-of-ramesses-ii.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.heroImageOverlay,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.premiumGold,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.darkInk,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Your Personalized Tour',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.premiumHero(context).copyWith(
                          fontSize: 25,
                          height: 1.08,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.82),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the themes, artifacts, and pace you want Horus to guide you through.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.premiumBody(context).copyWith(
                          color: AppColors.whiteTitle.withValues(alpha: 0.84),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
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
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ],
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
        constraints: const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(12),
        decoration: selected
            ? AppDecorations.premiumGlassCard(
                radius: 18,
                highlighted: true,
                opacity: 0.64,
              )
            : AppDecorations.secondaryGlassCard(
                radius: 18,
                opacity: 0.54,
              ).copyWith(
                border: Border.all(
                  color: emphasized
                      ? AppColors.goldBorder(0.28)
                      : AppColors.goldBorder(0.14),
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppGradients.premiumGold : null,
                color: selected ? null : Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.goldBorder(0.16)),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.darkInk : AppColors.primaryGold,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.premiumCardTitle(
                context,
              ).copyWith(color: AppColors.whiteTitle, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _DurationOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 142,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: selected
            ? AppDecorations.premiumGlassCard(
                radius: 18,
                highlighted: true,
                opacity: 0.62,
              ).copyWith(border: Border.all(color: AppColors.primaryGold))
            : AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.52),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.premiumCardTitle(context).copyWith(
                color: selected ? AppColors.softGold : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${option.minutes} min - ${option.targetStops} stops',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _PlannerChip extends StatelessWidget {
  const _PlannerChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryGold,
      checkmarkColor: AppColors.darkInk,
      backgroundColor: AppColors.cinematicCard,
      labelStyle: AppTextStyles.metadata(context).copyWith(
        color: selected ? AppColors.darkInk : Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.primaryGold : AppColors.goldBorder(0.16),
        ),
      ),
    );
  }
}

class _PhotoExperienceCard extends StatelessWidget {
  const _PhotoExperienceCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.premiumGold,
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              color: AppColors.darkInk,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo Experience',
                  style: AppTextStyles.premiumCardTitle(
                    context,
                  ).copyWith(color: AppColors.whiteTitle, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Include recommended photo stops for tour memories.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeThumbColor: AppColors.primaryGold,
            onChanged: onChanged,
          ),
        ],
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
        padding: const EdgeInsets.all(9),
        decoration: selected
            ? AppDecorations.premiumGlassCard(
                radius: 18,
                highlighted: true,
                opacity: 0.60,
              )
            : AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.50),
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
                    style: AppTextStyles.premiumCardTitle(context).copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _periodLine(exhibit),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(color: AppColors.neutralMedium),
                  ),
                  if (exhibit.descriptionEn.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      exhibit.getDescription(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium),
                    ),
                  ],
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.exhibit,
    required this.isArabic,
    required this.reason,
    required this.onAdd,
  });

  final Exhibit exhibit;
  final bool isArabic;
  final String reason;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.54),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exhibit.getName(isArabic ? 'ar' : 'en'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.premiumCardTitle(
                    context,
                  ).copyWith(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryGold),
            tooltip: 'Add exhibit',
          ),
        ],
      ),
    );
  }
}

String _periodLine(Exhibit exhibit) {
  final parts = <String>[
    if (exhibit.category.trim().isNotEmpty) exhibit.category.trim(),
    if (exhibit.floor.trim().isNotEmpty) exhibit.floor.trim(),
  ];
  if (parts.isEmpty) return 'Museum highlight';
  return parts.join(' - ');
}

class _SelectionCounter extends StatelessWidget {
  const _SelectionCounter({required this.selected, required this.max});

  final int selected;
  final int max;

  @override
  Widget build(BuildContext context) {
    final remaining = (max - selected).clamp(0, max);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.54),
      child: Row(
        children: [
          const Icon(Icons.route_rounded, color: AppColors.primaryGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Selected: $selected / $max stops',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.premiumCardTitle(
                context,
              ).copyWith(color: AppColors.whiteTitle, fontSize: 15),
            ),
          ),
          Text(
            '$remaining stops remaining',
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

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.metadata(context).copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.unfold_more_rounded,
              size: 16,
              color: AppColors.primaryGold,
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

class _GeneratedRouteCard extends StatelessWidget {
  const _GeneratedRouteCard({
    required this.route,
    required this.duration,
    required this.tourType,
    required this.matchScore,
    required this.reasons,
    required this.includePhotoStops,
    required this.isArabic,
  });

  final List<Exhibit> route;
  final int duration;
  final RobotTourType tourType;
  final int matchScore;
  final List<String> reasons;
  final bool includePhotoStops;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final stops = <String>[
      'Entrance',
      ...route.map((exhibit) => exhibit.getName(isArabic ? 'ar' : 'en')),
      'Exit',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: AppDecorations.premiumGlassCard(
        radius: 24,
        highlighted: true,
        opacity: 0.64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Horus Route',
                  style: AppTextStyles.premiumSectionLabel(
                    context,
                  ).copyWith(color: AppColors.softGold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  gradient: AppGradients.premiumGold,
                ),
                child: Text(
                  '$matchScore% Match',
                  style: AppTextStyles.metadata(context).copyWith(
                    color: AppColors.darkInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...stops.asMap().entries.map((entry) {
            final isLast = entry.key == stops.length - 1;
            return _RouteStop(label: entry.value, isLast: isLast);
          }),
          const SizedBox(height: 14),
          Text(
            'Why Horus selected this route',
            style: AppTextStyles.premiumCardTitle(
              context,
            ).copyWith(color: AppColors.whiteTitle, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.primaryGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(color: AppColors.neutralMedium),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${tourType.name} - $duration minutes - ${route.length} stops'
            '${includePhotoStops ? ' - photo stops enabled' : ''}',
            maxLines: 2,
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

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.label, required this.isLast});

  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: AppColors.primaryGold.withValues(alpha: 0.42),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: AppColors.whiteTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.isArabic,
    required this.tourType,
    required this.interests,
    required this.exhibits,
    required this.duration,
    required this.accessibility,
    required this.photoStopsEnabled,
    required this.price,
    required this.generated,
    required this.languageLabel,
    required this.matchScore,
  });

  final bool isArabic;
  final RobotTourType tourType;
  final int interests;
  final int exhibits;
  final int duration;
  final List<String> accessibility;
  final bool photoStopsEnabled;
  final int price;
  final bool generated;
  final String languageLabel;
  final int matchScore;

  @override
  Widget build(BuildContext context) {
    final typeLabel = tourType == RobotTourType.personalized
        ? 'Personalized Tour'
        : 'Standard Tour';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
      decoration: AppDecorations.premiumGlassCard(
        radius: 24,
        highlighted: true,
        opacity: 0.62,
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Summary',
            style: AppTextStyles.premiumSectionLabel(
              context,
            ).copyWith(color: AppColors.softGold),
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: 'Tour type', value: typeLabel),
          _SummaryLine(label: 'Tour match', value: '$matchScore% Match'),
          _SummaryLine(label: 'Duration', value: '$duration minutes'),
          _SummaryLine(label: 'Selected exhibits', value: '$exhibits'),
          _SummaryLine(label: 'Selected interests', value: '$interests'),
          _SummaryLine(
            label: 'Accessibility',
            value: accessibility.isEmpty
                ? 'None selected'
                : accessibility.join(', '),
          ),
          _SummaryLine(
            label: 'Photo stops',
            value: photoStopsEnabled ? 'Enabled' : 'Disabled',
          ),
          _SummaryLine(label: 'Language', value: languageLabel),
          _SummaryLine(label: 'Robot tour', value: '$price EGP'),
          const _SummaryLine(label: 'Museum entry', value: 'Included'),
          if (generated) ...[
            const SizedBox(height: 10),
            Text(
              'Booking this plan will reserve museum entry and a personalized Horus-Bot robot tour.',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlannerNotice extends StatelessWidget {
  const _PlannerNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.secondaryGlassCard(radius: 18, opacity: 0.58)
          .copyWith(
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.5),
            ),
          ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyPrimary(
          context,
        ).copyWith(color: AppColors.softGold),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyPrimary(
        context,
      ).copyWith(color: AppColors.neutralMedium),
    );
  }
}
