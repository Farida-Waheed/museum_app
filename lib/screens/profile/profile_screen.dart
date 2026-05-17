import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/app_session_provider.dart' as app_session;
import '../../models/auth_provider.dart';
import '../../models/ticket_provider.dart';
import '../../models/tour_photo.dart';
import '../../models/user_preferences.dart';
import '../../services/photo_repository.dart';
import '../../services/robot_mqtt_service.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _loadedUserId;
  bool _isLoggingOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (authProvider.isLoggedIn && userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TicketProvider>().loadUserTickets(userId);
      });
    }
  }

  Future<void> _confirmSignOut(BuildContext context, bool isArabic) async {
    if (_isLoggingOut) return;
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cinematicCard,
          title: Text(
            isArabic ? 'تسجيل الخروج' : 'Sign out',
            style: AppTextStyles.titleLarge(
              dialogContext,
            ).copyWith(color: Colors.white),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to sign out?',
            style: AppTextStyles.bodyPrimary(
              dialogContext,
            ).copyWith(color: AppColors.bodyText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                isArabic ? 'تسجيل الخروج' : 'Sign out',
                style: const TextStyle(color: AppColors.alertRed),
              ),
            ),
          ],
        );
      },
    );

    if (ok != true || !context.mounted) return;

    setState(() => _isLoggingOut = true);
    var loggedOut = false;
    try {
      if (userId != null && userId.isNotEmpty) {
        context.read<TicketProvider>().clearUserTickets(userId);
      }
      context.read<app_session.AppSessionProvider>().resetSession();
      await context.read<RobotMqttService>().disconnect();
      loggedOut = await authProvider.logout();
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }

    if (!context.mounted) return;
    if (!loggedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_genericFailureMessage(isArabic))),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _editProfile(BuildContext context, bool isArabic) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final fullNameController = TextEditingController(text: user.fullName);
    final displayNameController = TextEditingController(text: user.displayName);
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');
    final nationalityController = TextEditingController(
      text: user.nationality ?? '',
    );
    final avatarController = TextEditingController(text: user.avatarUrl ?? '');
    var language = user.preferredLanguage == 'arabic' ? 'arabic' : 'english';
    var marketingOptIn = user.marketingOptIn;
    var isSaving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cinematicCard,
              title: Text(
                isArabic ? 'تعديل الملف الشخصي' : 'Edit profile',
                style: AppTextStyles.titleLarge(
                  dialogContext,
                ).copyWith(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ProfileTextField(
                      controller: fullNameController,
                      label: isArabic ? 'الاسم الكامل' : 'Full name',
                    ),
                    _ProfileTextField(
                      controller: displayNameController,
                      label: isArabic ? 'اسم العرض' : 'Display name',
                    ),
                    _ProfileTextField(
                      controller: phoneController,
                      label: isArabic ? 'رقم الهاتف' : 'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    _ProfileTextField(
                      controller: nationalityController,
                      label: isArabic ? 'الجنسية' : 'Nationality',
                    ),
                    _ProfileTextField(
                      controller: avatarController,
                      label: isArabic ? 'رابط الصورة' : 'Avatar URL',
                      keyboardType: TextInputType.url,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: language,
                      dropdownColor: AppColors.cinematicElevated,
                      decoration: _profileInputDecoration(
                        isArabic ? 'لغة الواجهة' : 'UI language',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'english',
                          child: Text(isArabic ? 'الإنجليزية' : 'English'),
                        ),
                        DropdownMenuItem(
                          value: 'arabic',
                          child: Text(isArabic ? 'العربية' : 'Arabic'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => language = value);
                      },
                    ),
                    CheckboxListTile(
                      value: marketingOptIn,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryGold,
                      title: Text(
                        isArabic
                            ? 'أخبار وعروض المتحف'
                            : 'Museum news and offers',
                        style: const TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setDialogState(() => marketingOptIn = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          final ok = await authProvider.updateProfile(
                            fullName: fullNameController.text,
                            displayName: displayNameController.text,
                            phoneNumber: phoneController.text,
                            nationality: nationalityController.text,
                            preferredLanguage: language,
                            avatarUrl: avatarController.text,
                            marketingOptIn: marketingOptIn,
                          );
                          if (!dialogContext.mounted) return;
                          setDialogState(() => isSaving = false);
                          if (ok) {
                            Navigator.pop(dialogContext, true);
                            return;
                          }
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                _profileUpdateFailureMessage(isArabic),
                              ),
                            ),
                          );
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.darkInk,
                          ),
                        )
                      : Text(isArabic ? '\u062d\u0641\u0638' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !context.mounted) return;

    await context.read<UserPreferencesModel>().setLanguage(
      language == 'arabic' ? 'ar' : 'en',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_profileUpdatedMessage(isArabic))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final authProvider = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final prefs = context.watch<UserPreferencesModel>();
    final user = authProvider.currentUser;
    final userId = user?.id;

    return AppMenuShell(
      title: l10n.profile.toUpperCase(),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
      backgroundColor: AppColors.darkBackground,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppGradients.screenBackground,
          ),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 120),
              children: [
                if (authProvider.isLoading && user == null) ...[
                  _ProfileStateCard(
                    icon: Icons.account_circle_outlined,
                    title: isArabic
                        ? '\u062c\u0627\u0631\u064a \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a...'
                        : 'Loading profile...',
                    message: '',
                    isLoading: true,
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 18),
                ],
                if (authProvider.hasError && user == null) ...[
                  _ProfileStateCard(
                    icon: Icons.info_outline_rounded,
                    title: _profileLoadFailureMessage(isArabic),
                    message: _connectionIssueMessage(isArabic),
                    buttonLabel: isArabic
                        ? '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629'
                        : 'Try again',
                    onPressed: () =>
                        context.read<AuthProvider>().retryProfileLoad(),
                    isArabic: isArabic,
                  ),
                  const SizedBox(height: 18),
                ],
                _ProfileHeader(
                  name: user?.name ?? l10n.guestVisitor,
                  email:
                      user?.email ??
                      (isArabic ? 'غير مسجل الدخول' : 'Not signed in'),
                  avatarUrl: user?.avatarUrl,
                  isArabic: isArabic,
                ),
                const SizedBox(height: 18),
                if (user != null) ...[
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    title: isArabic ? 'تعديل الملف الشخصي' : 'Edit profile',
                    subtitle: isArabic
                        ? 'الاسم والهاتف والجنسية ولغة الواجهة'
                        : 'Name, phone, nationality, and UI language',
                    onTap: () => _editProfile(context, isArabic),
                  ),
                  const SizedBox(height: 6),
                ],
                _InfoCard(
                  rows: [
                    _InfoRow(
                      label: isArabic ? 'لغة الواجهة' : 'UI language',
                      value: _languageName(
                        user?.preferredLanguage ?? prefs.language,
                        isArabic,
                      ),
                    ),
                    if ((user?.nationality ?? '').isNotEmpty)
                      _InfoRow(
                        label: isArabic ? 'الجنسية' : 'Nationality',
                        value: user!.nationality!,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (userId == null || userId.isEmpty)
                  _AccountGate(isArabic: isArabic)
                else
                  StreamBuilder<List<TourPhoto>>(
                    stream: PhotoRepository().watchUserPhotos(userId),
                    builder: (context, snapshot) {
                      final photoCount = snapshot.data?.length ?? 0;
                      return _StatsGrid(
                        isArabic: isArabic,
                        museumTickets: ticketProvider.museumTickets.length,
                        robotTickets: ticketProvider.robotTourTickets.length,
                        memories: photoCount,
                      );
                    },
                  ),
                const SizedBox(height: 24),
                _SectionTitle(isArabic ? 'الوصول السريع' : 'Quick access'),
                const SizedBox(height: 12),
                _ActionTile(
                  icon: Icons.confirmation_number_outlined,
                  title: l10n.myTickets,
                  subtitle: isArabic
                      ? 'تذاكر الدخول وجولات Horus-Bot'
                      : 'Museum Entry Tickets and Horus-Bot Tour Tickets',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.myTickets),
                ),
                _ActionTile(
                  icon: Icons.event_outlined,
                  title: l10n.events,
                  subtitle: isArabic
                      ? 'الفعاليات والعروض المتاحة في المتحف'
                      : 'Museum events and scheduled moments',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.events),
                ),
                _ActionTile(
                  icon: Icons.photo_library_outlined,
                  title: isArabic ? 'الذكريات' : 'Memories',
                  subtitle: isArabic
                      ? 'الصور وسجل الزيارات'
                      : 'Photos and visit history',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.memories),
                ),
                _ActionTile(
                  icon: Icons.accessibility_outlined,
                  title: l10n.settings,
                  subtitle: isArabic
                      ? 'اللغة والتباين وحجم النص'
                      : 'Language, contrast, and text size',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                ),
                _ActionTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.notifications,
                  subtitle: isArabic
                      ? 'تنبيهات الجولة والتذاكر'
                      : 'Tour and ticket alerts',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.notificationSettings,
                  ),
                ),
                _ActionTile(
                  icon: Icons.emoji_events_outlined,
                  title: l10n.achievements,
                  subtitle: isArabic
                      ? 'الشارات وتقدم الزيارة'
                      : 'Badges and visit progress',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.achievements),
                ),
                _ActionTile(
                  icon: Icons.feedback_outlined,
                  title: l10n.feedback,
                  subtitle: isArabic
                      ? 'شاركنا رأيك في التجربة'
                      : 'Share your visit feedback',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.feedback),
                ),
                _ActionTile(
                  icon: Icons.support_agent_outlined,
                  title: l10n.supportInboxTitle,
                  subtitle: isArabic
                      ? 'طلبات ومحادثات الدعم'
                      : 'Support requests and conversations',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.supportInbox),
                ),
                _ActionTile(
                  icon: Icons.info_outline,
                  title: l10n.about,
                  subtitle: isArabic
                      ? 'عن مشروع Horus-Bot'
                      : 'About the Horus-Bot project',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.projectInfo),
                ),
                _ActionTile(
                  icon: Icons.groups_2_outlined,
                  title: l10n.team,
                  subtitle: isArabic
                      ? 'الفريق والمشرفون'
                      : 'Team members and supervisors',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.team),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 56,
                  child: TextButton.icon(
                    onPressed: _isLoggingOut
                        ? null
                        : () => _confirmSignOut(context, isArabic),
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.alertRed,
                            ),
                          )
                        : const Icon(Icons.logout_rounded),
                    label: Text(isArabic ? 'تسجيل الخروج' : 'Sign out'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.alertRed,
                      backgroundColor: AppColors.cinematicCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: AppColors.alertRed.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isArabic,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.premiumGlassCard(
        radius: 24,
        highlighted: true,
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          _Avatar(name: name, avatarUrl: avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStateCard extends StatelessWidget {
  const _ProfileStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.isArabic,
    this.buttonLabel,
    this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isArabic;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.secondaryGlassCard(radius: 20),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: Directionality.of(context),
            children: [
              isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGold,
                      ),
                    )
                  : Icon(icon, color: AppColors.primaryGold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.bodyPrimary(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.start,
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
            ),
          ],
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onPressed,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _profileInputDecoration(label),
      ),
    );
  }
}

