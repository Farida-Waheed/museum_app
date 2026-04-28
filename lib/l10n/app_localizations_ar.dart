// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'حوروس-بوت';

  @override
  String get exploreEgypt => 'استكشف مصر مع حورس-بوت';

  @override
  String nextStop(Object location, Object time) {
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
  String get mapPreview => 'معاينة الخريطة';

  @override
  String get fullView => 'عرض كامل';

  @override
  String get horusBot => 'حوروس-بوت';

  @override
  String get talkToHorusBot => 'اسأل الدليل';

  @override
  String get askTheGuide => 'اسأل الدليل';

  @override
  String get guideStatus => 'حالة الدليل';

  @override
  String get alwaysAvailable => 'متاح دائماً';

  @override
  String get discoverStoryBehind => 'اكتشف القصة وراء كل شيء';

  @override
  String get aboutHorusBot => 'عن حوروس-بوت';

  @override
  String get you => 'أنت';

  @override
  String get exhibit => 'معروض';

  @override
  String get guestUser => 'زائر';

  @override
  String get chatHeaderTitle => 'دليل حورس';

  @override
  String get chatHeaderSubtitle => 'اطرح أسئلتك أثناء متابعتك لحوروس-بوت.';

  @override
  String get micPermissionTitle => 'الميكروفون';

  @override
  String get micPermissionDenied => 'تم رفض إذن الميكروفون.';

  @override
  String get micPermissionSettings =>
      'يرجى تمكين الوصول إلى الميكروفون من الإعدادات.';

  @override
  String get micListening => 'يستمع... تحدث الآن.';

  @override
  String get moreInfo => 'مزيد من المعلومات';

  @override
  String get moreInfoText =>
      'اسأل عن التذاكر، ساعات العمل، الفعاليات، المعروضات أو الاتجاهات.';

  @override
  String get humanSupportLabel => 'طلب دعم بشري مباشر';

  @override
  String get humanSupportAck => 'تم استلام طلب الدعم البشري.';

  @override
  String get humanSupportRequested => 'تم طلب الدعم البشري';

  @override
  String get humanSupportRequestPending =>
      'سيرد عليك ممثل الخدمة البشرية قريبًا جدًا.';

  @override
  String get quickHelpTopics => 'مواضيع سريعة';

  @override
  String get askButton => 'اسأل';

  @override
  String robotArrivalIn(Object time) {
    return 'وصول خلال $time';
  }

  @override
  String get supportRequestStatus => 'حالة الطلب';

  @override
  String get supportStatusPending => 'قيد الانتظار';

  @override
  String get supportStatusInProgress => 'قيد المعالجة';

  @override
  String get supportStatusResolved => 'تم الحل';

  @override
  String get chatLoading => 'حورس يفكر...';

  @override
  String get chatInputHint => 'اسأل الدليل أثناء متابعتك لحوروس-بوت.';

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
  String get privacyPermissions => 'إذن الموقع';

  @override
  String get privacyText =>
      'حوروس يستخدم البلوتوث والموقع لإرشادك داخل المتحف.';

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
      'عدل حجم النص، التباين، واللغة لتناسب احتياجاتك.';

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
      'اختر لغة التطبيق المفضلة؛ يظل حوروس-بوت قائدا لجولتك.';

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
  String get robotQrInMuseumMode =>
      'هذا رمز QR للروبوت ولا يمكن استخدامه لدخول المتحف.';

  @override
  String get connectedReady => 'تم الاتصال وجاهز. يمكن لحوروس-بوت البدء الآن.';

  @override
  String get museumTicketInRobotMode =>
      'تذكرة المتحف هذه غير صالحة لاتصال الروبوت.';

  @override
  String get notHorusBotQr => 'هذا الرمز ليس رمز QR لحوروس-بوت.';

  @override
  String get connectToHorusBot => 'الاتصال بحوروس-بوت';

  @override
  String get scanMuseumEntryTicket => 'مسح تذكرة دخول المتحف';

  @override
  String get scanRobotQrSubtitle =>
      'ضع رمز QR الخاص بالروبوت داخل الإطار للاتصال.';

  @override
  String get scanMuseumQrSubtitle =>
      'ضع رمز QR لتذكرة دخول المتحف داخل الإطار.';

  @override
  String get simulateRobotScan => 'محاكاة مسح الروبوت';

  @override
  String get prototypeOnly => 'نموذج تجريبي فقط';

  @override
  String get audioGuide => 'وضع الدليل الصوتي';

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

  @override
  String get museumNews => 'أخبار المتحف';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get dataAnonymous => 'البيانات مجهولة الهوية';

  @override
  String get analyticsNote => 'خرائط الحركة تستخدم فقط للتحليل';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get allowLocationAccess => 'تفعيل الموقع';

  @override
  String get locationPermissionBody =>
      'يستخدم حوروس موقعك لإرشادك عبر معروضات المتحف ومساعدتك في تتبع الروبوت أثناء الجولة.';

  @override
  String get dataReassurance => 'بياناتك مجهولة الهوية وتستخدم فقط للملاحة.';

  @override
  String get introSubtitle => 'استكشف العجائب القديمة برفقة حورس-بوت';

  @override
  String get introThe => '';

  @override
  String get introEgyptian => 'المصرية';

  @override
  String get introMuseums => 'المتاحف';

  @override
  String get introSubtitleFull => 'استكشف مصر مع حوروس-بوت وتطبيقه المكمّل.';

  @override
  String get onboarding1Title => 'مرحبًا بك في حورس';

  @override
  String get onboarding1Desc =>
      'ادخل عالم العجائب القديمة، حيث يحمل كل قطعة أثرية قصة تروى.';

  @override
  String get onboarding2Title => 'دليلك الشخصي';

  @override
  String get onboarding2Desc =>
      'اطرح الأسئلة، استمع إلى القصص، واستكشف المتحف مع حوروس-بوت وتطبيقه المكمّل.';

  @override
  String get onboarding3Title => 'استكشف بسلاسة';

  @override
  String get onboarding3Desc =>
      'تنقّل بين المعروضات بسهولة وابقَ متصلًا بدليلك طوال رحلتك.';

  @override
  String get onboarding4Title => 'اكتشف المزيد';

  @override
  String get onboarding4Desc =>
      'اكشف القصص المخفية، تفاعل مع المعروضات، واجعل كل زيارة لا تُنسى.';

  @override
  String get next => 'التالي';

  @override
  String get startExploring => 'ابدأ الاستكشاف';

  @override
  String get recommendedForYou => 'اكتشف القطع الأثرية';

  @override
  String get quizPromptTitle => 'وقت الاختبار';

  @override
  String get quizPromptDescription => 'هل تريد أخذ الاختبار لهذا المعرض؟';

  @override
  String get later => 'لاحقاً';

  @override
  String get takeNow => 'خذ الآن';

  @override
  String get didYouKnow => 'هل تعلم؟';

  @override
  String get didYouKnowFact => 'قناع توت عنخ آمون الذهبي يحتوي على ١٠ كجم ذهب.';

  @override
  String get onlineStatus => '● متصل';

  @override
  String get mapSub => 'ابحث عن المعروضات والمسارات';

  @override
  String get exhibitsSub => 'تصفح القطع الأثرية القريبة';

  @override
  String get quizSub => 'اختبر معلوماتك';

  @override
  String get liveTourSub => 'اتبع حوروس';

  @override
  String get scanExhibitsAR => 'افحص المعروضات بالواقع المعزز';

  @override
  String get visit => 'الزيارة';

  @override
  String get accountPreferences => 'الحساب والتفضيلات';

  @override
  String get extras => 'إضافات';

  @override
  String get liveTourActive => 'جولة حية نشطة';

  @override
  String get liveTourLockedTitle => 'الجولة الحية غير متاحة';

  @override
  String get liveTourLockedDesc => 'اتصل بحوروس بوت لبدء جولتك الموجهة الحية';

  @override
  String get liveTourPausedDesc => 'جولتك متوقفة حالياً. استأنف للمتابعة.';

  @override
  String get scanQRToConnect =>
      'امسح رمز الاستجابة السريعة عند مدخل المتحف للاتصال';

  @override
  String currentlyVisiting(Object location) {
    return 'تزور حالياً: $location';
  }

  @override
  String get followHorusBot => 'اتبع حوروس';

  @override
  String get startNavigation => 'بدء الملاحة';

  @override
  String robotHeadingTo(Object location) {
    return 'الروبوت يتجه إلى: $location';
  }

  @override
  String get exploreTheMuseum => 'استكشف المتحف';

  @override
  String get followAndDiscover =>
      'اتبع الروبوت واكتشف القصص وراء القطع الأثرية القديمة.';

  @override
  String get museumMap => 'خريطة المتحف';

  @override
  String get grandEgyptianMuseum => 'المتحف المصري الكبير';

  @override
  String get eastWingGoldenArtifacts => 'الجناح الشرقي • مقتنيات ذهبية';

  @override
  String get entrance => 'المدخل';

  @override
  String get explain => 'شرح';

  @override
  String get generateMyRoute => 'إنشاء مساري';

  @override
  String get customizeTourDescription =>
      'خصص جولتك في المتحف بناءً على اهتماماتك والوقت المتاح.';

  @override
  String get interestsQuestion => 'ما هي اهتماماتك؟';

  @override
  String get visitorStatistics => 'إحصائيات الزوار';

  @override
  String get myTours => 'جولاتي';

  @override
  String get savedExhibits => 'المعروضات المحفوظة';

  @override
  String get learningProgress => 'تقدم التعلم';

  @override
  String get quickPreferences => 'التفضيلات السريعة';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get explorerLabel => 'مستكشف';

  @override
  String memberSince(Object period) {
    return 'عضو منذ $period';
  }

  @override
  String get tours => 'الجولات';

  @override
  String get artifactsLabel => 'القطع';

  @override
  String get quizScoreLabel => 'نقاط الاختبار';

  @override
  String get newKingdomHighlights => 'أبرز مقتنيات الدولة الحديثة';

  @override
  String get tutankhamunTreasures => 'كنوز توت عنخ آمون';

  @override
  String get museumTickets => 'تذاكر المتحف';

  @override
  String get bookTicketsEarly => 'احجز تذاكرك مبكراً لتوفير الوقت.';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get change => 'تغيير';

  @override
  String get ticketTypes => 'أنواع التذاكر';

  @override
  String get adult => 'بالغ';

  @override
  String get ages12Plus => '١٢+ سنة';

  @override
  String get student => 'طالب';

  @override
  String get withValidID => 'مع بطاقة هوية سارية';

  @override
  String get child => 'طفل';

  @override
  String get ages5to11 => '٥-١١ سنة';

  @override
  String get totalLabel => 'المجموع';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get ticketsConfirmed => 'تم تأكيد التذاكر';

  @override
  String reservedTickets(Object date, Object tickets) {
    return 'تم حجز $tickets تذكرة في $date.';
  }

  @override
  String get viewMyTickets => 'عرض تذاكري';

  @override
  String get museumEntryTicket => 'تذكرة دخول المتحف';

  @override
  String get ticketID => 'معرّف التذكرة';

  @override
  String get priceLabel => 'السعر';

  @override
  String get activeStatus => 'سارية';

  @override
  String get expiredStatus => 'منتهية';

  @override
  String get showEntryCode => 'إظهار رمز الدخول';

  @override
  String get noTicketsYet => 'لا توجد تذاكر بعد';

  @override
  String get ticketsEmptyDesc =>
      'عند شراء التذاكر من شاشة الحجز، ستظهر هنا لعرضها عند الدخول.';

  @override
  String get searchExhibits => 'البحث في المعروضات';

  @override
  String get searchByExhibitName => 'ابحث باسم المعروض...';

  @override
  String get noResultsFound => 'لا توجد نتائج';

  @override
  String get noResultsFoundDesc => 'جرّب كلمة مختلفة أو تحقق من الهجاء.';

  @override
  String get tapToViewDetailsAndAudioGuide => 'اضغط لعرض التفاصيل ودليل الصوت';

  @override
  String get currentTour => 'الجولة الحالية';

  @override
  String get progressLabel => 'التقدّم';

  @override
  String get durationLabel => 'المدة';

  @override
  String get completedLabel => 'مكتمل';

  @override
  String get visitedLabel => 'تمت الزيارة';

  @override
  String get notVisitedYetLabel => 'لم تُزر بعد';

  @override
  String get quizzesCompleted => 'الاختبارات المكتملة';

  @override
  String get totalQuizScoreLabel => 'إجمالي نقاط الاختبار';

  @override
  String get skippedQuizzes => 'الاختبارات المتجاوزة';

  @override
  String get howWasYourVisit => 'كيف كانت زيارتك اليوم؟';

  @override
  String get rateYourExperience => 'قيّم تجربتك';

  @override
  String get overallRating => 'التقييم العام';

  @override
  String get feedbackAboutOptional => 'ما هو موضوع هذه الملاحظة؟ (اختياري)';

  @override
  String get tellUsMoreOptional => 'أخبرنا المزيد (اختياري)';

  @override
  String get feedbackPrompt => 'ما الذي أعجبك أو يحتاج إلى تحسين؟';

  @override
  String get writeFeedbackHere => 'اكتب ملاحظاتك هنا...';

  @override
  String get feedbackUsedNote =>
      'تُستخدم الملاحظات فقط لأبحاث وتحسين تجربة الزوار.';

  @override
  String get submitFeedback => 'إرسال الملاحظات';

  @override
  String get excellentThankYou => 'ممتاز، شكراً لك!';

  @override
  String get greatExperience => 'تجربة رائعة.';

  @override
  String get overallGood => 'جيدة بشكل عام.';

  @override
  String get needsImprovement => 'تحتاج بعض التحسين.';

  @override
  String get notGoodExperience => 'تجربة غير جيدة.';

  @override
  String get pleaseAddRatingOrComment =>
      'من فضلك أضف تقييماً أو تعليقاً أولاً.';

  @override
  String memberSinceNote(Object period) {
    return 'عضو منذ $period';
  }

  @override
  String get museumExperience => 'تجربة المتحف';

  @override
  String get museumExperienceSub =>
      'خصص كيف يقوم حوروس-بوت بإرشادك عبر المتحف.';

  @override
  String get autoFollow => 'التتبع التلقائي لحوروس';

  @override
  String get nearbyAlerts => 'إظهار المعروضات القريبة';

  @override
  String get detailedExplanations => 'تفعيل شروحات المعروضات';

  @override
  String get permissionsCenter => 'الأذونات';

  @override
  String get locationService => 'الموقع';

  @override
  String get bluetooth => 'البلوتوث';

  @override
  String get microphone => 'الميكروفون';

  @override
  String get camera => 'الكاميرا';

  @override
  String get notifications => 'التنبيهات';

  @override
  String get enable => 'تفعيل';

  @override
  String get settingsDisabled => 'الإعدادات: معطل';

  @override
  String get about => 'حول';

  @override
  String get appVersion => 'الإصدار ١.٠';

  @override
  String get appTagline => 'تطبيق مكمّل لحوروس-بوت';

  @override
  String get developedBy => 'تم التطوير بواسطة';

  @override
  String get organization => 'جامعة بنها';

  @override
  String get department => 'برنامج هندسة الحاسبات والاتصالات';

  @override
  String get projectInfo => 'معلومات المشروع';

  @override
  String get team => 'فريقنا';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get tutankhamunHall => 'قاعة توت عنخ آمون';

  @override
  String get fiveMinutesAway => 'على بعد ٥ دقائق';

  @override
  String get tutankhamunMask => 'قناع توت عنخ آمون';

  @override
  String get goldenHallRecommended => 'القاعة الذهبية • مستحسن الآن';

  @override
  String get ancientPapyrus => 'بردية قديمة';

  @override
  String get westWingStory => 'الجناح الغربي • قصة الكتابة';

  @override
  String get canopicJars => 'أواني كانوبية';

  @override
  String get southHallMummification => 'القاعة الجنوبية • طقوس التحنيط';

  @override
  String get locationServiceSub => 'يستخدم للملاحة الداخلية وإرشاد المعروضات';

  @override
  String get bluetoothSub => 'اتصل بمنارات الروبوت القريبة';

  @override
  String get cameraSub => 'يستخدم لمسح تذاكر QR وعرض الواقع المعزز';

  @override
  String get notificationsSub => 'ابق على اطلاع بجولتك وحالة الروبوت';

  @override
  String get audioGuideSub => 'قراءة معلومات المعروضات بصوت عالٍ تلقائيًا';

  @override
  String get reduceAnimations => 'تقليل الحركات';

  @override
  String get reduceAnimationsSub => 'تبسيط تأثيرات الحركة للمستخدمين الحساسين';

  @override
  String get simpleMode => 'الوضع البسيط';

  @override
  String get simpleModeSub => 'أزرار أكبر وتخطيط مبسط';

  @override
  String get version => 'الإصدار ١.٠';

  @override
  String get aboutDesc => 'رفيقك لتجربة حوروس-بوت.';

  @override
  String get university => 'جامعة بنها';

  @override
  String get program => 'كلية الحاسبات والذكاء الاصطناعي';

  @override
  String get tourStartingTitle => 'بدء الجولة';

  @override
  String get tourStartingMsg =>
      'جولتك الإرشادية تبدأ الآن. اتبع حوروس-بوت واستخدم التطبيق لمزيد من التفاصيل.';

  @override
  String get nextExhibitTitle => 'المعروض التالي قادم';

  @override
  String nextExhibitMsg(Object location) {
    return 'أنت تقترب من $location.';
  }

  @override
  String get quizAvailableTitle => 'اختبار متاح';

  @override
  String quizAvailableMsg(Object location) {
    return 'اختبر ما تعلمته عن $location.';
  }

  @override
  String get takeQuiz => 'بدء الاختبار';

  @override
  String get smartTipTitle => 'نصيحة من الدليل';

  @override
  String get robotNearbyTitle => 'حوروس قريب منك';

  @override
  String get robotNearbyMsg =>
      'اتبع الروبوت واستمر في استخدام التطبيق لمزيد من التفاصيل.';

  @override
  String get permissionsTitle => 'أذونات التطبيق';

  @override
  String get permissionsSubtitle =>
      'قم بتفعيل هذه الميزات لتحقيق أقصى استفادة من زيارتك للمتحف.';

  @override
  String get locationPermissionTitle => 'الوصول إلى الموقع';

  @override
  String get locationPermissionDesc =>
      'يستخدم للملاحة الداخلية، والعثور على المعروضات القريبة، وتتبع الروبوت.';

  @override
  String get notificationPermissionTitle => 'التنبيهات';

  @override
  String get notificationPermissionDesc =>
      'تلقي تنبيهات لبدء الجولات، والمعروضات التالية، وتذكيرات الاختبارات.';

  @override
  String get cameraPermissionTitle => 'الوصول إلى الكاميرا';

  @override
  String get cameraPermissionDesc =>
      'مطلوب لمسح تذاكر QR وميزات الواقع المعزز المستقبلية.';

  @override
  String get continueBtn => 'الاستمرار إلى الرئيسية';

  @override
  String get benhaUniversity => 'جامعة بنها';

  @override
  String get facultyEngineeringShoubra => 'كلية الهندسة بشبرا';

  @override
  String get computerCommunicationProgram => 'برنامج هندسة الحاسبات والاتصالات';

  @override
  String get drMohamedHussein => 'د. محمد حسين';

  @override
  String youScored(int score, int total) {
    return 'حصلت على $score من أصل $total';
  }

  @override
  String get retry => 'إعادة محاولة';

  @override
  String get doneButton => 'تم';

  @override
  String get guestVisitor => 'زائر';

  @override
  String get englishLanguage => 'الإنجليزية';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get webPermissionsNote =>
      'يتم إدارة الأذونات من خلال إعدادات المتصفح لديك على الويب.';

  @override
  String get ticketConfirmation => 'تأكيد التذكرة';

  @override
  String get scanResult => 'نتيجة المسح';

  @override
  String get feedbackSubmitted => 'تم إرسال الملاحظات';

  @override
  String get horusBotTitle => 'حوروس-بوت';

  @override
  String get version1 => 'الإصدار ١.٠';

  @override
  String get smartAutonomousGuide => 'مرشد متحف ذكي ذاتي القيادة';

  @override
  String get projectDescription =>
      'حوروس-بوت هو روبوت دليل متحف ذكي ذاتي القيادة مصمم لتحسين تجربة زائري المتحف من خلال الملاحة الذاتية والتفاعل متعدد اللغات وتطبيق مرافق.';

  @override
  String get projectDescriptionLabel => 'وصف المشروع';

  @override
  String get technologiesUsedLabel => 'التقنيات المستخدمة';

  @override
  String get developedByLabel => 'تم التطوير بواسطة';

  @override
  String get teamLabel => 'الفريق';

  @override
  String get supervisorLabel => 'المشرف';

  @override
  String get copyrightYear => 'جميع الحقوق محفوظة © ٢٠٢٦ مشروع حوروس-بوت';

  @override
  String get notificationExplanationTitle => 'ابقَ متصلاً مع التنبيهات';

  @override
  String get notificationExplanationBody =>
      'استقبل تحديثات في الوقت المناسب حول رحلتك بالمتحف للاستفادة القصوى من زيارتك.';

  @override
  String get notificationExampleTourStarting => 'ستبدأ جولتك خلال 10 دقائق';

  @override
  String get notificationExampleNextExhibit =>
      'المعروض التالي قادم: قاعة توت عنخ آمون';

  @override
  String get notificationExampleQuizAvailable =>
      'اختبار سريع متاح عن مصر القديمة';

  @override
  String get notificationExampleTicketReminder => 'زيارتك للمتحف اليوم';

  @override
  String get notificationExplanationAllow => 'السماح بالتنبيهات';

  @override
  String get notificationExplanationDecline => 'ليس الآن';

  @override
  String get notificationPermissionDeniedTitle => 'التنبيهات معطلة';

  @override
  String get notificationPermissionDeniedBody =>
      'لاستقبال تحديثات الجولة والتذكيرات، فعّل التنبيهات في إعدادات جهازك.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get notificationSettings => 'إعدادات التنبيهات';

  @override
  String get notificationSettingsSubtitle =>
      'اختر التنبيهات التي تريد استقبالها';

  @override
  String get enableAllNotifications => 'تفعيل جميع التنبيهات';

  @override
  String get disableAllNotifications => 'تعطيل جميع التنبيهات';

  @override
  String get tourUpdatesCategory => 'تحديثات الجولة';

  @override
  String get tourUpdatesCategoryDesc => 'بدء الجولة والتقدم والانتهاء';

  @override
  String get exhibitRemindersCategory => 'تذكيرات المعروضات';

  @override
  String get exhibitRemindersCategoryDesc =>
      'المعروضات القريبة والاكتشافات الجديدة';

  @override
  String get quizRemindersCategory => 'تذكيرات الاختبار';

  @override
  String get quizRemindersCategoryDesc => 'إخطارات توفر الاختبارات';

  @override
  String get guideRemindersCategory => 'تذكيرات الدليل';

  @override
  String get guideRemindersCategoryDesc => 'اقتراحات اسأل الدليل';

  @override
  String get museumNewsCategory => 'أخبار المتحف';

  @override
  String get museumNewsCategoryDesc => 'هل كنت تعلم الحقائق والفعاليات';

  @override
  String get ticketRemindersCategory => 'تذكيرات التذاكر';

  @override
  String get ticketRemindersCategoryDesc => 'تذكيرات الزيارة والفعاليات';

  @override
  String get systemAlertsCategory => 'التنبيهات النظامية';

  @override
  String get systemAlertsCategoryDesc => 'تحديثات الاتصال والحالة';

  @override
  String get notificationPermissionStatus => 'إذن التنبيهات';

  @override
  String get notificationPermissionGranted => 'مفعّل';

  @override
  String get notificationPermissionDenied => 'معطّل';

  @override
  String get enableNotifications => 'تفعيل التنبيهات';

  @override
  String get disableNotifications => 'تعطيل التنبيهات';

  @override
  String get quickSuggestions => 'اقتراحات سريعة';

  @override
  String get chatInfoPopup =>
      'يمكنك السؤال عن التذاكر أو الفعاليات أو المواعيد أو المعروضات.';

  @override
  String get supportConversationTitle => 'محادثة الدعم';

  @override
  String get supportRequestNotFound => 'طلب الدعم غير موجود';

  @override
  String get supportReplyHint => 'اكتب ردك...';

  @override
  String get supportRequestFrom => 'من';

  @override
  String get supportRequestCreatedAt => 'أنشئ في';

  @override
  String get supportInboxTitle => 'صندوق الدعم';

  @override
  String get supportNoRequests => 'لا توجد طلبات دعم';

  @override
  String get welcomeToHorusBot => 'مرحباً بك في حورس-بوت';

  @override
  String get howAreYouUsingTheAppToday => 'كيف ستستخدم التطبيق اليوم؟';

  @override
  String get planMyVisit => 'خطط لزيارتي';

  @override
  String get planMyVisitDescription =>
      'استكشف المتحف، اشترِ التذاكر، واستعد لزيارتك.';

  @override
  String get startMyTour => 'ابدأ جولتي';

  @override
  String get startMyTourDescription =>
      'استخدم تذاكرك، اتصل بحورس-بوت، وابدأ التجربة الموجهة.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get fullNameHint => 'أدخل اسمك الكامل';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get phoneHint => 'أدخل رقم هاتفك (اختياري)';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أدخل كلمة المرور مرة أخرى';

  @override
  String get passwordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get welcomeBack => 'أهلاً وسهلاً بعودتك';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get loggingIn => 'جاري تسجيل الدخول';

  @override
  String get signingUp => 'جاري إنشاء الحساب';

  @override
  String get loginFailed => 'فشل تسجيل الدخول. يرجى التحقق من بيانات اعتمادك.';

  @override
  String get registerFailed => 'فشل التسجيل. يرجى المحاولة مرة أخرى.';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح!';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get myAccount => 'حسابي';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get viewTickets => 'عرض التذاكر';

  @override
  String get myTickets => 'تذاكري';

  @override
  String get buyTickets => 'شراء التذاكر';

  @override
  String get loggedInAs => 'تم تسجيل الدخول باسم';

  @override
  String get guestMode => 'وضع الزائر';

  @override
  String get loginToViewTickets => 'سجل الدخول لعرض تذاكرك';

  @override
  String get loginToStartTour => 'سجل الدخول لبدء جولتك';

  @override
  String get accountRequired => 'الحساب مطلوب';

  @override
  String get createOrLoginToPreserve =>
      'أنشئ حساباً أو سجل دخولك لحفظ تذاكرك والمدفوعات وإمكانية الوصول إلى جولة الروبوت.';

  @override
  String get accountRequiredForPurchase =>
      'يجب عليك إنشاء حساب أو تسجيل الدخول قبل شراء التذاكر.';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get visitHistory => 'سجل الزيارات';

  @override
  String get invalidEmail => 'صيغة بريد إلكتروني غير صحيحة';

  @override
  String get accountAlreadyExists => 'هذا البريد الإلكتروني مسجل بالفعل';

  @override
  String get visitDate => 'تاريخ الزيارة';

  @override
  String get timeSlot => 'فترة الدخول';

  @override
  String get ticketId => 'معرّف التذكرة';

  @override
  String get active => 'سارية';

  @override
  String get expired => 'منتهية';

  @override
  String get useQrAtMuseumEntrance => 'استخدم هذا الرمز عند بوابة المتحف';

  @override
  String get minutes => 'دقيقة';

  @override
  String get includedFeatures => 'المميزات المشمولة';

  @override
  String get startTourSetup => 'إعداد الجولة';

  @override
  String get scanQrOnRobot => 'امسح رمز QR الموجود على روبوت حورس-بوت للاتصال';
}
