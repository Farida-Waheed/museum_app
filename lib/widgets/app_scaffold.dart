import 'package:flutter/material.dart';

import '../core/constants/text_styles.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  /// If true, shows BottomNav. If false, no BottomNav (for QR/Quiz/Onboarding).
  final bool showBottomNav;

  /// Required only if showBottomNav = true
  final int? bottomNavIndex;

  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBottomNav = false,
    this.bottomNavIndex,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      showBottomNav == false || bottomNavIndex != null,
      'If showBottomNav is true, bottomNavIndex must not be null.',
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        title: title,
        actions: actions,
        showDrawerIcon: true,
      ),
      body: Padding(padding: AppPadding.page, child: body),
      bottomNavigationBar: showBottomNav
          ? BottomNav(currentIndex: bottomNavIndex!)
          : null,
    );
  }
}
