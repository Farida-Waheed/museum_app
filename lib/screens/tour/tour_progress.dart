import 'package:flutter/material.dart';

import 'live_tour_screen.dart';

/// Legacy compatibility wrapper.
///
/// LiveTourScreen is the canonical during-visit progress surface. Keeping this
/// route as a wrapper prevents older notifications/deep links from opening an
/// outdated static progress UI.
class TourProgressScreen extends StatelessWidget {
  const TourProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveTourScreen();
  }
}
