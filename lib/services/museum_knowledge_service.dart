import 'dart:math' as math;
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
  final List<Exhibit> _exhibits = MockDataService.getAllExhibits();

  final String museumName = 'Grand Egyptian Museum';
  final String museumDescription =
      'The Grand Egyptian Museum is home to Egypt’s greatest collection of ancient artifacts including Tutankhamun’s treasures.';

  final Map<String, List<String>> _exhibitAliases = {
    'gem_tut_golden_mask': [
      'tutankhamun',
      'tutankhamen',
      'king tut',
      'king tutankhamun',
      'golden mask',
      'توت عنخ آمون',
      'توت عنخ',
      'القناع الذهبي',
    ],
    'gem_ramses2_colossus': [
      'ramesses ii',
      'ramesses',
      'ramses',
      'رمسيس الثاني',
      'رمسيس',
      'تمثال رمسيس',
    ],
    'gem_ptolemaic_king_colossus': [
      'ptolemaic king',
      'بطلمي',
      'تمثال ملك بطلمي',
    ],
    'gem_ptolemaic_queen_colossus': [
      'ptolemaic queen',
      'cleopatra',
      'كليوباترا',
      'تمثال ملكة بطلمية',
    ],
    'gem_anubis_chest': ['anubis chest', 'anubis', 'أنوبيس', 'مقصورة أنوبيس'],
  };

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ')
        .replaceAll(RegExp(r'[_\W]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _searchTerms(Exhibit exhibit) {
    final terms = <String>[
      exhibit.nameEn,
      exhibit.nameAr,
      exhibit.descriptionEn,
      exhibit.descriptionAr,
    ];
    terms.addAll(_exhibitAliases[exhibit.id] ?? []);
    return terms.map(_normalize).where((t) => t.isNotEmpty).toList();
  }

  double _similarity(String a, String b) {
    final distance = _levenshteinDistance(a, b).toDouble();
    final maxLen = math.max(a.length, b.length).toDouble();
    if (maxLen == 0) return 1.0;
    return 1.0 - (distance / maxLen);
  }

  int _levenshteinDistance(String a, String b) {
    final lenA = a.length;
    final lenB = b.length;
    final matrix = List.generate(
      lenA + 1,
      (_) => List<int>.filled(lenB + 1, 0),
    );
    for (var i = 0; i <= lenA; i++) matrix[i][0] = i;
    for (var j = 0; j <= lenB; j++) matrix[0][j] = j;
    for (var i = 1; i <= lenA; i++) {
      for (var j = 1; j <= lenB; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }
    return matrix[lenA][lenB];
  }

  Exhibit? findBestExhibitMatch(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return null;

    // Exact and alias matches
    for (final exhibit in _exhibits) {
      for (final term in _searchTerms(exhibit)) {
        if (term == normalizedQuery ||
            term.contains(normalizedQuery) ||
            normalizedQuery.contains(term)) {
          return exhibit;
        }
      }
    }

    // Similarity-based fallback
    Exhibit? best;
    double bestScore = 0.0;
    for (final exhibit in _exhibits) {
      for (final term in _searchTerms(exhibit)) {
        final score = _similarity(normalizedQuery, term);
        if (score > bestScore) {
          bestScore = score;
          best = exhibit;
        }
      }
    }

    return (bestScore >= 0.38) ? best : null;
  }

  List<Exhibit> findClosestMatches(String query, {int limit = 3}) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return [];

    final scores = <Exhibit, double>{};
    for (final exhibit in _exhibits) {
      var maxScore = 0.0;
      for (final term in _searchTerms(exhibit)) {
        maxScore = math.max(maxScore, _similarity(normalizedQuery, term));
      }
      scores[exhibit] = maxScore;
    }

    final sorted = scores.entries.where((entry) => entry.value > 0.25).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((entry) => entry.key).toList();
  }

  List<Exhibit> searchExhibits(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) return [];
    final results = _exhibits.where((exhibit) {
      return _searchTerms(
        exhibit,
      ).any((term) => term.contains(normalizedQuery));
    }).toList();
    if (results.isNotEmpty) return results;
    return findClosestMatches(query);
  }

  Exhibit? findExhibitById(String id) {
    try {
      return _exhibits.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Exhibit? findExhibitByName(String name) {
    final predicate = _normalize(name);
    try {
      return _exhibits.firstWhere((e) {
        return _searchTerms(e).any((term) => term.contains(predicate));
      });
    } catch (_) {
      return null;
    }
  }

  String getTicketInfo({required String language}) {
    if (language == 'ar') {
      return 'التذاكر متاحة عند المدخل. السعر القياسي 250 جنيهًا، مع خصومات للطلاب والأطفال. تُقبل بطاقات النقد وبطاقات الائتمان.';
    }
    return 'Tickets are available at the entrance. Standard admission is EGP 250, with discounts for students and children. Both cash and cards are accepted.';
  }

  String getMuseumHours({required String language}) {
    if (language == 'ar') {
      return 'المتحف مفتوح من 9 صباحًا حتى 5 مساءً يومياً ما عدا العطلات الرسمية. يُنصح بالوصول مبكراً لتفادي الزحام.';
    }
    return 'The museum is open daily from 9 AM to 5 PM, except public holidays. We recommend arriving early to avoid the crowds.';
  }

  String getEventHighlights({required String language}) {
    if (language == 'ar') {
      return 'تُقام جولات مرشدة وورش عمل خاصة طوال اليوم. تحقق من اللوحات الإرشادية في الردهة الرئيسية لمعرفة التوقيتات الدقيقة.';
    }
    return 'Guided tours and special workshops are running throughout the day. Check the signage in the main foyer for exact schedules.';
  }

  String getVisitDuration({required String language}) {
    if (language == 'ar') {
      return 'الزيارات العادية تستغرق عادة بين ساعة ونصف إلى ساعتين. إذا كنت ترغب في استكشاف كل التفاصيل، فخطط لبضع ساعات إضافية.';
    }
    return 'A typical visit takes about one and a half to two hours. If you want to explore every detail, plan for a few extra hours.';
  }

  String _shortTextExcerpt(String text, {int maxLength = 130}) {
    final cleaned = text.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    final sentences = cleaned.split(RegExp(r'(?<=[.!?؟])\s+'));
    var excerpt = sentences.isNotEmpty ? sentences.first : cleaned;
    if (excerpt.length > maxLength) {
      excerpt = '${excerpt.substring(0, maxLength).trim()}...';
    }
    return excerpt;
  }

  String getShortExhibitOverview(Exhibit exhibit, String language) {
    final description = exhibit.getDescription(language);
    final excerpt = _shortTextExcerpt(description);
    if (language == 'ar') {
      return excerpt;
    }
    return excerpt;
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
