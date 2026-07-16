import 'package:flutter/widgets.dart';

import '../enums/accessibility_enums.dart';

/// Self-contained bilingual (en/ar) string table for the Accessibility module.
///
/// Why a module-local table instead of the app's generated `AppLocalizations`?
/// * Keeps the module fully self-contained (module spec #1) — it can be lifted
///   into another app or the website dashboard without ARB wiring.
/// * Adds zero new keys to the shared ARB files, so it never forces a
///   `flutter gen-l10n` regeneration or risks colliding with app strings.
///
/// It follows the SAME language source of truth as the rest of the app: the
/// active `Locale` (Arabic when languageCode == 'ar'), so switching the app
/// language switches these strings too. RTL is handled by the app's global
/// `Directionality` (see app.dart) exactly as every other screen.
///
/// Resolve with `AccessibilityL10n.of(context)`.
class AccessibilityL10n {
  final bool isAr;
  const AccessibilityL10n(this.isAr);

  static AccessibilityL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AccessibilityL10n(code == 'ar');
  }

  String _s(String en, String ar) => isAr ? ar : en;

  // --- Wizard: chrome ---
  String get skip => _s('Skip', 'تخطٍّ');
  String get back => _s('Back', 'رجوع');
  String get next => _s('Next', 'التالي');
  String get finish => _s('Finish', 'إنهاء');
  String get saving => _s('Saving…', 'جارٍ الحفظ…');

  // --- Step 1: welcome ---
  String get welcomeTitle => _s('Welcome to Horus', 'مرحباً بك في حورس');
  String get welcomeBody => _s(
        'Before we begin your museum journey, let’s personalize your '
            'experience so Horus can assist you in the best possible way.',
        'قبل أن نبدأ رحلتك في المتحف، دعنا نخصّص تجربتك حتى يتمكن حورس من '
            'مساعدتك بأفضل شكل ممكن.',
      );
  String get welcomeReassurance => _s(
        'It takes less than a minute, and you can change anything later.',
        'لن يستغرق الأمر سوى أقل من دقيقة، ويمكنك تغيير أي شيء لاحقاً.',
      );
  String get letsBegin => _s('Let’s begin', 'لنبدأ');

  // --- Step 2/3: needs ---
  String get needsTitle =>
      _s('How would you like Horus to assist you?', 'كيف تودّ أن يساعدك حورس؟');
  String get needsSubtitle => _s(
        'Choose everything that applies. You can select more than one.',
        'اختر كل ما ينطبق عليك. يمكنك اختيار أكثر من خيار.',
      );

  // --- Step 4: preferences ---
  String get preferencesTitle =>
      _s('Personalize your preferences', 'خصّص تفضيلاتك');
  String get preferencesSubtitle => _s(
        'We’ve set sensible defaults from your choices. Fine-tune anything — '
            'or skip and do it later.',
        'لقد اخترنا إعدادات مناسبة بناءً على اختياراتك. عدّل ما تشاء، أو تخطَّ '
            'وقم بذلك لاحقاً.',
      );

  // --- Step 5: preview ---
  String get previewTitle => _s('Here’s your experience', 'إليك تجربتك');
  String get previewSubtitle => _s(
        'This is how Horus will look and feel for you.',
        'هكذا سيبدو حورس ويتفاعل معك.',
      );
  String get previewSampleHeading => _s('Sample exhibit', 'مثال لمعروضة');
  String get previewSampleBody => _s(
        'The golden mask of Tutankhamun is one of the museum’s most treasured '
            'artifacts, crafted over 3,000 years ago.',
        'قناع توت عنخ آمون الذهبي هو أحد أثمن مقتنيات المتحف، صُنع قبل أكثر من '
            '٣٠٠٠ عام.',
      );

  // --- Step 6: finish ---
  String get finishTitle => _s('You’re all set', 'أصبح كل شيء جاهزاً');
  String get finishBody => _s(
        'Horus now understands how to assist you. Enjoy your visit.',
        'يفهم حورس الآن كيفية مساعدتك. نتمنى لك زيارة ممتعة.',
      );
  String get openHome => _s('Enter the museum', 'ادخل المتحف');

  // --- Profile page ---
  String get profileTitle => _s('Accessibility Profile', 'ملف الوصول');
  String get activeNeeds => _s('Active needs', 'الاحتياجات المفعّلة');
  String get noActiveNeeds =>
      _s('Standard experience', 'التجربة القياسية');
  String get editSelection => _s('Edit selection', 'تعديل الاختيار');
  String get resetProfile => _s('Reset to standard', 'إعادة التعيين للقياسي');
  String get exportProfile => _s('Export settings', 'تصدير الإعدادات');
  String get resetConfirmTitle =>
      _s('Reset accessibility profile?', 'إعادة تعيين ملف الوصول؟');
  String get resetConfirmBody => _s(
        'This returns all accessibility preferences to the standard experience. '
            'You can set them up again anytime.',
        'سيؤدي هذا إلى إعادة جميع تفضيلات الوصول إلى التجربة القياسية. يمكنك '
            'إعدادها مرة أخرى في أي وقت.',
      );
  String get cancel => _s('Cancel', 'إلغاء');
  String get reset => _s('Reset', 'إعادة تعيين');
  String get syncedToAccount =>
      _s('Synced to your account', 'متزامن مع حسابك');
  String get savedOnDevice =>
      _s('Saved on this device', 'محفوظ على هذا الجهاز');
  String get willSyncWhenOnline =>
      _s('Will sync when back online', 'ستتم المزامنة عند عودة الاتصال');

  // --- Section headers (preferences) ---
  String get sectionDisplay => _s('Display', 'العرض');
  String get sectionVoice => _s('Voice', 'الصوت');
  String get sectionNavigation => _s('Navigation', 'التنقّل');
  String get sectionInteraction => _s('Interaction', 'التفاعل');
  String get sectionTour => _s('Tour', 'الجولة');

  // --- Display controls ---
  String get textSize => _s('Text size', 'حجم النص');
  String get highContrast => _s('High contrast', 'تباين عالٍ');
  String get boldText => _s('Bold text', 'نص عريض');
  String get reduceMotion => _s('Reduce motion', 'تقليل الحركة');
  String get largeButtons => _s('Large buttons', 'أزرار كبيرة');

  // --- Voice controls ---
  String get voiceGuidance => _s('Voice guidance', 'الإرشاد الصوتي');
  String get audioDescription => _s('Audio description', 'الوصف الصوتي');
  String get speechSpeed => _s('Speech speed', 'سرعة النطق');

  // --- Navigation controls ---
  String get stepFreeRoutes =>
      _s('Step-free routes', 'مسارات خالية من الدرَج');
  String get moreRestPoints =>
      _s('More rest points', 'نقاط استراحة أكثر');
  String get announceDirections =>
      _s('Announce directions', 'الإعلان عن الاتجاهات');

  // --- Interaction controls ---
  String get liveCaptions => _s('Live captions', 'ترجمة حيّة');
  String get hapticFeedback => _s('Haptic feedback', 'اهتزاز عند اللمس');
  String get extendedTimeouts =>
      _s('Extra time for actions', 'وقت إضافي للإجراءات');

  // --- Tour controls ---
  String get pace => _s('Pace', 'الإيقاع');
  String get explanationDetail =>
      _s('Explanation detail', 'مستوى تفصيل الشرح');

  // --- Value labels ---
  String speechRateLabel(SpeechRate r) => switch (r) {
        SpeechRate.slow => _s('Slow', 'بطيء'),
        SpeechRate.normal => _s('Normal', 'عادي'),
        SpeechRate.fast => _s('Fast', 'سريع'),
      };

  String paceLabel(TourPace p) => switch (p) {
        TourPace.relaxed => _s('Relaxed', 'مريح'),
        TourPace.standard => _s('Standard', 'قياسي'),
        TourPace.brisk => _s('Brisk', 'سريع'),
      };

  String explanationLabel(ExplanationLevel e) => switch (e) {
        ExplanationLevel.simple => _s('Simple', 'مبسّط'),
        ExplanationLevel.standard => _s('Standard', 'قياسي'),
        ExplanationLevel.detailed => _s('Detailed', 'مفصّل'),
      };

  // --- Home banner ---
  String get profileActive =>
      _s('Accessibility profile active', 'ملف الوصول مفعّل');
  String get personalizeAccessibility =>
      _s('Personalize accessibility', 'تخصيص إمكانية الوصول');
  String get readyVoiceNavigation =>
      _s('Voice navigation ready', 'التنقّل الصوتي جاهز');
  String get readyLiveCaptions => _s('Live captions ready', 'الترجمة الحية جاهزة');
  String get readyAccessibleRoute =>
      _s('Accessible route enabled', 'المسار الميسّر مفعّل');
  String get readyAudioDescription =>
      _s('Audio description ready', 'الوصف الصوتي جاهز');
  String get readySimpleMode =>
      _s('Simple explanations on', 'الشرح المبسّط مفعّل');

  String greeting(String name) => name.trim().isEmpty
      ? _s('Welcome back', 'مرحباً بعودتك')
      : _s('Welcome back, $name', 'مرحباً بعودتك، $name');
}
