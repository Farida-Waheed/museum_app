// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'حوروس';

  @override
  String get exploreEgypt => 'استكشف مصر مع حوروس';

  @override
  String nextStop(String location, int time) {
    return 'المحطة التالية: $location خلال $time دقائق';
  }

  @override
  String get exhibits => 'المعروضات';

  @override
  String get visited => 'تمت زيارتها';

  @override
  String get duration => 'المدة';

  @override
  String get todaysHighlights => 'معروضات اليوم';

  @override
  String get mapPreview => 'معاينة الخريطة (موقع حوروس)';

  @override
  String get fullView => 'عرض كامل';

  @override
  String get horusBot => 'حوروس';

  @override
  String get you => 'أنت';

  @override
  String get exhibit => 'معروض';

  @override
  String get guestUser => 'زائر';

  @override
  String get exploreMuseum => 'استكشف المتحف';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get map => 'الخريطة';

  @override
  String get quiz => 'الاختبار';

  @override
  String get liveTour => 'جولة حية';

  @override
  String get tourPlanner => 'مخطط الجولة';

  @override
  String get events => 'الفعاليات';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get language => 'اللغة';

  @override
  String get accessibility => 'إمكانية الوصول';

  @override
  String get feedback => 'الملاحظات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get privacyPermissions => 'الخصوصية والأذونات';

  @override
  String get privacyText =>
      'حوروس يستخدم البلوتوث والموقع لمرافقتك داخل المتحف.\n\n• البيانات مجهولة الهوية.\n• تُستخدم خرائط الحركة لأغراض التحليل فقط.\n\nهل تسمح باستخدام موقعك؟';

  @override
  String get deny => 'رفض';

  @override
  String get allow => 'سماح';

  @override
  String get mainGallery => 'المعرض الرئيسي';

  @override
  String get comfortableApp => 'اجعل التطبيق مريحاً لك';

  @override
  String get adjustSettings =>
      'عدّل حجم الخط والتباين واللغة لتناسب احتياجاتك.';

  @override
  String get displayText => 'العرض والنص';

  @override
  String get highContrast => 'وضع تباين عالٍ';

  @override
  String get highContrastSubtitle =>
      'زيادة وضوح الألوان والعناصر للنظر الضعيف أو الإضاءة المنخفضة.';

  @override
  String get appearanceMode => 'وضع المظهر';

  @override
  String get system => 'حسب النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get textSize => 'حجم النص';

  @override
  String get smaller => 'أصغر';

  @override
  String get larger => 'أكبر';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get appLanguageSubtitle =>
      'اختر اللغة المفضلة لواجهة التطبيق والمحتوى.';

  @override
  String get saveNote => 'يتم حفظ هذه الإعدادات على هذا الجهاز فقط.';

  @override
  String get settingsAccessibility => 'الإعدادات وإمكانية الوصول';

  @override
  String get done => 'تم';

  @override
  String get scanAnother => 'مسح آخر';

  @override
  String get ticketVerified => 'تم التحقق من التذكرة';

  @override
  String get invalidQr => 'رمز QR غير صالح';

  @override
  String get scanTicket => 'مسح التذكرة';

  @override
  String get alignQr => 'ضع رمز QR داخل الإطار';

  @override
  String get audioGuide => 'الشرح الصوتي';

  @override
  String get audioPlaying => 'يتم تشغيل الشرح الصوتي...';

  @override
  String get audioNarration => 'اضغط للاستماع إلى شرح قصير.';

  @override
  String get addedToBookmarks => 'تمت إضافة المعروض إلى قائمتك.';

  @override
  String get removedFromBookmarks => 'تمت إزالة المعروض من قائمتك.';

  @override
  String get description => 'الوصف';

  @override
  String get origin => 'الأصل';

  @override
  String get period => 'الفترة';

  @override
  String get gallery => 'المعرض';

  @override
  String get addToMyRoute => 'أضف إلى مساري';

  @override
  String get viewOnMap => 'عرض على الخريطة';

  @override
  String get addedToRoute => 'أُضيفت هذه القطعة إلى مسارك.';

  @override
  String get openingMap => 'فتح الخريطة في قاعة هذه القطعة.';

  @override
  String get live => 'مباشر';

  @override
  String get robotDescribing => 'الروبوت يشرح هذه القطعة الآن.';

  @override
  String get liveTranscript => 'النص المباشر';

  @override
  String get accessibilityMuteNote =>
      'يمكنك إيقاف الصوت والاعتماد على النص في أي وقت.';

  @override
  String get guidedMode => 'الوضع الموجه';

  @override
  String get selfPacedMode => 'الوضع الذاتي';

  @override
  String get currentStop => 'المحطة الحالية';

  @override
  String get nextStopLabel => 'المحطة التالية';

  @override
  String get previousStop => 'المحطة السابقة';

  @override
  String get tourProgress => 'تقدم الجولة';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get skip => 'تخطي';

  @override
  String get robotWaiting => 'الروبوت ينتظرك في المحطة التالية.';

  @override
  String get robotMoving => 'الروبوت ينتقل إلى المعروض التالي.';

  @override
  String get connectionLost => 'فقد الاتصال. جاري إعادة الاتصال...';

  @override
  String get myJourney => 'رحلتي';

  @override
  String get exhibitsFound => 'المعروضات المكتشفة';

  @override
  String get factsDiscovered => 'الحقائق المكتشفة';

  @override
  String get takeQuickQuiz => 'أجب على اختبار سريع حول هذا المعروض!';

  @override
  String get startQuiz => 'بدء الاختبار';

  @override
  String get visitSummary => 'ملخص الزيارة';

  @override
  String get endTour => 'إنهاء الجولة';

  @override
  String get congrats => 'تهانينا!';

  @override
  String get visitComplete => 'لقد أكملت رحلتك في المتحف.';

  @override
  String get exhibitsVisited => 'المعروضات التي زرتها';

  @override
  String get totalTime => 'الوقت الإجمالي';

  @override
  String get shareVisit => 'مشاركة زيارتي';

  @override
  String get pioneer => 'المستكشف الأول';

  @override
  String get pioneerDesc => 'زيارة أول معروض لك';

  @override
  String get scholar => 'الباحث';

  @override
  String get scholarDesc => 'اكتشاف 5 حقائق';

  @override
  String get wayfinder => 'مرشد الطريق';

  @override
  String get wayfinderDesc => 'إكمال جولة في جناح كامل';

  @override
  String get happeningNow => 'يحدث الآن';

  @override
  String get noEvents => 'لا توجد فعاليات حية حالياً.';

  @override
  String get upcomingEvents => 'الفعاليات القادمة';

  @override
  String get workshop => 'ورشة عمل: الهيروغليفية ١٠١';

  @override
  String get workshopDesc => 'تبدأ خلال ٢٠ دقيقة في القاعة ج';

  @override
  String get talk => 'محاضرة: الملك الطفل';

  @override
  String get talkDesc => 'تبدأ في الساعة ٢:٠٠ ظهراً في المسرح الرئيسي';

  @override
  String get home => 'الرئيسية';

  @override
  String get tour => 'الجولة';

  @override
  String get tickets => 'التذاكر';
}
