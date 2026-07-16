import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../enums/accessibility_enums.dart';
import '../l10n/accessibility_category_presentation.dart';
import '../l10n/accessibility_l10n.dart';
import '../models/accessibility_profile.dart';
import '../state/accessibility_controller.dart';
import '../widgets/accessibility_need_card.dart';
import '../widgets/accessibility_toggle_tile.dart';

/// The Accessibility Setup Wizard — a premium multi-step onboarding experience
/// that welcomes the visitor and personalizes Horus in under a minute.
///
/// Design decisions:
/// * Holds a local DRAFT (`_draft`) so nothing persists until Finish; the app is
///   not re-themed mid-wizard on every tap (except the live Preview step, which
///   opts in). This keeps the flow calm and cancellable.
/// * Multi-select needs (Visual + Wheelchair, etc.) via a Set; selecting needs
///   rebuilds the draft from `AccessibilityProfile.forCategories`, preserving the
///   visitor's later manual tweaks is intentionally NOT done here — choosing
///   needs is the reset point, and Step 4 is where fine-tuning happens.
/// * Reduced-motion aware: page transitions honor the CURRENT saved profile so a
///   returning visitor who already reduced motion sees calm transitions.
/// * Fully accessible: Semantics on every control, ≥48dp targets, RTL via the
///   app's global Directionality, and a visible progress indicator.
class AccessibilitySetupScreen extends StatefulWidget {
  /// Where to go when the wizard completes or is skipped. When null, the wizard
  /// simply pops (used when opened from the profile page to re-run setup).
  final String? nextRoute;

  const AccessibilitySetupScreen({super.key, this.nextRoute});

  @override
  State<AccessibilitySetupScreen> createState() =>
      _AccessibilitySetupScreenState();
}

class _AccessibilitySetupScreenState extends State<AccessibilitySetupScreen> {
  static const int _stepCount = 6;

  final PageController _pageController = PageController();
  int _step = 0;
  bool _saving = false;

  late Set<AccessibilityCategory> _selected;
  late AccessibilityProfile _draft;

  @override
  void initState() {
    super.initState();
    // Seed the draft from the existing profile so re-running setup preserves
    // prior choices.
    final current = context.read<AccessibilityController>().profile;
    _selected = {...current.categories};
    _draft = current;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Duration get _transitionDuration =>
      // Honor the already-saved motion preference during the wizard itself.
      context.read<AccessibilityController>().reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 320);

