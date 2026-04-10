import 'package:flutter/material.dart';
import '../core/services/mock_data.dart';
import '../models/exhibit.dart';
import '../models/tour_provider.dart';

class KnowledgeResponse {
  final String header;
  final List<String> bullets;
  final String followUp;

  KnowledgeResponse({
    required this.header,
    required this.bullets,
    required this.followUp,
  });

  String toText() {
    final buffer = StringBuffer(header);
    if (bullets.isNotEmpty) {
      buffer.writeln();
      for (final item in bullets) {
        buffer.writeln('• $item');
      }
    }
    if (followUp.isNotEmpty) {
      buffer.writeln();
      buffer.write(followUp);
    }
    return buffer.toString();
  }
}

/// Simple in-app knowledge source for a retrieval-augmented museum assistant.
class MuseumKnowledgeService {
  // Structured response for chat service consumption.
  // Keep this minimal and easy to translate.
  // Future API integration can keep this shape as domain object.

  final List<Exhibit> _exhibits = MockDataService.getAllExhibits();

  final String museumName = 'Grand Egyptian Museum';
  final String museumDescription =
      'The Grand Egyptian Museum is home to Egypt’s greatest collection of ancient artifacts including Tutankhamun’s treasures.';

  String getMuseumHours({required String language}) {
    final response = language == 'ar'
        ? KnowledgeResponse(
            header: 'إليك مواعيد الزيارة التي قد تحتاجها.',
            bullets: [
              'الافتتاح: 9:00 صباحًا',
              'الإغلاق: 6:00 مساءً',
              'آخر دخول: 5:30 مساءً',
              'تمديد الجمعة/السبت حتى 9:00 مساءً',
            ],
            followUp: 'يمكنني أيضًا مساعدتك في اختيار أفضل وقت للزيارة.',
          )
        : KnowledgeResponse(
            header: 'Here are the museum hours you may need.',
            bullets: [
              'Opening: 9:00 AM',
              'Closing: 6:00 PM',
              'Last entry: 5:30 PM',
              'Fri/Sat extended to 9:00 PM',
            ],
            followUp: 'I can also help you plan the best time to visit.',
          );
    return response.toText();
  }

  String getTicketInfo({required String language}) {
    final response = language == 'ar'
        ? KnowledgeResponse(
            header: 'إليك تفاصيل التذاكر الحالية.',
            bullets: [
              'الدخول العام: 200 جنيهًا',
              'الطلاب وكبار السن قد يحق لهم خصومات حسب الأهلية المحلية',
              'قد تختلف الأسعار للزوار الأجانب',
            ],
            followUp:
                'وإذا أردت، يمكنني أيضًا توضيح أفضل مسار للزيارة أو أقرب بوابة دخول.',
          )
        : KnowledgeResponse(
            header: 'Here are the current ticket details.',
            bullets: [
              'General admission: 200 EGP',
              'Student/senior offers may vary depending on local eligibility',
              'Foreign visitor pricing may differ',
            ],
            followUp:
                'If you’d like, I can also explain the best visit route or nearest gate.',
          );
    return response.toText();
  }

  String getVisitDuration({required String language}) {
    final response = language == 'ar'
        ? KnowledgeResponse(
            header: 'هذه توصيفات الوقت، لتخطيط زيارتك.',
            bullets: [
              'زيارة سريعة: 45-60 دقيقة',
              'زيارة قياسية: 1.5-2 ساعة',
              'تجربة كاملة: أكثر من 3 ساعات',
            ],
            followUp: 'أخبرني إن كنت تريد مسارًا مخصصًا لوقت محدد.',
          )
        : KnowledgeResponse(
            header: 'Here is the estimated visit duration guide.',
            bullets: [
              'Quick visit: 45-60 minutes',
              'Standard visit: 1.5-2 hours',
              'Full experience: 3+ hours',
            ],
            followUp: 'Let me know if you want a suggested route for a specific timespan.',
          );
    return response.toText();
  }

  String getEventHighlights({required String language}) {
    final event = MockDataService.getAllEvents().first;
    final response = language == 'ar'
        ? KnowledgeResponse(
            header: 'إليك أبرز فعاليات اليوم.',
            bullets: [
              'الحدث القادم: ${event.titleAr}',
              'الوصف: ${event.descriptionAr}',
              'الوقت: ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
              'المكان: ${event.locationAr}',
            ],
            followUp: 'اطلب جدول الفعالية الكامل إذا رغبت.',
          )
        : KnowledgeResponse(
            header: 'Here are today’s event highlights.',
            bullets: [
              'Next event: ${event.titleEn}',
              'Description: ${event.descriptionEn}',
              'Time: ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
              'Location: ${event.locationEn}',
            ],
            followUp: 'Ask for the full schedule if you like.',
          );
    return response.toText();
  }

  String getExhibitHighlight(Exhibit exhibit, {required String language}) {
    final title = exhibit.getName(language);
    final snippet = exhibit.getDescription(language).split('.').first;
    if (language == 'ar') {
      final response = KnowledgeResponse(
        header: 'من أفضل الأماكن للبدء: $title.',
        bullets: [snippet],
        followUp: 'اخبرني إذا أردت مسارًا موجهًا لهذه القاعة.',
      );
      return response.toText();
    }
    final response = KnowledgeResponse(
      header: 'A great place to begin is $title.',
      bullets: [snippet],
      followUp: 'Let me know if you want a guided route for this hall.',
    );
    return response.toText();
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
          buffer.writeln(
            'Onward to: ${next.getName(language)} in ${tour.estimatedTimeToNext.round()} seconds.',
          );
        }
      }
    }

    return buffer.toString();
  }
}
