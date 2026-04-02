import 'package:flutter/material.dart';
import '../core/services/mock_data.dart';
import '../models/exhibit.dart';
import '../models/tour_provider.dart';

/// Simple in-app knowledge source for a retrieval-augmented museum assistant.
class MuseumKnowledgeService {
  final List<Exhibit> _exhibits = MockDataService.getAllExhibits();

  final String museumName = 'Grand Egyptian Museum';
  final String museumDescription =
      'The Grand Egyptian Museum is home to Egypt’s greatest collection of ancient artifacts including Tutankhamun’s treasures.';

  String getMuseumHours({required String language}) {
    if (language == 'ar') {
      return 'ساعات العمل: من 9 صباحًا إلى 6 مساءً يوميًا، مع تمديد حتى 9 مساءً أيام الجمعة والسبت.';
    }
    return 'Opening hours: 9 AM to 6 PM daily, with extended hours until 9 PM on Fridays and Saturdays.';
  }

  String getTicketInfo({required String language}) {
    if (language == 'ar') {
      return 'تذكرة الدخول العامة: 200 جنيهًا. تذاكر الأطفال وكبار السن بناءً على التأهيل المحلي.';
    }
    return 'General admission: 200 EGP. Child and senior tickets are available with local eligibility.';
  }

  List<Exhibit> searchExhibits(String query) {
    final keyword = query.toLowerCase().trim();
    final results = _exhibits.where((exhibit) {
      return exhibit.nameEn.toLowerCase().contains(keyword) ||
          exhibit.nameAr.toLowerCase().contains(keyword) ||
          exhibit.descriptionEn.toLowerCase().contains(keyword) ||
          exhibit.descriptionAr.toLowerCase().contains(keyword);
    }).toList();
    return results;
  }

  Exhibit? findExhibitById(String id) {
    try {
      return _exhibits.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Exhibit? findExhibitByName(String name) {
    final predicate = name.toLowerCase();
    try {
      return _exhibits.firstWhere((e) {
        return e.nameEn.toLowerCase().contains(predicate) ||
            e.nameAr.toLowerCase().contains(predicate);
      });
    } catch (_) {
      return null;
    }
  }

  /// Produces a retrieval context snippet from the exhibit and environmental info.
  String buildRetrievalSnippet({
    Exhibit? exhibit,
    TourProvider? tour,
    required String language,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Museum: $museumName.');
    buffer.writeln(museumDescription);
    buffer.writeln(getMuseumHours(language: language));
    buffer.writeln(getTicketInfo(language: language));

    if (exhibit != null) {
      buffer.writeln('Current exhibit context: ${exhibit.getName(language)}.');
      buffer.writeln(exhibit.getDescription(language));
    }

    if (tour != null && tour.currentExhibitId != null) {
      final current = findExhibitById(tour.currentExhibitId!);
      if (current != null) {
        buffer.writeln('Tour at: ${current.getName(language)}.');
      }
      if (tour.nextExhibitId != null) {
        final next = findExhibitById(tour.nextExhibitId!);
        if (next != null) {
          buffer.writeln('Onward to: ${next.getName(language)} in ${tour.estimatedTimeToNext.round()} seconds.');
        }
      }
    }

    return buffer.toString();
  }
}