  void _goTo(int step) {
    final clamped = step.clamp(0, _stepCount - 1);
    setState(() => _step = clamped);
    final dur = _transitionDuration;
    if (dur == Duration.zero) {
      _pageController.jumpToPage(clamped);
    } else {
      _pageController.animateToPage(
        clamped,
        duration: dur,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _rebuildDraftFromSelection() {
    setState(() {
      _draft = AccessibilityProfile.forCategories(_selected);
    });
  }

  void _toggleCategory(AccessibilityCategory c) {
    setState(() {
      if (c == AccessibilityCategory.standard) {
        // "Standard" is exclusive: choosing it clears all real needs.
        _selected = {};
      } else {
        if (_selected.contains(c)) {
          _selected.remove(c);
        } else {
          _selected.add(c);
        }
      }
    });
    _rebuildDraftFromSelection();
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final controller = context.read<AccessibilityController>();
    final navigator = Navigator.of(context);
    final route = widget.nextRoute;

    await controller.updateProfile(
      _draft.copyWith(hasCompletedSetup: true),
    );

    if (!mounted) return;
    if (route != null) {
      navigator.pushReplacementNamed(route);
    } else {
      navigator.pop();
    }
  }

  Future<void> _skip() async {
    if (_saving) return;
    setState(() => _saving = true);
    final controller = context.read<AccessibilityController>();
    final navigator = Navigator.of(context);
    final route = widget.nextRoute;

    // Skipping = standard experience, but mark setup complete so we don't nag.
    await controller.updateProfile(
      AccessibilityProfile.initial.copyWith(hasCompletedSetup: true),
    );

    if (!mounted) return;
    if (route != null) {
      navigator.pushReplacementNamed(route);
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AccessibilityL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.resolvedBackground,
      body: DecoratedBox(
        decoration: AppDecorations.cinematicBackground(),
        child: SafeArea(
          child: Column(
            children: [
              _WizardHeader(
                step: _step,
                stepCount: _stepCount,
                onSkip: _saving ? null : _skip,
                skipLabel: t.skip,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(t: t),
                    _NeedsStep(
                      t: t,
                      selected: _selected,
                      onToggle: _toggleCategory,
                    ),
                    _NeedsStep(
                      t: t,
                      selected: _selected,
                      onToggle: _toggleCategory,
                      // Step 3 mirrors step 2 in this compact flow; kept distinct
                      // so the progress model reads naturally and future copy can
                      // diverge without restructuring.
                    ),
                    _PreferencesStep(
                      t: t,
                      draft: _draft,
                      onChanged: (p) => setState(() => _draft = p),
                    ),
                    _PreviewStep(t: t, draft: _draft),
                    _FinishStep(t: t),
                  ],
                ),
              ),
              _WizardFooter(
                t: t,
                step: _step,
                stepCount: _stepCount,
                saving: _saving,
                onBack: _step == 0 ? null : () => _goTo(_step - 1),
                onNext: _step == _stepCount - 1 ? _finish : () => _goTo(_step + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: brand + progress
// ---------------------------------------------------------------------------
class _WizardHeader extends StatelessWidget {
  final int step;
  final int stepCount;
  final VoidCallback? onSkip;
  final String skipLabel;

  const _WizardHeader({
    required this.step,
    required this.stepCount,
    required this.onSkip,
    required this.skipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('assets/icons/horus_eye.png', width: 22, height: 22),
              const SizedBox(width: 10),
              Text(
                'HORUS-BOT',
                style: AppTextStyles.premiumBrandTitle(context)
                    .copyWith(fontSize: 16, letterSpacing: 1.1),
              ),
              const Spacer(),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    skipLabel,
                    style: AppTextStyles.metadata(context)
                        .copyWith(color: AppColors.primaryGold, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Step ${step + 1} of $stepCount',
            child: Row(
              children: List.generate(stepCount, (i) {
                final active = i <= step;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == stepCount - 1 ? 0 : 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      height: 5,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primaryGold
                            : AppColors.resolvedMutedText.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer: back / next-finish
// ---------------------------------------------------------------------------
class _WizardFooter extends StatelessWidget {
  final AccessibilityL10n t;
  final int step;
  final int stepCount;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const _WizardFooter({
    required this.t,
    required this.step,
    required this.stepCount,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == stepCount - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          if (onBack != null)
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : onBack,
                style: AppDecorations.secondaryButton(),
                child: Text(t.back),
              ),
            ),
          if (onBack != null) const SizedBox(width: 14),
          Expanded(
            flex: onBack == null ? 1 : 2,
            child: ElevatedButton(
              onPressed: saving ? null : onNext,
              style: AppDecorations.primaryButton(),
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.darkInk,
                      ),
                    )
                  : Text(isLast ? t.openHome : t.next),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Steps
// ---------------------------------------------------------------------------
class _StepScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _StepScaffold({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.premiumScreenTitle(context)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: AppTextStyles.premiumMutedBody(context)
                  .copyWith(color: AppColors.resolvedBodyText),
            ),
          ],
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final AccessibilityL10n t;
  const _WelcomeStep({required this.t});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t.welcomeTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.goldBorder(0.4)),
              ),
              child: const Icon(Icons.accessibility_new_rounded,
                  size: 46, color: AppColors.primaryGold),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            t.welcomeBody,
            style: AppTextStyles.premiumBody(context)
                .copyWith(color: AppColors.resolvedTitleText, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            t.welcomeReassurance,
            style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _NeedsStep extends StatelessWidget {
  final AccessibilityL10n t;
  final Set<AccessibilityCategory> selected;
  final ValueChanged<AccessibilityCategory> onToggle;

  const _NeedsStep({
    required this.t,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t.needsTitle,
      subtitle: t.needsSubtitle,
      child: Column(
        children: [
          for (final c in AccessibilityCategoryPresentation.selectable) ...[
            AccessibilityNeedCard(
              presentation:
                  AccessibilityCategoryPresentation.resolve(c, t),
              selected: c == AccessibilityCategory.standard
                  ? selected.isEmpty
                  : selected.contains(c),
              onTap: () => onToggle(c),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PreferencesStep extends StatelessWidget {
  final AccessibilityL10n t;
  final AccessibilityProfile draft;
  final ValueChanged<AccessibilityProfile> onChanged;

  const _PreferencesStep({
    required this.t,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t.preferencesTitle,
      subtitle: t.preferencesSubtitle,
      child: Column(
        children: [
          // Display
          _PrefGroup(
            title: t.sectionDisplay,
            children: [
              AccessibilityToggleTile(
                title: t.highContrast,
                value: draft.display.highContrast,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    display: draft.display.copyWith(highContrast: v),
                  ),
                ),
              ),
              AccessibilityToggleTile(
                title: t.largeButtons,
                value: draft.display.largeTapTargets,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    display: draft.display.copyWith(largeTapTargets: v),
                  ),
                ),
              ),
              AccessibilityToggleTile(
                title: t.reduceMotion,
                value: draft.display.reduceMotion,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    display: draft.display.copyWith(reduceMotion: v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Voice
          _PrefGroup(
            title: t.sectionVoice,
            children: [
              AccessibilityToggleTile(
                title: t.voiceGuidance,
                value: draft.voice.voiceGuidanceEnabled,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    voice: draft.voice.copyWith(voiceGuidanceEnabled: v),
                  ),
                ),
              ),
              AccessibilityToggleTile(
                title: t.audioDescription,
                value: draft.voice.audioDescriptionEnabled,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    voice: draft.voice.copyWith(audioDescriptionEnabled: v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Interaction
          _PrefGroup(
            title: t.sectionInteraction,
            children: [
              AccessibilityToggleTile(
                title: t.liveCaptions,
                value: draft.interaction.captionsEnabled,
                onChanged: (v) => onChanged(
                  draft.copyWith(
                    interaction:
                        draft.interaction.copyWith(captionsEnabled: v),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrefGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _PrefGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: AppDecorations.secondaryGlassCard(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(context)
                  .copyWith(fontSize: 11, letterSpacing: 1.2),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PreviewStep extends StatelessWidget {
  final AccessibilityL10n t;
  final AccessibilityProfile draft;
  const _PreviewStep({required this.t, required this.draft});

  @override
  Widget build(BuildContext context) {
    // Live preview: render the sample using the DRAFT's text scale + weight so
    // the visitor sees the effect before committing.
    final scale = draft.display.textScale;
    final weight =
        draft.display.boldText ? FontWeight.bold : FontWeight.normal;

    return _StepScaffold(
      title: t.previewTitle,
      subtitle: t.previewSubtitle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: draft.display.highContrast
            ? BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGold, width: 1.4),
              )
            : AppDecorations.premiumGlassCard(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.previewSampleHeading,
              style: TextStyle(
                color: draft.display.highContrast
                    ? Colors.white
                    : AppColors.resolvedTitleText,
                fontWeight: FontWeight.bold,
                fontSize: 14 * scale,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.previewSampleBody,
              style: TextStyle(
                color: draft.display.highContrast
                    ? Colors.white
                    : AppColors.resolvedBodyText,
                fontWeight: weight,
                fontSize: 15 * scale,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PreviewChip(
                  icon: Icons.speed_rounded,
                  label: '${t.pace}: ${t.paceLabel(draft.tour.pace)}',
                ),
                _PreviewChip(
                  icon: Icons.record_voice_over_rounded,
                  label:
                      '${t.explanationDetail}: ${t.explanationLabel(draft.tour.explanationLevel)}',
                ),
                if (draft.interaction.captionsEnabled)
                  _PreviewChip(
                    icon: Icons.closed_caption_rounded,
                    label: t.liveCaptions,
                  ),
                if (draft.navigation.routePreference.requiresStepFree)
                  _PreviewChip(
                    icon: Icons.accessible_rounded,
                    label: t.stepFreeRoutes,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PreviewChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.goldBorder(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.metadata(context)
                .copyWith(fontSize: 12, color: AppColors.resolvedTitleText),
          ),
        ],
      ),
    );
  }
}

class _FinishStep extends StatelessWidget {
  final AccessibilityL10n t;
  const _FinishStep({required this.t});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t.finishTitle,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withValues(alpha: 0.14),
                border: Border.all(color: AppColors.goldBorder(0.45)),
              ),
              child: const Icon(Icons.check_rounded,
                  size: 52, color: AppColors.primaryGold),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            t.finishBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.premiumBody(context)
                .copyWith(color: AppColors.resolvedTitleText, height: 1.5),
          ),
        ],
      ),
    );
  }
}
