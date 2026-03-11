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
      nameEn: 'Grand Hall / Tutankhamun Hall',
      nameAr: 'القاعة الكبرى / قاعة توت عنخ آمون',
      descriptionEn:
          'This hall contains the world-famous treasures of Tutankhamun, discovered in 1922.',
      descriptionAr:
          'تحتوي هذه القاعة على كنوز توت عنخ آمون المشهورة عالمياً، والتي تم اكتشافها في عام 1922.',
      imageAsset: 'assets/images/Grand Hall.jpg',
      x: 100.0,
      y: 120.0,
    ),
    Exhibit(
      id: '2',
      nameEn: 'Colossal Seated Statues',
      nameAr: 'التماثيل الجالسة الضخمة',
      descriptionEn:
          'Massive statues representing Pharaohs from the New Kingdom era.',
      descriptionAr: 'تماثيل ضخمة تمثل الفراعنة من عصر الدولة الحديثة.',
      imageAsset: 'assets/images/Colossal Seated Statues.jpg',
      x: 250.0,
      y: 280.0,
    ),
    Exhibit(
      id: '3',
      nameEn: 'Gold-Covered Sandals',
      nameAr: 'صندل مغطى بالذهب',
      descriptionEn: 'Exquisite sandals belonging to a Pharaoh, covered in pure gold leaf.',
      descriptionAr: 'صندل رائع يخص أحد الفراعنة، مغطى بورق الذهب الخالص.',
      imageAsset: 'assets/images/Gold-Covered Sandals.jpg',
      x: 400.0,
      y: 150.0,
    ),
    Exhibit(
      id: '4',
      nameEn: 'Canopic Jars',
      nameAr: 'الأواني الكانوبية',
      descriptionEn: 'Used during the mummification process to store internal organs.',
      descriptionAr: 'استخدمت خلال عملية التحنيط لتخزين الأعضاء الداخلية.',
      imageAsset: 'assets/images/canopic_jars.jpg',
      x: 150.0,
      y: 450.0,
    ),
    Exhibit(
      id: '5',
      nameEn: 'Hieroglyphic Wall',
      nameAr: 'جدار هيروغليفي',
      descriptionEn: 'A section of a temple wall featuring intricate hieroglyphic inscriptions.',
      descriptionAr: 'جزء من جدار معبد يتميز بنقوش هيروغليفية معقدة.',
      imageAsset: 'assets/images/hieroglyphs.jpg',
      x: 480.0,
      y: 380.0,
    ),
  ];

  static List<Exhibit> getAllExhibits() => exhibits;

  static List<MockEvent> getAllEvents() => events;

  /// Planner tags without modifying Exhibit model:
  /// Map exhibitId -> tags
  static final Map<String, List<String>> exhibitTags = {
    '1': ['History', 'Highlights'],
    '2': ['History', 'Statues'],
    '3': ['Highlights', 'History'],
    '4': ['History', 'Mummies'],
    '5': ['History', 'Statues'],
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
      questionEn: 'In what year was Tutankhamun\'s tomb discovered?',
      questionAr: 'في أي عام تم اكتشاف مقبرة توت عنخ آمون؟',
      optionsEn: ['1900', '1922', '1950', '1890'],
      optionsAr: ['1900', '1922', '1950', '1890'],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      id: 'q2',
      questionEn: 'What were Canopic Jars used for?',
      questionAr: 'فيما كانت تستخدم الأواني الكانوبية؟',
      optionsEn: ['Drinking water', 'Storing organs', 'Cooking food', 'Storing jewelry'],
      optionsAr: ['شرب الماء', 'تخزين الأعضاء', 'طهي الطعام', 'تخزين المجوهرات'],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      id: 'q3',
      questionEn: 'What is the material used to cover the royal sandals?',
      questionAr: 'ما هي المادة المستخدمة لتغطية الصنادل الملكية؟',
      optionsEn: ['Silver', 'Bronze', 'Gold', 'Iron'],
      optionsAr: ['الفضة', 'البرونز', 'الذهب', 'الحديد'],
      correctAnswerIndex: 2,
    ),
  ];

  static List<QuizQuestion> getAllQuestions() => questions;

  // -------------------------
  // Museum News
  // -------------------------
  static final List<MockNews> news = [
    MockNews(
      title: "New Discovery in Saqqara",
      description: "Archaeologists have uncovered a well-preserved tomb from the Old Kingdom era.",
      image: "assets/images/Onboarding.jpg",
      source: "National Geographic",
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockNews(
      title: "Digital Preservation of Artifacts",
      description: "The museum starts a new initiative to scan all artifacts in 3D.",
      image: "assets/images/Grand Hall.jpg",
      source: "UNESCO",
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<MockNews> getAllNews() => news;

  // -------------------------
  // Events (Happening Now / Today focus)
  // -------------------------
  static final List<MockEvent> events = [
    MockEvent(
      titleEn: 'LIVE: Ancient Egypt Highlights Tour',
      titleAr: 'مباشر: جولة أبرز معالم مصر القديمة',
      dateTime: DateTime.now().add(const Duration(minutes: 15)),
      locationEn: 'Main Entrance Hall',
      locationAr: 'ردهة المدخل الرئيسي',
      descriptionEn: 'A live guided tour led by Horus-Bot and a museum specialist.',
      descriptionAr: 'جولة إرشادية حية بقيادة حوروس-بوت وأخصائي متحف.',
      isLive: true,
    ),
    MockEvent(
      titleEn: 'Kids Workshop: Scribe School',
      titleAr: 'ورشة أطفال: مدرسة الكاتب',
      dateTime: DateTime.now().add(const Duration(hours: 1)),
      locationEn: 'Education Wing',
      locationAr: 'جناح التعليم',
      descriptionEn: 'Learn how to write your name in hieroglyphs!',
      descriptionAr: 'تعلم كيف تكتب اسمك بالهيروغليفية!',
      isLive: false,
    ),
    MockEvent(
      titleEn: 'Curator Talk: Tutankhamun\'s Secrets',
      titleAr: 'حديث المنسق: أسرار توت عنخ آمون',
      dateTime: DateTime.now().add(const Duration(hours: 3)),
      locationEn: 'Auditorium',
      locationAr: 'الأوديتوريوم',
      descriptionEn: 'Deep dive into the latest findings from the Valley of the Kings.',
      descriptionAr: 'غوص عميق في أحدث النتائج من وادي الملوك.',
      isLive: false,
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
  final String titleEn;
  final String titleAr;
  final DateTime dateTime;
  final String locationEn;
  final String locationAr;
  final String descriptionEn;
  final String descriptionAr;
  final bool isLive;

  MockEvent({
    required this.titleEn,
    required this.titleAr,
    required this.dateTime,
    required this.locationEn,
    required this.locationAr,
    required this.descriptionEn,
    required this.descriptionAr,
    this.isLive = false,
  });

  String getTitle(String lang) => lang == 'ar' ? titleAr : titleEn;
  String getLocation(String lang) => lang == 'ar' ? locationAr : locationEn;
  String getDescription(String lang) => lang == 'ar' ? descriptionAr : descriptionEn;
}

class MockNews {
  final String title;
  final String description;
  final String image;
  final String source;
  final DateTime date;

  MockNews({
    required this.title,
    required this.description,
    required this.image,
    required this.source,
    required this.date,
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
