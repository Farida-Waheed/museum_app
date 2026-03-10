import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AppMenuShell(
      title: l10n.profile,
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. User Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFFF3F6FB),
                        child: Icon(Icons.person_outline, size: 50, color: Colors.black26),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                        child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.guestUser, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(l10n.exploreTheMuseum, style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Options List
            _buildOptionGroup([
              _ProfileOption(icon: Icons.history_rounded, label: isArabic ? "تاريخ الزيارات" : "Visit History", onTap: () {}),
              _ProfileOption(icon: Icons.emoji_events_outlined, label: l10n.achievements, onTap: () {}),
              _ProfileOption(icon: Icons.bookmark_border_rounded, label: isArabic ? "المحفوظات" : "Bookmarks", onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _buildOptionGroup([
              _ProfileOption(icon: Icons.language_rounded, label: l10n.language, onTap: () {}),
              _ProfileOption(icon: Icons.accessibility_new_rounded, label: l10n.accessibility, onTap: () {}),
              _ProfileOption(icon: Icons.notifications_none_rounded, label: isArabic ? "الإشعارات" : "Notifications", onTap: () {}),
            ]),
            const SizedBox(height: 32),

            // 3. Logout
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isArabic ? "تسجيل الخروج" : "Sign Out", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            Icon(isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
