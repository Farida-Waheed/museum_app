import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/auth_provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/guest_prompt.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final Set<int> _selectedTagIndexes = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleTag(int index) {
    setState(() {
      if (_selectedTagIndexes.contains(index)) {
        _selectedTagIndexes.remove(index);
      } else {
        _selectedTagIndexes.add(index);
      }
    });
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.feedbackSignInRequired),
          action: SnackBarAction(
            label: l10n.login,
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.login,
                arguments: {'redirect': AppRoutes.feedback},
              );
            },
          ),
        ),
      );
      return;
    }

    if (_rating == 0 && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseAddRatingOrComment)));
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _rating = 0;
      _commentController.clear();
      _selectedTagIndexes.clear();
    });

    _showThankYouDialog();
  }

  void _showThankYouDialog() {
    final l10n = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.feedbackSubmitted,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return const Center(child: _FeedbackThankYouDialog());
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final authProvider = context.watch<AuthProvider>();
    final isArabic = prefs.language == 'ar';
    final l10n = AppLocalizations.of(context)!;
    final tags = [
      l10n.feedbackTagRobotGuide,
      l10n.feedbackTagExhibits,
      l10n.feedbackTagNavigation,
      l10n.feedbackTagTickets,
      l10n.feedbackTagFacilities,
    ];

    if (!authProvider.isLoggedIn) {
      return AppMenuShell(
        title: l10n.feedback.toUpperCase(),
        backgroundColor: AppColors.resolvedBackground,
        bottomNavigationBar: const BottomNav(currentIndex: 4),
        body: DecoratedBox(
          decoration: BoxDecoration(color: AppColors.resolvedBackground),
          child: GuestPrompt(
            icon: Icons.rate_review_outlined,
            title: l10n.feedbackShareExperience,
            body: l10n.feedbackGuestBody,
          ),
        ),
      );
    }

    return AppMenuShell(
      title: l10n.feedback.toUpperCase(),
      backgroundColor: AppColors.resolvedBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      floatingActionButton: null,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 92, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderCard(
                      title: l10n.howWasYourVisit,
                      subtitle: l10n.rateYourExperience,
                    ),
                    const SizedBox(height: 32),
                    _RatingCard(
                      title: l10n.overallRating.toUpperCase(),
                      rating: _rating,
                      label: _ratingLabel(_rating),
                      onRatingChanged: (rating) {
                        setState(() => _rating = rating);
                      },
                      tagTitle: l10n.feedbackAboutOptional,
                      tags: tags,
                      selectedTagIndexes: _selectedTagIndexes,
                      onToggleTag: _toggleTag,
                    ),
                    const SizedBox(height: 32),
                    _CommentCard(controller: _commentController),
                    const SizedBox(height: 24),
                    Text(
                      l10n.feedbackUsedNote,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
            _SubmitBar(isSubmitting: _isSubmitting, onSubmit: _handleSubmit),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    final l10n = AppLocalizations.of(context)!;
    switch (rating) {
      case 5:
        return l10n.excellentThankYou;
      case 4:
        return l10n.greatExperience;
      case 3:
        return l10n.overallGood;
      case 2:
        return l10n.needsImprovement;
      case 1:
        return l10n.notGoodExperience;
      default:
        return '';
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.feedback_outlined,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.metadata(context).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.title,
    required this.rating,
    required this.label,
    required this.onRatingChanged,
    required this.tagTitle,
    required this.tags,
    required this.selectedTagIndexes,
    required this.onToggleTag,
  });

  final String title;
  final int rating;
  final String label;
  final ValueChanged<int> onRatingChanged;
  final String tagTitle;
  final List<String> tags;
  final Set<int> selectedTagIndexes;
  final ValueChanged<int> onToggleTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.displaySectionTitle(context)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              final isFilled = star <= rating;
              return IconButton(
                onPressed: () => onRatingChanged(star),
                icon: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isFilled
                      ? AppColors.primaryGold
                      : AppColors.resolvedMutedText,
                  size: 40,
                ),
              );
            }),
          ),
          if (rating > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  label,
                  style: AppTextStyles.metadata(context).copyWith(
                    color: AppColors.primaryGold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            tagTitle,
            style: AppTextStyles.bodyPrimary(context).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(tags.length, (index) {
              final selected = selectedTagIndexes.contains(index);
              return GestureDetector(
                onTap: () => onToggleTag(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryGold.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryGold
                          : AppColors.goldBorder(0.16),
                    ),
                  ),
                  child: Text(
                    tags[index],
                    style: AppTextStyles.metadata(context).copyWith(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected
                          ? AppColors.primaryGold
                          : AppColors.resolvedMutedText,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.premiumGlassCard(radius: 24, opacity: 0.58),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tellUsMoreOptional.toUpperCase(),
            style: AppTextStyles.displaySectionTitle(context),
          ),
          const SizedBox(height: 8),
          Text(l10n.feedbackPrompt, style: AppTextStyles.metadata(context)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLines: 4,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.resolvedTitleText),
            decoration: InputDecoration(
              hintText: l10n.writeFeedbackHere,
              hintStyle: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.resolvedMutedText),
              filled: true,
              fillColor: AppColors.cardGlass(0.30),
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.goldBorder(0.16)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryGold,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.isSubmitting, required this.onSubmit});

  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.useLightSurfaces
            ? AppColors.websiteLightBackground.withValues(alpha: 0.96)
            : AppColors.cinematicNav,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkInk.withValues(
              alpha: AppColors.useLightSurfaces ? 0.10 : 0.34,
            ),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.premiumGlassCard(
            radius: 24,
            opacity: 0.62,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: AppDecorations.primaryButton(),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.darkInk,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      l10n.submitFeedback,
                      style: AppTextStyles.buttonLabel(context),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackThankYouDialog extends StatelessWidget {
  const _FeedbackThankYouDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardGlass(0.66),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.goldBorder(0.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.feedbackSubmittedTitle,
              style: AppTextStyles.displayScreenTitle(
                context,
              ).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.feedbackSubmittedBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(context).copyWith(
                color: AppColors.resolvedMutedText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                style: AppDecorations.primaryButton(),
                child: Text(
                  l10n.close,
                  style: AppTextStyles.buttonLabel(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
