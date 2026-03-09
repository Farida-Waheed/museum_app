import 'package:flutter/material.dart';
import '../core/constants/sizes.dart';
import '../core/constants/text_styles.dart';
import '../core/constants/strings.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showDrawerIcon;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showDrawerIcon = true,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final useBack = !showDrawerIcon && canPop;

    return AppBar(
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      leadingWidth: AppSizes.iconTapSize,
      leading: showDrawerIcon
          ? Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          : (useBack
              ? IconButton(
                  tooltip: 'Back',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                )
              : null),
      title: Text(
        title ?? AppStrings.appName,
        style: AppTextStyles.title(context),
      ),
      actions: actions,
    );
  }
}
