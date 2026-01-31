import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Achievements',
      body: Center(child: Text('Achievements (badges next)')),
    );
  }
}
