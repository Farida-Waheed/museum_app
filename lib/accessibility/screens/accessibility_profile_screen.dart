import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../constants/accessibility_constants.dart';
import '../enums/accessibility_enums.dart';
import '../l10n/accessibility_category_presentation.dart';
import '../l10n/accessibility_l10n.dart';
import '../models/accessibility_profile.dart';
import '../state/accessibility_controller.dart';
import '../widgets/accessibility_card.dart';
import '../widgets/accessibility_toggle_tile.dart';
import 'dart:convert';

/// Accessibility Profile management page (route: /accessibility_profile).
///
/// View, edit, reset, and export the profile. Every control writes straight to
/// [AccessibilityController], which persists (local + cloud) and re-themes the
/// whole app live — no restart. Reuses the module's branded widgets so it is
/// visually native to Horus-Bot.
class AccessibilityProfileScreen extends StatelessWidget {
  const AccessibilityProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AccessibilityL10n.of(context);
    final controller = context.watch<AccessibilityController>();
    final profile = controller.profile;

    return Scaffold(
      backgroundColor: AppColors.resolvedBackground,
      appBar: AppBar(
        title: Text(t.profileTitle),
        backgroundColor: AppColors.darkHeader,
        foregroundColor: Colors.white,
      ),
      body: DecoratedBox(
        decoration: AppDecorations.cinematicBackground(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _SyncBadge(controller: controller, t: t),
              const SizedBox(height: 16),
              _ActiveNeedsCard(profile: profile, t: t),
              const SizedBox(height: 20),
              _DisplaySection(controller: controller, t: t),
              const SizedBox(height: 16),
              _VoiceSection(controller: controller, t: t),
              const SizedBox(height: 16),
              _NavigationSection(controller: controller, t: t),
              const SizedBox(height: 16),
              _InteractionSection(controller: controller, t: t),
              const SizedBox(height: 24),
              _ActionsRow(controller: controller, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _SyncBadge({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = controller.isSyncing
        ? (Icons.sync_rounded, t.saving)
        : controller.isCloudStale
            ? (Icons.cloud_off_rounded, t.willSyncWhenOnline)
            : (Icons.cloud_done_rounded, t.savedOnDevice);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGold),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.metadata(context).copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _ActiveNeedsCard extends StatelessWidget {
  final AccessibilityProfile profile;
  final AccessibilityL10n t;
  const _ActiveNeedsCard({required this.profile, required this.t});

  @override
  Widget build(BuildContext context) {
    final cats = profile.categories;
    return AccessibilityCard(
      leadingIcon: Icons.accessibility_new_rounded,
      title: t.activeNeeds,
      child: cats.isEmpty
          ? Text(
              t.noActiveNeeds,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in cats)
                  _NeedChip(
                    presentation:
                        AccessibilityCategoryPresentation.resolve(c, t),
                  ),
              ],
            ),
    );
  }
}

class _NeedChip extends StatelessWidget {
  final AccessibilityCategoryPresentation presentation;
  const _NeedChip({required this.presentation});

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
          Icon(presentation.icon, size: 15, color: AppColors.primaryGold),
          const SizedBox(width: 6),
          Text(
            presentation.label,
            style: AppTextStyles.metadata(context)
                .copyWith(fontSize: 12, color: AppColors.resolvedTitleText),
          ),
        ],
      ),
    );
  }
}

class _DisplaySection extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _DisplaySection({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    final d = controller.display;
    return AccessibilityCard(
      title: t.sectionDisplay,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.textSize,
                    style: AppTextStyles.bodyPrimary(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text('${(d.textScale * 100).round()}%',
                    style: AppTextStyles.metadata(context)),
              ],
            ),
          ),
          Slider(
            value: d.textScale,
            min: AccessibilityConstants.minTextScale,
            max: AccessibilityConstants.maxTextScale,
            divisions: 6,
            activeColor: AppColors.primaryGold,
            label: '${(d.textScale * 100).round()}%',
            onChanged: (v) =>
                controller.updateDisplay(d.copyWith(textScale: v)),
          ),
          AccessibilityToggleTile(
            title: t.highContrast,
            value: d.highContrast,
            onChanged: (v) =>
                controller.updateDisplay(d.copyWith(highContrast: v)),
          ),
          AccessibilityToggleTile(
            title: t.boldText,
            value: d.boldText,
            onChanged: (v) => controller.updateDisplay(d.copyWith(boldText: v)),
          ),
          AccessibilityToggleTile(
            title: t.reduceMotion,
            value: d.reduceMotion,
            onChanged: (v) =>
                controller.updateDisplay(d.copyWith(reduceMotion: v)),
          ),
          AccessibilityToggleTile(
            title: t.largeButtons,
            value: d.largeTapTargets,
            onChanged: (v) =>
                controller.updateDisplay(d.copyWith(largeTapTargets: v)),
          ),
        ],
      ),
    );
  }
}

