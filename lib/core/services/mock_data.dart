import '../../models/exhibit.dart';
import '../../models/quiz.dart'; // Import Quiz Model

class MockDataService {
  // --- Exhibits ---
  static final List<Exhibit> exhibits = [
    Exhibit(
      id: '1',
      nameEn: 'Ancient Vase',
      nameAr: 'مزهرية قديمة',
      descriptionEn: 'A rare Greek vase from 300 BC, depicting the battle of Troy.',
      descriptionAr: 'مزهرية يونانية نادرة من عام 300 قبل الميلاد تصور معركة طروادة.',
      imageAsset: 'assets/images/vase.png',
      x: 50.0,
      y: 100.0,
    ),
    Exhibit(
      id: '2',
      nameEn: 'Dinosaur Bone',
      nameAr: 'عظم ديناصور',
      descriptionEn: 'The femur bone of a Tyrannosaurus Rex discovered in 1995.',
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

  // --- Quiz Questions (NEW) ---
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
}