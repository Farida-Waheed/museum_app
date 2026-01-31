import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../app/router.dart';
import '../core/constants/sizes.dart';
import '../core/constants/strings.dart';
import '../core/constants/text_styles.dart';
import '../models/user_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    String t({required String en, required String ar}) => isArabic ? ar : en;

    Widget item({
      required IconData icon,
      required String title,
      required String route,
    }) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title, style: AppTextStyles.body(context)),
        onTap: () {
          Navigator.pop(context); // close drawer
          Navigator.pushReplacementNamed(context, route);
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    child: Text('G', style: AppTextStyles.title(context)),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(en: 'Guest User', ar: 'زائر'),
                          style: AppTextStyles.title(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t(en: 'Explore the museum', ar: 'استكشف المتحف'),
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/profile');
                    },
                    child: Text(t(en: 'Profile', ar: 'الملف الشخصي')),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Main missing sections
                  item(
                    icon: Icons.person_outline,
                    title: AppStrings.profile,
                    route: '/profile',
                  ),
                  item(
                    icon: Icons.route_outlined,
                    title: AppStrings.tourPlanner,
                    route: '/tour-planner',
                  ),
                  item(
                    icon: Icons.event_outlined,
                    title: AppStrings.events,
                    route: '/events',
                  ),
                  item(
                    icon: Icons.emoji_events_outlined,
                    title: AppStrings.achievements,
                    route: '/achievements',
                  ),

                  const Divider(),

                  // Existing screens shortcuts
                  item(
                    icon: Icons.language,
                    title: AppStrings.language,
                    route: '/language',
                  ),
                  item(
                    icon: Icons.accessibility_new,
                    title: AppStrings.accessibility,
                    route: '/accessibility',
                  ),
                  item(
                    icon: Icons.feedback_outlined,
                    title: AppStrings.feedback,
                    route: '/feedback',
                  ),
                  item(
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    route: '/settings',
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