InputDecoration _profileInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.neutralMedium),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryGold),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();
    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.primaryGold,
      foregroundColor: AppColors.darkInk,
      backgroundImage: avatarUrl == null || avatarUrl!.isEmpty
          ? null
          : NetworkImage(avatarUrl!),
      child: avatarUrl == null || avatarUrl!.isEmpty
          ? Text(
              initials.isEmpty ? 'H' : initials,
              style: AppTextStyles.titleLarge(
                context,
              ).copyWith(color: AppColors.darkInk),
            )
          : null,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.secondaryGlassCard(radius: 20),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(color: AppColors.neutralMedium),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.bodyPrimary(
                          context,
                        ).copyWith(color: Colors.white),
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

class _InfoRow {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.isArabic,
    required this.museumTickets,
    required this.robotTickets,
    required this.memories,
  });

  final bool isArabic;
  final int museumTickets;
  final int robotTickets;
  final int memories;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        _StatCard(
          icon: Icons.museum_outlined,
          value: '$museumTickets',
          label: isArabic ? 'تذاكر المتحف' : 'Museum tickets',
        ),
        _StatCard(
          icon: Icons.smart_toy_outlined,
          value: '$robotTickets',
          label: isArabic ? 'جولات الروبوت' : 'Robot tours',
        ),
        _StatCard(
          icon: Icons.photo_library_outlined,
          value: '$memories',
          label: isArabic ? 'ذكريات' : 'Memories',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.secondaryGlassCard(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 22),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLarge(
              context,
            ).copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metadata(
              context,
            ).copyWith(color: AppColors.neutralMedium, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AccountGate extends StatelessWidget {
  const _AccountGate({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return _ActionTile(
      icon: Icons.login_rounded,
      title: isArabic ? 'سجّل الدخول لحفظ رحلتك' : 'Sign in to save your visit',
      subtitle: isArabic
          ? 'التذاكر والذكريات والجولات ترتبط بحسابك.'
          : 'Tickets, memories, and tours are linked to your account.',
      onTap: () => Navigator.pushNamed(context, AppRoutes.login),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.displaySectionTitle(
        context,
      ).copyWith(color: AppColors.softGold),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.secondaryGlassCard(radius: 18),
            child: Row(
              textDirection: Directionality.of(context),
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primaryGold),
                ),
                const SizedBox(width: 14),
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
                        style: AppTextStyles.bodyPrimary(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.metadata(
                          context,
                        ).copyWith(color: AppColors.neutralMedium),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isArabic
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppColors.primaryGold,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _connectionIssueMessage(bool isArabic) {
  return isArabic
      ? '\u062d\u062f\u062b\u062a \u0645\u0634\u0643\u0644\u0629 \u0641\u064a \u0627\u0644\u0627\u062a\u0635\u0627\u0644. \u064a\u0631\u062c\u0649 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0627\u0644\u0625\u0646\u062a\u0631\u0646\u062a \u0648\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
      : 'Connection issue. Please check your internet connection and try again.';
}

String _genericFailureMessage(bool isArabic) {
  return isArabic
      ? '\u062d\u062f\u062b \u062e\u0637\u0623 \u0645\u0627. \u064a\u0631\u062c\u0649 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649.'
      : 'Something went wrong. Please try again.';
}

String _profileLoadFailureMessage(bool isArabic) {
  return isArabic
      ? '\u062a\u0639\u0630\u0631 \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a.'
      : 'We could not load your profile.';
}

String _profileUpdatedMessage(bool isArabic) {
  return isArabic
      ? '\u062a\u0645 \u062a\u062d\u062f\u064a\u062b \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a.'
      : 'Profile updated.';
}

String _profileUpdateFailureMessage(bool isArabic) {
  return isArabic
      ? '\u062a\u0639\u0630\u0631 \u062a\u062d\u062f\u064a\u062b \u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062e\u0635\u064a.'
      : 'We could not update your profile.';
}

String _languageName(String languageCode, bool isArabic) {
  final normalized = languageCode.toLowerCase().replaceAll('-', '_');
  if (normalized == 'ar' || normalized == 'arabic') {
    return isArabic ? 'العربية' : 'Arabic';
  }
  return isArabic ? 'الإنجليزية' : 'English';
}
