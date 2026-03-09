import 'package:flutter/material.dart';

// import '../../widgets/app_scaffold.dart';
import '../../widgets/app_card.dart';

import '../../core/constants/sizes.dart';
import '../../core/constants/text_styles.dart';

import '../../core/services/progress_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Profile'));
  }
}
