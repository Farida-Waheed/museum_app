import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exhibit.dart';
import '../models/exhibit_provider.dart';
import '../models/tour_provider.dart';
import '../models/user_preferences.dart';

class ChatContext {
  final String screen;
  final Exhibit? exhibit;
  final TourProvider? tourState;
  final String language;
  final String question;

  ChatContext({
    required this.screen,
    required this.language,
    required this.question,
    this.exhibit,
    this.tourState,
  });

  @override
  String toString() {
    return 'Screen: $screen, Exhibit: ${exhibit?.nameEn ?? 'none'}, Language: $language, Question: $question';
  }
}

class ChatContextBuilder {
  static ChatContext build(
    BuildContext context, {
    String? screen,
    String userQuestion = '',
    String? exhibitId,
  }) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final tour = Provider.of<TourProvider>(context, listen: false);
    final exhibits = Provider.of<ExhibitProvider>(context, listen: false);

    Exhibit? exhibit;
    if (exhibitId != null) {
      if (exhibits.exhibits.isNotEmpty) {
        exhibit = exhibits.exhibits.firstWhere(
          (e) => e.id == exhibitId,
          orElse: () => exhibits.exhibits.first,
        );
      }
    } else if (tour.currentExhibitId != null) {
      if (exhibits.exhibits.isNotEmpty) {
        exhibit = exhibits.exhibits.firstWhere(
          (e) => e.id == tour.currentExhibitId,
          orElse: () => exhibits.exhibits.first,
        );
      }
    }

    return ChatContext(
      screen: screen ?? 'home',
      language: prefs.language,
      question: userQuestion,
      exhibit: exhibit,
      tourState: tour,
    );
  }
}
