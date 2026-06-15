import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';
import '../models/auth_provider.dart';
import '../widgets/ask_the_guide_button.dart';

import '../models/user_preferences.dart';
import '../app/router.dart';

class _SideMenu extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onClose;
  final void Function(String route) onPush;
  final void Function(String route) onReplace;
  final String? currentRoute;

  const _SideMenu({
    required this.isArabic,
    required this.onClose,
    required this.onPush,
    required this.onReplace,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = (size.width * 0.78).clamp(280.0, 340.0).toDouble();
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final isGuest = !authProvider.isLoggedIn;
    final useLightSurfaces = AppColors.useLightSurfaces;
    final userName = authProvider.currentUser?.name ?? l10n.guestUser;
    final userSubtitle = authProvider.isLoggedIn
        ? authProvider.currentUser?.email ?? l10n.exploreTheMuseum
        : l10n.exploreTheMuseum;

    return Align(
      alignment: isArabic
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isArabic
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              end: isArabic
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              colors: [
                if (useLightSurfaces) ...[
                  AppColors.websiteLightPopover.withValues(alpha: 0.94),
                  AppColors.cardGlass(0.88),
                  AppColors.websiteLightBackground.withValues(alpha: 0.18),
                ] else ...[
                  Colors.black.withValues(alpha: 0.90),
                  Colors.black.withValues(alpha: 0.74),
                  Colors.transparent,
                ],
              ],
              stops: const [0.0, 0.76, 1.0],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadiusDirectional.horizontal(
              end: Radius.circular(useLightSurfaces ? 30 : 0),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: useLightSurfaces ? 16 : 0,
                sigmaY: useLightSurfaces ? 16 : 0,
              ),
              child: SafeArea(
                child: Directionality(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      28,
                      24,
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/horus_eye.png',
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                l10n.appTitle.toUpperCase(),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.premiumBrandTitle(
                                  context,
                                ).copyWith(color: AppColors.primaryGold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.secondaryGlass(0.82),
                              child: const Icon(
                                Icons.person_outline,
                                color: AppColors.primaryGold,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: isArabic
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    textAlign: TextAlign.start,
                                    style:
                                        AppTextStyles.premiumCardTitle(
                                          context,
                                        ).copyWith(
                                          fontSize: 18,
                                          color: AppColors.resolvedTitleText,
                                        ),
                                  ),
                                  Text(
                                    userSubtitle,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.premiumMutedBody(
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryGold.withValues(
                            alpha: useLightSurfaces ? 0.06 : 0.10,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      children: [
                        _SectionHeader(label: l10n.accountPreferences),
                        _MenuItem(
                          icon: Icons.person_outline,
                          label: l10n.profile,
                          selected: currentRoute == AppRoutes.profile,
                          onTap: () => onReplace(AppRoutes.profile),
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: l10n.settings,
                          selected:
                              currentRoute == AppRoutes.settings ||
                              currentRoute == AppRoutes.accessibility,
                          onTap: () => onReplace(AppRoutes.settings),
                        ),
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: l10n.notifications,
                          selected:
                              currentRoute == AppRoutes.notificationSettings,
                          onTap: () =>
                              onReplace(AppRoutes.notificationSettings),
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(label: l10n.visitorServices),
                        _MenuItem(
                          icon: Icons.support_agent_outlined,
                          label: l10n.supportInboxTitle,
                          selected: currentRoute == AppRoutes.supportInbox,
                          onTap: () => onReplace(AppRoutes.supportInbox),
                        ),
                        if (!isGuest)
                          _MenuItem(
                            icon: Icons.rate_review_outlined,
                            label: l10n.feedback,
                            selected: currentRoute == AppRoutes.feedback,
                            onTap: () => onReplace(AppRoutes.feedback),
                          ),
                        const SizedBox(height: 16),
                        _SectionHeader(label: l10n.information),
                        _MenuItem(
                          icon: Icons.info_outline,
                          label: l10n.about,
                          selected: currentRoute == AppRoutes.projectInfo,
                          onTap: () => onReplace(AppRoutes.projectInfo),
                        ),
                        _MenuItem(
                          icon: Icons.event_outlined,
                          label: l10n.events,
                          selected: currentRoute == AppRoutes.events,
                          onTap: () => onReplace(AppRoutes.events),
                        ),
                        if (!isGuest)
                          _MenuItem(
                            icon: Icons.emoji_events_outlined,
                            label: l10n.achievements,
                            selected: currentRoute == AppRoutes.achievements,
                            onTap: () => onReplace(AppRoutes.achievements),
                          ),
                      ],
                    ),
                  ),
                ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 24, 24, 12),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.start,
        style: AppTextStyles.premiumSectionLabel(context).copyWith(
          fontSize: 12,
          letterSpacing: 2.1,
          color: AppColors.softGold.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        visualDensity: const VisualDensity(vertical: -3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          size: 23,
          color: selected ? AppColors.primaryGold : AppColors.resolvedBodyText,
        ),
        title: Text(
          label,
          textAlign: TextAlign.start,
          style: AppTextStyles.premiumBody(context).copyWith(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? AppColors.primaryGold
                : AppColors.resolvedBodyText,
          ),
        ),
        tileColor: selected
            ? AppColors.primaryGold.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
    );
  }
}

class _ShellBrandTitle extends StatelessWidget {
  const _ShellBrandTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icons/horus_eye.png', width: 18, height: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.premiumBrandTitle(context).copyWith(
              fontSize: 16.5,
              height: 1.08,
              shadows: [
                if (!AppColors.useLightSurfaces)
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.70),
                    blurRadius: 10,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShellCircleButton extends StatelessWidget {
  const _ShellCircleButton({
    required this.icon,
    required this.onTap,
    required this.scrollStrength,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double scrollStrength;

  @override
  Widget build(BuildContext context) {
    final useLightSurfaces = AppColors.useLightSurfaces;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8 + (8 * scrollStrength),
                sigmaY: 8 + (8 * scrollStrength),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: useLightSurfaces
                      ? AppColors.cardGlass(0.90 - (0.18 * scrollStrength))
                      : Colors.black.withValues(
                          alpha: 0.09 + (0.15 * scrollStrength),
                        ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.goldBorder(0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkInk.withValues(
                        alpha: useLightSurfaces
                            ? 0.08 + (0.08 * scrollStrength)
                            : 0.10 + (0.10 * scrollStrength),
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.resolvedTitleText, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellFloatingHeader extends StatelessWidget {
  const _ShellFloatingHeader({
    required this.title,
    required this.leadingIcon,
    required this.onLeading,
    this.actions,
    this.subHeader,
  });

  final String title;
  final IconData leadingIcon;
  final VoidCallback onLeading;
  final List<Widget>? actions;
  final Widget? subHeader;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    const scrollStrength = 0.0;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: topPadding + (subHeader == null ? 86 : 134),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 3, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      textDirection: Directionality.of(context),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ShellCircleButton(
                          icon: leadingIcon,
                          onTap: onLeading,
                          scrollStrength: scrollStrength,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: IgnorePointer(
                            child: _ShellBrandTitle(title: title),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (actions != null && actions!.isNotEmpty)
                          Row(mainAxisSize: MainAxisSize.min, children: actions!)
                        else
                          const SizedBox(width: 44, height: 44),
                      ],
                    ),
                    if (subHeader != null) ...[
                      const SizedBox(height: 10),
                      subHeader!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppMenuShell extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showChatButton;
  final Color? backgroundColor;
  final bool hideDefaultAppBar;
  final Widget? subHeader;
  final Widget? floatingActionButton;

  const AppMenuShell({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.showChatButton = false,
    this.backgroundColor,
    this.hideDefaultAppBar = false,
    this.subHeader,
    this.floatingActionButton,
  });

  static AppMenuShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppMenuShellState>();
  }

  @override
  State<AppMenuShell> createState() => AppMenuShellState();
}

class AppMenuShellState extends State<AppMenuShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (_isMenuOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  }

  void openMenu() {
    if (_isMenuOpen) return;
    _menuController.forward();
    setState(() {
      _isMenuOpen = true;
    });
  }

  void closeMenu() {
    if (!_isMenuOpen) return;
    _menuController.reverse();
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _goPush(String route) {
    _forceCloseMenu();
    Navigator.pushNamed(context, route);
  }

  void _goReplace(String route) {
    _forceCloseMenu();
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  void _forceCloseMenu() {
    _menuController.value = 0;
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final requestedBg = widget.backgroundColor;
    final bgColor =
        !isDarkTheme &&
            (requestedBg == null ||
                requestedBg == AppColors.cinematicBackground ||
                requestedBg == AppColors.baseBlack)
        ? Theme.of(context).scaffoldBackgroundColor
        : (requestedBg ?? AppColors.cinematicBackground);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          widget.floatingActionButton ??
          (widget.showChatButton
              ? const AskHorusFloatingChip()
              : null),
      body: AnimatedBuilder(
        animation: _menuController,
        builder: (context, _) {
          final v = _menuController.value;
          final blur = 10 * v;
          final menuWidth = (size.width * 0.78).clamp(280.0, 340.0).toDouble();
          final menuDx = (isArabic ? 1 : -1) * menuWidth * (1 - v);

          return Stack(
            fit: StackFit.expand,
            children: [
              AbsorbPointer(
                absorbing: _isMenuOpen,
                child: Container(
                  color: bgColor,
                  child: Builder(
                    builder: (innerContext) {
                      if (widget.hideDefaultAppBar) return widget.body;
                      final canPop = Navigator.canPop(innerContext);
                      final leadingIcon = canPop
                          ? (isArabic
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_new_rounded)
                          : Icons.menu_rounded;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(child: widget.body),
                          _ShellFloatingHeader(
                            title: widget.title ?? l10n.appTitle,
                            leadingIcon: leadingIcon,
                            onLeading: () {
                              if (canPop) {
                                Navigator.pop(innerContext);
                              } else {
                                toggleMenu();
                              }
                            },
                            actions: widget.actions,
                            subHeader: widget.subHeader,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (v > 0)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: closeMenu,
                    onHorizontalDragUpdate: (details) {
                      if (isArabic) {
                        if (details.primaryDelta! > 10 && _isMenuOpen) {
                          closeMenu();
                        }
                      } else {
                        if (details.primaryDelta! < -10 && _isMenuOpen) {
                          closeMenu();
                        }
                      }
                    },
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                      child: Container(
                        color: AppColors.useLightSurfaces
                            ? AppColors.darkInk.withValues(alpha: 0.10 * v)
                            : Colors.black.withValues(alpha: 0.46 * v),
                      ),
                    ),
                  ),
                ),
              if (v > 0)
                Transform.translate(
                  offset: Offset(menuDx, 0),
                  child: _SideMenu(
                    isArabic: isArabic,
                    onClose: closeMenu,
                    onPush: _goPush,
                    onReplace: _goReplace,
                    currentRoute: currentRoute,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
