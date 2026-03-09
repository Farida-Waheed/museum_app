import '../../models/exhibit.dart';
import '../../models/quiz.dart';

/// ONE source of truth for demo/offline data.
/// - Exhibits (used by exhibit list/map/tour)
/// - Quiz questions
/// - Events (for Events screen)
/// - Achievements badges
/// - Planner tags/interests
class MockDataService {
  // -------------------------
  // Exhibits
  // -------------------------
  static final List<Exhibit> exhibits = [
    Exhibit(
      id: '1',
      nameEn: 'Ancient Vase',
      nameAr: 'مزهرية قديمة',
      descriptionEn:
          'A rare Greek vase from 300 BC, depicting the battle of Troy.',
      descriptionAr:
          'مزهرية يونانية نادرة من عام 300 قبل الميلاد تصور معركة طروادة.',
      imageAsset: 'assets/images/vase.png',
      x: 50.0,
      y: 100.0,
    ),
    Exhibit(
      id: '2',
      nameEn: 'Dinosaur Bone',
      nameAr: 'عظم ديناصور',
      descriptionEn:
          'The femur bone of a Tyrannosaurus Rex discovered in 1995.',
      descriptionAr: 'عظم فخذ التيرانوصور ريكس الذي تم اكتشافه عام 1995.',
      imageAsset: 'assets/images/dino.png',
      x: 200.0,
      y: 300.0,
    ),
    Exhibit(
      id: '3',
      nameEn: 'Space Suit',
      nameAr: 'بدلة فضاء',
      descriptionEn: 'An original Apollo 11 space suit replica.',
      descriptionAr: 'نسخة طبق الأصل من بدلة فضاء أبولو 11.',
      imageAsset: 'assets/images/space.png',
      x: 300.0,
      y: 150.0,
    ),
  ];

  static List<Exhibit> getAllExhibits() => exhibits;

  static List<MockEvent> getAllEvents() => events;

  /// Planner tags without modifying Exhibit model:
  /// Map exhibitId -> tags
  static final Map<String, List<String>> exhibitTags = {
    '1': ['History', 'Highlights'],
    '2': ['History', 'Kids-friendly'],
    '3': ['Highlights', 'History'],
  };

  /// Interests shown in Tour Planner chips
  static const List<String> interests = [
    'Highlights',
    'History',
    'Statues',
    'Mummies',
    'Kids-friendly',
  ];

  // -------------------------
  // Quiz Questions
  // -------------------------
  static final List<QuizQuestion> questions = [
    QuizQuestion(
      id: 'q1',
      questionEn: 'Which era is the Ancient Vase from?',
      questionAr: 'إلى أي حقبة تعود المزهرية القديمة؟',
      optionsEn: ['1000 AD', '300 BC', '1990', '500 BC'],
      optionsAr: ['1000 م', '300 ق.م', '1990', '500 ق.م'],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      id: 'q2',
      questionEn: 'What dinosaur does the bone belong to?',
      questionAr: 'لأي ديناصور ينتمي هذا العظم؟',
      optionsEn: ['T-Rex', 'Stegosaurus', 'Raptor', 'Triceratops'],
      optionsAr: ['تي ريكس', 'ستيغوسورس', 'رابتور', 'تريسيراتوبس'],
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      id: 'q3',
      questionEn: 'Which mission used the Space Suit?',
      questionAr: 'أي مهمة استخدمت بدلة الفضاء؟',
      optionsEn: ['Apollo 13', 'Mars Rover', 'Apollo 11', 'Gemini'],
      optionsAr: ['أبولو 13', 'مركبة المريخ', 'أبولو 11', 'جيميني'],
      correctAnswerIndex: 2,
    ),
  ];

  static List<QuizQuestion> getAllQuestions() => questions;

  // -------------------------
  // Events
  // -------------------------
  static final List<MockEvent> events = [
    MockEvent(
      title: 'Guided Tour: Ancient Egypt Highlights',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      location: 'Main Entrance',
      description: 'A 45-min guided tour covering the most iconic artifacts.',
    ),
    MockEvent(
      title: 'Kids Workshop: Build a Pyramid',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      location: 'Education Hall',
      description: 'Interactive workshop for kids (ages 7–12).',
    ),
    MockEvent(
      title: 'Talk: Secrets of Mummification',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 1)),
      location: 'Auditorium',
      description: 'A short talk + Q&A with a museum specialist.',
    ),
  ];

  // -------------------------
  // Achievements
  // -------------------------
  static final List<MockBadge> badges = [
    MockBadge(
      id: 'b1',
      title: 'First Steps',
      description: 'Complete your first tour.',
      requiredValue: 1,
      statKey: 'tours',
    ),
    MockBadge(
      id: 'b2',
      title: 'Quiz Rookie',
      description: 'Complete 3 quizzes.',
      requiredValue: 3,
      statKey: 'quizzes',
    ),
    MockBadge(
      id: 'b3',
      title: 'Explorer',
      description: 'Visit 5 exhibits.',
      requiredValue: 5,
      statKey: 'exhibits',
    ),
    MockBadge(
      id: 'b4',
      title: 'Pro Guide',
      description: 'Complete 5 tours.',
      requiredValue: 5,
      statKey: 'tours',
    ),
  ];
}

/// Keep these simple models here for now (no backend yet).
class MockEvent {
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;

  MockEvent({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
  });
}

class MockBadge {
  final String id;
  final String title;
  final String description;
  final int requiredValue;
  final String statKey; // "tours" or "quizzes" or "exhibits"

  MockBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredValue,
    required this.statKey,
  });
}