class _VoiceSection extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _VoiceSection({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    final v = controller.voice;
    return AccessibilityCard(
      title: t.sectionVoice,
      child: Column(
        children: [
          AccessibilityToggleTile(
            title: t.voiceGuidance,
            value: v.voiceGuidanceEnabled,
            onChanged: (x) =>
                controller.updateVoice(v.copyWith(voiceGuidanceEnabled: x)),
          ),
          AccessibilityToggleTile(
            title: t.audioDescription,
            value: v.audioDescriptionEnabled,
            onChanged: (x) =>
                controller.updateVoice(v.copyWith(audioDescriptionEnabled: x)),
          ),
          const SizedBox(height: 8),
          _SegmentedRow<SpeechRate>(
            label: t.speechSpeed,
            values: SpeechRate.values,
            selected: v.speechRate,
            labelOf: t.speechRateLabel,
            onSelected: (x) =>
                controller.updateVoice(v.copyWith(speechRate: x)),
          ),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _NavigationSection({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    final n = controller.navigation;
    return AccessibilityCard(
      title: t.sectionNavigation,
      child: Column(
        children: [
          AccessibilityToggleTile(
            title: t.stepFreeRoutes,
            value: n.routePreference.requiresStepFree,
            onChanged: (x) => controller.updateNavigation(
              n.copyWith(
                routePreference:
                    x ? RoutePreference.stepFree : RoutePreference.standard,
              ),
            ),
          ),
          AccessibilityToggleTile(
            title: t.moreRestPoints,
            value: n.moreRestPoints,
            onChanged: (x) =>
                controller.updateNavigation(n.copyWith(moreRestPoints: x)),
          ),
          AccessibilityToggleTile(
            title: t.announceDirections,
            value: n.announceDirections,
            onChanged: (x) =>
                controller.updateNavigation(n.copyWith(announceDirections: x)),
          ),
        ],
      ),
    );
  }
}

class _InteractionSection extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _InteractionSection({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    final i = controller.interaction;
    return AccessibilityCard(
      title: t.sectionInteraction,
      child: Column(
        children: [
          AccessibilityToggleTile(
            title: t.liveCaptions,
            value: i.captionsEnabled,
            onChanged: (x) =>
                controller.updateInteraction(i.copyWith(captionsEnabled: x)),
          ),
          AccessibilityToggleTile(
            title: t.hapticFeedback,
            value: i.hapticFeedback,
            onChanged: (x) =>
                controller.updateInteraction(i.copyWith(hapticFeedback: x)),
          ),
          AccessibilityToggleTile(
            title: t.extendedTimeouts,
            value: i.extendedTimeouts,
            onChanged: (x) =>
                controller.updateInteraction(i.copyWith(extendedTimeouts: x)),
          ),
        ],
      ),
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  const _SegmentedRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyPrimary(context).copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final v in values)
              ChoiceChip(
                label: Text(labelOf(v)),
                selected: v == selected,
                onSelected: (_) => onSelected(v),
                selectedColor: AppColors.primaryGold.withValues(alpha: 0.85),
                backgroundColor: AppColors.cardGlass(0.4),
                labelStyle: TextStyle(
                  color: v == selected
                      ? AppColors.darkInk
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final AccessibilityController controller;
  final AccessibilityL10n t;
  const _ActionsRow({required this.controller, required this.t});

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.resolvedElevated,
        title: Text(t.resetConfirmTitle),
        content: Text(t.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.reset),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.updateProfile(
        AccessibilityProfile.initial.copyWith(hasCompletedSetup: true),
      );
    }
  }

  Future<void> _export(BuildContext context) async {
    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(controller.profile.toStorageMap());
    await Clipboard.setData(ClipboardData(text: json));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.exportProfile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => _export(context),
          style: AppDecorations.secondaryButton(),
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: Text(t.exportProfile),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _confirmReset(context),
          icon: const Icon(Icons.restart_alt_rounded,
              size: 18, color: AppColors.alertRed),
          label: Text(
            t.resetProfile,
            style: const TextStyle(color: AppColors.alertRed),
          ),
        ),
      ],
    );
  }
}
