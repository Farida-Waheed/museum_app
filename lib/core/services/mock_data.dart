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
      id: 'gem_ramses2_colossus',
      nameEn: 'Colossal Statue of Ramesses II',
      nameAr: 'تمثال رمسيس الثاني الضخم',
      descriptionEn:
          'This colossal red granite statue of Ramesses II stands over 11 meters tall and depicts the king in a powerful striding pose.',
      descriptionAr:
          'هذا التمثال الضخم من الجرانيت الأحمر للملك رمسيس الثاني يزيد طوله عن 11 مترًا ويصور الملك في وضعية خطوة قوية.',
      imageAsset: 'assets/images/museum_interior.jpg',
      x: 100.0,
      y: 120.0,
    ),
    Exhibit(
      id: 'gem_ptolemaic_king_colossus',
      nameEn: 'Colossus of a Ptolemaic King',
      nameAr: 'تمثال ضخم لملك بطلمي',
      descriptionEn:
          'This granite colossus, over 5 meters high, depicts a Ptolemaic king dressed in traditional pharaonic regalia.',
      descriptionAr:
          'هذا التمثال الضخم من الجرانيت، الذي يزيد ارتفاعه عن 5 أمتار، يصور ملكًا بطلميًا يرتدي الملابس الفرعونية التقليدية.',
      imageAsset: 'assets/images/artifacts.jpg',
      x: 250.0,
      y: 280.0,
    ),
    Exhibit(
      id: 'gem_ptolemaic_queen_colossus',
      nameEn: 'Colossus of a Ptolemaic Queen',
      nameAr: 'تمثال ضخم لملكة بطلمية',
      descriptionEn:
          'This monumental statue represents a Ptolemaic queen, possibly Cleopatra II or Cleopatra III.',
      descriptionAr:
          'هذا التمثال الضخم يمثل ملكة بطلمية، ربما كليوباترا الثانية أو كليوباترا الثالثة.',
      imageAsset: 'assets/images/Black Granite Statue.jpg',
      x: 400.0,
      y: 150.0,
    ),
    Exhibit(
      id: 'gem_anubis_chest',
      nameEn: 'Anubis on a Chest',
      nameAr: 'أنوبيس على مقصورة',
      descriptionEn:
          'This pylon-shaped chest was found at the entrance to Tutankhamun’s Treasury.',
      descriptionAr:
          'عثر على هذه المقصورة التي تأخذ شكل الصرح عند مدخل غرفة الكنوز للملك توت عنخ آمون.',
      imageAsset: 'assets/images/Grand Hall.jpg',
      x: 150.0,
      y: 450.0,
    ),
    Exhibit(
      id: 'gem_tut_golden_mask',
      nameEn: 'Golden Burial Mask of Tutankhamun',
      nameAr: 'قناع دفن توت عنخ آمون الذهبي',
      descriptionEn:
          'The Golden Burial Mask of Tutankhamun is one of the most famous objects from ancient Egypt.',
      descriptionAr:
          'يعد قناع دفن توت عنخ آمون الذهبي أحد أشهر القطع الأثرية من مصر القديمة.',
      imageAsset: 'assets/images/pharaoh_head.jpg',
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
      exhibitId: 'gem_tut_golden_mask',
      exhibitNameEn: 'Golden Burial Mask of Tutankhamun',
      exhibitNameAr: 'قناع دفن توت عنخ آمون الذهبي',
      questionEn: 'In what year was Tutankhamun\'s tomb discovered?',
      questionAr: 'في أي عام تم اكتشاف مقبرة توت عنخ آمون؟',
      optionsEn: ['1900', '1922', '1950', '1890'],
      optionsAr: ['1900', '1922', '1950', '1890'],
      correctAnswerIndex: 1,
      explanationEn: 'The tomb was discovered in 1922 by Howard Carter.',
      explanationAr: 'تم اكتشاف المقبرة في عام 1922 بواسطة هوارد كارتر.',
    ),
    QuizQuestion(
      id: 'q2',
      exhibitId: 'gem_anubis_chest',
      exhibitNameEn: 'Anubis on a Chest',
      exhibitNameAr: 'أنوبيس على مقصورة',
      questionEn: 'What were Canopic Jars used for?',
      questionAr: 'فيما كانت تستخدم الأواني الكانوبية؟',
      optionsEn: [
        'Drinking water',
        'Storing organs',
        'Cooking food',
        'Storing jewelry',
      ],
      optionsAr: [
        'شرب الماء',
        'تخزين الأعضاء',
        'طهي الطعام',
        'تخزين المجوهرات',
      ],
      correctAnswerIndex: 1,
      explanationEn: 'Canopic jars held organs removed during mummification.',
      explanationAr:
          'كانت الأواني الكانوبية تحتفظ بالأعضاء التي أُزيلت أثناء التحنيط.',
    ),
    QuizQuestion(
      id: 'q3',
      exhibitId: 'gem_ramses2_colossus',
      exhibitNameEn: 'Colossal Statue of Ramesses II',
      exhibitNameAr: 'تمثال رمسيس الثاني الضخم',
      questionEn: 'What is the material used to cover the royal sandals?',
      questionAr: 'ما هي المادة المستخدمة لتغطية الصنادل الملكية؟',
      optionsEn: ['Silver', 'Bronze', 'Gold', 'Iron'],
      optionsAr: ['الفضة', 'البرونز', 'الذهب', 'الحديد'],
      correctAnswerIndex: 2,
      explanationEn:
          'Gold was a symbol of eternity and used to decorate royal items.',
      explanationAr: 'كان الذهب رمزًا للأبدية ويُستخدم لتزيين الأشياء الملكية.',
    ),
  ];

  static List<QuizQuestion> getAllQuestions() => questions;

  // -------------------------
  // Museum News (Mocked - Trusted Sources Only)
  // -------------------------
  static final List<MockNews> news = [
    MockNews(
      title: "Grand Egyptian Museum Opening Extended Hours Announced",
      description:
          "The museum will now offer evening visits on Fridays and Saturdays to accommodate more visitors from around the world.",
      image: "assets/images/Onboarding.jpg",
      source: "Grand Egyptian Museum Official",
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MockNews(
      title: "UNESCO Recognizes GEM's Digital Preservation Efforts",
      description:
          "The Grand Egyptian Museum receives commendation for its innovative 3D scanning project to preserve ancient artifacts digitally.",
      image: "assets/images/Grand Hall.jpg",
      source: "UNESCO Heritage News",
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
      descriptionEn:
          'A live guided tour led by Horus-Bot and a museum specialist.',
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
      descriptionEn:
          'Deep dive into the latest findings from the Valley of the Kings.',
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
  String getDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;
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
