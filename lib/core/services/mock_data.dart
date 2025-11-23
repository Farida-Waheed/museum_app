import '../../models/exhibit.dart';

class MockDataService {
  static final List<Exhibit> exhibits = [
    Exhibit(
      id: '1',
      nameEn: 'Ancient Vase',
      nameAr: 'مزهرية قديمة',
      descriptionEn: 'A rare Greek vase from 300 BC, depicting the battle of Troy.',
      descriptionAr: 'مزهرية يونانية نادرة من عام 300 قبل الميلاد تصور معركة طروادة.',
      imageAsset: 'assets/images/vase.png', // We will handle missing images later
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

  static List<Exhibit> getAllExhibits() {
    return exhibits;
  }
  
  static Exhibit getExhibitById(String id) {
    return exhibits.firstWhere((e) => e.id == id, orElse: () => exhibits[0]);
  }
}