import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/sizes.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/progress_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, int>? _stats;
  String? _lastPlan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await ProgressStore.getStats();
    final lastPlan = await ProgressStore.getLastPlan();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _lastPlan = lastPlan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    String t(String en, String ar) => isArabic ? ar : en;

    final stats = _stats ?? {'tours': 0, 'quizzes': 0, 'exhibits': 0};

    return AppScaffold(
      title: t('Profile', 'الملف الشخصي'),
      body: ListView(
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text('G', style: AppTextStyles.title(context)),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Guest User', 'زائر'),
                        style: AppTextStyles.title(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('Demo mode (UI only)', 'وضع العرض (واجهة فقط)'),
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Your Progress', 'تقدمك'),
                  style: AppTextStyles.title(context),
                ),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    _statChip(context, t('Tours', 'جولات'), stats['tours']!),
                    _statChip(
                      context,
                      t('Quizzes', 'اختبارات'),
                      stats['quizzes']!,
                    ),
                    _statChip(
                      context,
                      t('Exhibits', 'معروضات'),
                      stats['exhibits']!,
                    ),
                  ],
                ),
                if ((_lastPlan ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    t('Last Plan', 'آخر خطة'),
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 4),
                  Text(_lastPlan!, style: AppTextStyles.body(context)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Quick Links', 'اختصارات'),
                  style: AppTextStyles.title(context),
                ),
                const SizedBox(height: AppSizes.sm),
                _linkTile(
                  context,
                  icon: Icons.emoji_events_outlined,
                  title: t('Achievements', 'الإنجازات'),
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.achievements,
                  ),
                ),
                _linkTile(
                  context,
                  icon: Icons.confirmation_num_outlined,
                  title: t('My Tickets', 'تذاكري'),
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.tickets,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),

          PrimaryButton(
            label: t('Reset Demo Progress', 'إعادة ضبط التقدم'),
            icon: Icons.restart_alt,
            onPressed: () async {
              await ProgressStore.resetAll();
              await _load();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t('Progress reset.', 'تمت إعادة الضبط.')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text('$label: $value', style: AppTextStyles.body(context)),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: AppTextStyles.body(context)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
