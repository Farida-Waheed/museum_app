import '../../models/exhibit.dart';
import '../../models/exhibit_content.dart';
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
      contents: [
        ExhibitContent(
          id: 'gem_ramses2_colossus_overview_en_001',
          title: 'Colossal Statue of Ramesses II – Overview',
          type: 'overview',
          tags: ['Ramesses II', 'colossal statue', 'New Kingdom', 'pharaoh', 'royal sculpture'],
          text: 'This colossal red granite statue of Ramesses II stands over 11 meters tall and depicts the king in a powerful striding pose. Carved at his legs are figures of his children, including Khaemwaset and Bintanath, emphasizing royal lineage and continuity. The statue’s scale and carefully proportioned form were designed to project authority, strength, and divine kingship.',
        ),
        ExhibitContent(
          id: 'gem_ramses2_colossus_details_en_002',
          title: 'Colossal Statue of Ramesses II – Artistic Details',
          type: 'details',
          tags: ['granite', 'hieroglyphs', 'royal children', 'Egyptian art'],
          text: 'The statue is carved from red granite and features finely worked proportions and hieroglyphic inscriptions. The inclusion of royal children at the king’s legs reinforces Ramesses II’s role as both ruler and father of the dynasty. Hieroglyphs carved on the statue link the king to the gods, highlighting his divine legitimacy.',
        ),
        ExhibitContent(
          id: 'gem_ramses2_colossus_function_en_003',
          title: 'Colossal Statue of Ramesses II – Function and Worship',
          type: 'significance',
          tags: ['Temple of Ptah', 'Memphis', 'divine kingship', 'worship'],
          text: 'Originally placed outside the Temple of Ptah at Memphis, the statue functioned as a divine intermediary between the king and the gods. Ancient Egyptians venerated Ramesses II as a living god, offering prayers and offerings at monumental statues like this one. Such statues reinforced the belief that the pharaoh upheld cosmic order through divine favor.',
        ),
        ExhibitContent(
          id: 'gem_ramses2_colossus_history_en_004',
          title: 'Colossal Statue of Ramesses II – Historical Background',
          type: 'historical_background',
          tags: ['Ramesses the Great', 'New Kingdom history', 'royal ideology'],
          text: 'Ramesses II, often called Ramesses the Great, ruled Egypt during a long and prosperous reign marked by extensive building projects and military campaigns. His monuments across Egypt promoted an ideal image of kingship centered on power, stability, and divine support. This colossal statue reflects how royal imagery shaped political and religious life during the New Kingdom.',
        ),
        ExhibitContent(
          id: 'gem_ramses2_colossus_relocation_en_005',
          title: 'Colossal Statue of Ramesses II – Modern History',
          type: 'historical_background',
          tags: ['heritage preservation', 'Cairo', 'museum relocation'],
          text: 'After its excavation, the statue was displayed in Cairo’s central square before being carefully relocated to the Grand Egyptian Museum. This journey reflects modern efforts to preserve and present Egypt’s ancient heritage. Today, the statue stands as a bridge between ancient reverence for the king and contemporary museum conservation.',
        ),
        ExhibitContent(
          id: 'gem_ramses2_colossus_faq_en_006',
          title: 'Colossal Statue of Ramesses II – Common Questions',
          type: 'faq',
          tags: ['visitor questions', 'royal statues'],
          text: 'Q: Why is the statue so large? A: Its colossal size was meant to emphasize the pharaoh’s power and divine status. Q: Why are children carved at his legs? A: They represent royal lineage and the continuation of the dynasty. Q: Where did the statue originally stand? A: Outside the Temple of Ptah in Memphis.',
        ),
      ],
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
      contents: [
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_overview_en_001',
          title: 'Colossus of a Ptolemaic King – Overview',
          type: 'overview',
          tags: ['Ptolemaic', 'colossal statue', 'pharaoh', 'granite', 'Thonis-Heracleion'],
          text: 'This granite colossus, over 5 meters high, depicts a Ptolemaic king dressed in traditional pharaonic regalia. He wears the double crown and a kilt, and his clenched right fist likely once held a royal insignia. Although the ruler was Greek by origin, the statue presents him as an Egyptian pharaoh to communicate legitimacy and authority.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_details_en_002',
          title: 'Colossus of a Ptolemaic King – Artistic Features',
          type: 'details',
          tags: ['double crown', 'pharaonic regalia', 'Greek-Egyptian style', 'royal iconography'],
          text: 'The statue blends Egyptian royal iconography—such as the double crown and formal stance—with stylistic choices associated with the Ptolemaic period. This fusion reflects how Ptolemaic rulers adopted Egyptian visual language to rule effectively, while still operating within a broader Hellenistic world.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_context_en_003',
          title: 'Colossus of a Ptolemaic King – Original Setting',
          type: 'significance',
          tags: ['Amun-Gereb', 'temple entrance', 'guardianship', 'sacred precinct'],
          text: 'The colossus originally stood outside the temple of Amun-Gereb, where monumental statues helped define and protect sacred space. Positioned at or near a temple entrance, it presented the king as guardian of the gods’ precincts and a legitimate participant in Egyptian religious life.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_discovery_en_004',
          title: 'Colossus of a Ptolemaic King – Discovery at Thonis-Heracleion',
          type: 'historical_background',
          tags: ['underwater archaeology', 'submerged city', 'Thonis-Heracleion', 'rediscovery'],
          text: 'The statue was discovered submerged in the lost city of Thonis-Heracleion. Its survival underwater and modern recovery highlight the importance of underwater archaeology in revealing Egypt’s coastal and maritime history, including cities that once connected Egypt to Mediterranean trade and travel.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_history_en_005',
          title: 'Colossus of a Ptolemaic King – Historical Background',
          type: 'historical_background',
          tags: ['Ptolemies', 'Alexander the Great', 'Hellenistic Egypt', 'dynastic legitimacy'],
          text: 'The Ptolemies ruled Egypt after the conquests of Alexander the Great, combining Hellenistic governance with Egyptian religious and political traditions. Statues like this one show how foreign-origin rulers used Egyptian forms to claim continuity with earlier pharaohs. The Thonis-Heracleion site also reflects a Mediterranean world where Egyptian, Greek, and other cultures interacted closely.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_king_colossus_faq_en_006',
          title: 'Colossus of a Ptolemaic King – Common Questions',
          type: 'faq',
          tags: ['visitor questions', 'Ptolemaic rulers', 'Egyptian kingship'],
          text: 'Q: Why does a Greek ruler appear as an Egyptian pharaoh? A: Ptolemaic kings adopted Egyptian royal imagery to strengthen legitimacy. Q: Where was it found? A: In the submerged city of Thonis-Heracleion. Q: What was it used for? A: It marked royal presence and protected the sacred temple area.',
        ),
      ],
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
      contents: [
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_overview_en_001',
          title: 'Colossus of a Ptolemaic Queen – Overview',
          type: 'overview',
          tags: ['Ptolemaic queen', 'colossal statue', 'Isis', 'Thonis-Heracleion', 'royal women'],
          text: 'This monumental statue represents a Ptolemaic queen, possibly Cleopatra II or Cleopatra III, and was recovered from the submerged city of Thonis-Heracleion. She is shown wearing a pleated dress and a distinctive crown associated with the goddess Isis. The statue presents the queen as both a royal figure and a divine embodiment.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_details_en_002',
          title: 'Colossus of a Ptolemaic Queen – Artistic Features',
          type: 'details',
          tags: ['Greek-Egyptian style', 'Isis crown', 'royal iconography', 'Ptolemaic art'],
          text: 'The queen’s features blend Greek naturalism with Egyptian idealization, reflecting the dual cultural identity of the Ptolemaic court. Her crown links her directly to Isis, reinforcing her divine status, while the formal stance and attire follow long-established Egyptian royal conventions.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_context_en_003',
          title: 'Colossus of a Ptolemaic Queen – Original Setting',
          type: 'significance',
          tags: ['temple entrance', 'royal pair', 'divine protection', 'Amun-Gereb'],
          text: 'The statue was intended to stand alongside the colossus of the Ptolemaic king at the entrance to a temple, likely that of Amun-Gereb. Together, the pair presented a unified image of royal and divine authority, protecting the sacred precinct and reinforcing dynastic legitimacy.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_discovery_en_004',
          title: 'Colossus of a Ptolemaic Queen – Discovery and Recovery',
          type: 'historical_background',
          tags: ['underwater archaeology', 'submerged city', 'Thonis-Heracleion', 'archaeological discovery'],
          text: 'Recovered from the sea at Thonis-Heracleion, the statue highlights the achievements of modern underwater archaeology. Its preservation underwater and subsequent excavation have contributed significantly to understanding Egypt’s submerged heritage and coastal religious centers.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_history_en_005',
          title: 'Colossus of a Ptolemaic Queen – Historical Background',
          type: 'historical_background',
          tags: ['Ptolemaic queens', 'Isis cult', 'female power', 'Hellenistic Egypt'],
          text: 'Ptolemaic queens were influential figures in political and religious life, often revered as living manifestations of Isis. By presenting themselves as both rulers and goddesses, they secured legitimacy among Egyptian and Greek subjects alike. This statue reflects how female power and divine identity were central to Ptolemaic kingship.',
        ),
        ExhibitContent(
          id: 'gem_ptolemaic_queen_colossus_faq_en_006',
          title: 'Colossus of a Ptolemaic Queen – Common Questions',
          type: 'faq',
          tags: ['visitor questions', 'Ptolemaic queens', 'Isis symbolism'],
          text: 'Q: Which queen does the statue represent? A: It may depict Cleopatra II or Cleopatra III, though the exact identity is uncertain. Q: Why is the queen associated with Isis? A: Ptolemaic queens were often identified with Isis to emphasize divine legitimacy. Q: Where was it found? A: In the submerged city of Thonis-Heracleion.',
        ),
      ],
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
      contents: [
        ExhibitContent(
          id: 'gem_anubis_chest_overview_en_001',
          title: 'Anubis on a Chest – Overview',
          type: 'overview',
          tags: ['Anubis', 'Tutankhamun', 'funerary objects', 'guardian deity', 'New Kingdom'],
          text: 'This pylon-shaped chest was found at the entrance to Tutankhamun’s Treasury and is topped by a black and gold figure of Anubis in jackal form. Mounted on a gilded wooden sledge, the chest served as a protective shrine guarding ritual objects and jewelry belonging to the king.',
        ),
        ExhibitContent(
          id: 'gem_anubis_chest_details_en_002',
          title: 'Anubis on a Chest – Artistic and Physical Features',
          type: 'details',
          tags: ['jackal', 'gilded wood', 'pylon shape', 'Egyptian craftsmanship'],
          text: 'The chest is shaped like a pylon, echoing temple architecture, and rests on a gilded wooden sledge. The figure of Anubis is painted black, a color associated with rebirth and the fertile soil of the Nile, and highlighted with gold details. Inside the chest were compartments containing wrapped ritual items and jewelry.',
        ),
        ExhibitContent(
          id: 'gem_anubis_chest_function_en_003',
          title: 'Anubis on a Chest – Function and Symbolism',
          type: 'significance',
          tags: ['mummification', 'afterlife', 'ritual protection', 'royal burial'],
          text: 'Anubis was the god of mummification and protector of the dead, making his presence essential in royal burials. Positioned at the entrance to the Treasury, the chest functioned as a sentinel guarding sacred equipment used in the king’s rebirth. Its imagery reinforced the belief that divine protection was required at every stage of the afterlife journey.',
        ),
        ExhibitContent(
          id: 'gem_anubis_chest_procession_en_004',
          title: 'Anubis on a Chest – Funerary Procession',
          type: 'historical_background',
          tags: ['funerary procession', 'royal rituals', 'Tutankhamun burial'],
          text: 'The chest’s placement on a sledge suggests it was originally used in Tutankhamun’s funerary procession before being installed inside the tomb. Such sledges allowed sacred objects to be ritually transported, emphasizing continuity between public funerary ceremonies and the sealed burial space.',
        ),
        ExhibitContent(
          id: 'gem_anubis_chest_history_en_005',
          title: 'Anubis on a Chest – Religious Context',
          type: 'historical_background',
          tags: ['post-Amarna period', 'funerary religion', 'divine guardianship'],
          text: 'Following the religious upheaval of the Amarna period, traditional gods like Anubis regained central importance in funerary belief. The presence of Anubis on this chest reflects the restored emphasis on divine guardianship, ritual precision, and ensuring the king’s safe passage to resurrection.',
        ),
        ExhibitContent(
          id: 'gem_anubis_chest_faq_en_006',
          title: 'Anubis on a Chest – Common Questions',
          type: 'faq',
          tags: ['visitor questions', 'Anubis symbolism', 'Tutankhamun tomb'],
          text: 'Q: Why is Anubis shown as a jackal? A: Jackals were associated with cemeteries and protection of the dead. Q: Why is the chest on a sledge? A: It was likely used in the funerary procession before burial. Q: What was kept inside? A: Ritual objects and jewelry used in the king’s afterlife rites.',
        ),
      ],
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
      contents: [
        ExhibitContent(
          id: 'gem_tut_golden_mask_overview_en_001',
          title: 'Golden Burial Mask of Tutankhamun – Overview',
          type: 'overview',
          tags: ['Tutankhamun', 'golden mask', 'Osiris', 'royal burial'],
          text: 'The Golden Burial Mask of Tutankhamun is one of the most famous objects from ancient Egypt. Made of solid gold, it was placed over the head and shoulders of the king’s mummy.',
        ),
        ExhibitContent(
          id: 'gem_tut_golden_mask_details_en_002',
          title: 'Golden Burial Mask – Materials and Craftsmanship',
          type: 'details',
          tags: ['gold', 'lapis lazuli', 'inlay', 'royal portrait'],
          text: 'The mask weighs over 10 kilograms and is inlaid with lapis lazuli, quartz, obsidian, and colored glass. It presents an idealized portrait of Tutankhamun with divine features.',
        ),
        ExhibitContent(
          id: 'gem_tut_golden_mask_function_en_003',
          title: 'Golden Burial Mask – Religious Meaning',
          type: 'significance',
          tags: ['Osiris', 'resurrection', 'Book of the Dead'],
          text: 'The mask identifies the king with Osiris and the sun god Re. Spells from the Book of the Dead inscribed inside protected the soul and ensured resurrection.',
        ),
        ExhibitContent(
          id: 'gem_tut_golden_mask_faq_en_004',
          title: 'Golden Burial Mask – Common Questions',
          type: 'faq',
          tags: ['visitor questions', 'gold symbolism', 'royal masks'],
          text: 'Q: Why gold? A: Gold symbolized divine flesh. Q: Why the cobra and vulture? A: They represent united Egypt. Q: Is this the king’s real face? A: It is an idealized likeness.',
        ),
      ],
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
