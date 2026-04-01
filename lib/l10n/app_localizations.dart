import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Horus'**
  String get appTitle;

  /// No description provided for @exploreEgypt.
  ///
  /// In en, this message translates to:
  /// **'Explore Egypt With Horus-Bot'**
  String get exploreEgypt;

  /// No description provided for @nextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop: {location} in {time} min'**
  String nextStop(Object location, Object time);

  /// No description provided for @exhibits.
  ///
  /// In en, this message translates to:
  /// **'Exhibits'**
  String get exhibits;

  /// No description provided for @visited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visited;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @todaysHighlights.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Highlights'**
  String get todaysHighlights;

  /// No description provided for @mapPreview.
  ///
  /// In en, this message translates to:
  /// **'Map Preview'**
  String get mapPreview;

  /// No description provided for @fullView.
  ///
  /// In en, this message translates to:
  /// **'Full View'**
  String get fullView;

  /// No description provided for @horusBot.
  ///
  /// In en, this message translates to:
  /// **'Horus'**
  String get horusBot;

  /// No description provided for @talkToHorusBot.
  ///
  /// In en, this message translates to:
  /// **'Ask the Guide'**
  String get talkToHorusBot;

  /// No description provided for @askTheGuide.
  ///
  /// In en, this message translates to:
  /// **'Ask the Guide'**
  String get askTheGuide;

  /// No description provided for @guideStatus.
  ///
  /// In en, this message translates to:
  /// **'Guide Status'**
  String get guideStatus;

  /// No description provided for @alwaysAvailable.
  ///
  /// In en, this message translates to:
  /// **'Always available'**
  String get alwaysAvailable;

  /// No description provided for @aboutHorusBot.
  ///
  /// In en, this message translates to:
  /// **'About the Guide'**
  String get aboutHorusBot;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @exhibit.
  ///
  /// In en, this message translates to:
  /// **'Exhibit'**
  String get exhibit;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @exploreMuseum.
  ///
  /// In en, this message translates to:
  /// **'Explore the museum'**
  String get exploreMuseum;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @liveTour.
  ///
  /// In en, this message translates to:
  /// **'Live Tour'**
  String get liveTour;

  /// No description provided for @tourPlanner.
  ///
  /// In en, this message translates to:
  /// **'Tour Planner'**
  String get tourPlanner;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacyPermissions.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get privacyPermissions;

  /// No description provided for @privacyText.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot uses Bluetooth and Location to guide you inside the museum.'**
  String get privacyText;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @mainGallery.
  ///
  /// In en, this message translates to:
  /// **'Main exhibition gallery'**
  String get mainGallery;

  /// No description provided for @comfortableApp.
  ///
  /// In en, this message translates to:
  /// **'Make the app comfortable for you'**
  String get comfortableApp;

  /// No description provided for @adjustSettings.
  ///
  /// In en, this message translates to:
  /// **'Adjust text size, contrast, and language to suit your needs.'**
  String get adjustSettings;

  /// No description provided for @displayText.
  ///
  /// In en, this message translates to:
  /// **'Display & Text'**
  String get displayText;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast mode'**
  String get highContrast;

  /// No description provided for @highContrastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase color and element contrast for low vision or low light.'**
  String get highContrastSubtitle;

  /// No description provided for @appearanceMode.
  ///
  /// In en, this message translates to:
  /// **'Appearance mode'**
  String get appearanceMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @smaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get smaller;

  /// No description provided for @larger.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get larger;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app UI and content.'**
  String get appLanguageSubtitle;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'These settings are saved on this device only.'**
  String get saveNote;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Settings & Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// No description provided for @ticketVerified.
  ///
  /// In en, this message translates to:
  /// **'Ticket Verified'**
  String get ticketVerified;

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQr;

  /// No description provided for @scanTicket.
  ///
  /// In en, this message translates to:
  /// **'Scan Ticket'**
  String get scanTicket;

  /// No description provided for @alignQr.
  ///
  /// In en, this message translates to:
  /// **'Align QR Code within the frame'**
  String get alignQr;

  /// No description provided for @audioGuide.
  ///
  /// In en, this message translates to:
  /// **'Audio Guide Mode'**
  String get audioGuide;

  /// No description provided for @audioPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing the audio guide...'**
  String get audioPlaying;

  /// No description provided for @audioNarration.
  ///
  /// In en, this message translates to:
  /// **'Tap to listen to a short narration.'**
  String get audioNarration;

  /// No description provided for @addedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Exhibit added to your list.'**
  String get addedToBookmarks;

  /// No description provided for @removedFromBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Exhibit removed from your list.'**
  String get removedFromBookmarks;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addToMyRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to my route'**
  String get addToMyRoute;

  /// No description provided for @viewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMap;

  /// No description provided for @addedToRoute.
  ///
  /// In en, this message translates to:
  /// **'Added to your route.'**
  String get addedToRoute;

  /// No description provided for @openingMap.
  ///
  /// In en, this message translates to:
  /// **'Opening the map at this gallery.'**
  String get openingMap;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @robotDescribing.
  ///
  /// In en, this message translates to:
  /// **'The robot is currently describing this exhibit.'**
  String get robotDescribing;

  /// No description provided for @liveTranscript.
  ///
  /// In en, this message translates to:
  /// **'Live transcript'**
  String get liveTranscript;

  /// No description provided for @accessibilityMuteNote.
  ///
  /// In en, this message translates to:
  /// **'You can mute the robot and follow only the text at any time.'**
  String get accessibilityMuteNote;

  /// No description provided for @guidedMode.
  ///
  /// In en, this message translates to:
  /// **'Guided Mode'**
  String get guidedMode;

  /// No description provided for @selfPacedMode.
  ///
  /// In en, this message translates to:
  /// **'Self-paced Mode'**
  String get selfPacedMode;

  /// No description provided for @currentStop.
  ///
  /// In en, this message translates to:
  /// **'Current Stop'**
  String get currentStop;

  /// No description provided for @nextStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Stop'**
  String get nextStopLabel;

  /// No description provided for @previousStop.
  ///
  /// In en, this message translates to:
  /// **'Previous Stop'**
  String get previousStop;

  /// No description provided for @tourProgress.
  ///
  /// In en, this message translates to:
  /// **'Tour Progress'**
  String get tourProgress;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @robotWaiting.
  ///
  /// In en, this message translates to:
  /// **'Robot is waiting for you at the next stop.'**
  String get robotWaiting;

  /// No description provided for @robotMoving.
  ///
  /// In en, this message translates to:
  /// **'Robot is moving to the next exhibit.'**
  String get robotMoving;

  /// No description provided for @connectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Reconnecting...'**
  String get connectionLost;

  /// No description provided for @myJourney.
  ///
  /// In en, this message translates to:
  /// **'My Journey'**
  String get myJourney;

  /// No description provided for @exhibitsFound.
  ///
  /// In en, this message translates to:
  /// **'Exhibits Found'**
  String get exhibitsFound;

  /// No description provided for @factsDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Facts Discovered'**
  String get factsDiscovered;

  /// No description provided for @takeQuickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take a quick quiz about this exhibit!'**
  String get takeQuickQuiz;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @visitSummary.
  ///
  /// In en, this message translates to:
  /// **'Visit Summary'**
  String get visitSummary;

  /// No description provided for @endTour.
  ///
  /// In en, this message translates to:
  /// **'End Tour'**
  String get endTour;

  /// No description provided for @congrats.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congrats;

  /// No description provided for @visitComplete.
  ///
  /// In en, this message translates to:
  /// **'You have completed your museum journey.'**
  String get visitComplete;

  /// No description provided for @exhibitsVisited.
  ///
  /// In en, this message translates to:
  /// **'Exhibits Visited'**
  String get exhibitsVisited;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @shareVisit.
  ///
  /// In en, this message translates to:
  /// **'Share my visit'**
  String get shareVisit;

  /// No description provided for @pioneer.
  ///
  /// In en, this message translates to:
  /// **'Pioneer'**
  String get pioneer;

  /// No description provided for @pioneerDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit your first exhibit'**
  String get pioneerDesc;

  /// No description provided for @scholar.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get scholar;

  /// No description provided for @scholarDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover 5 facts'**
  String get scholarDesc;

  /// No description provided for @wayfinder.
  ///
  /// In en, this message translates to:
  /// **'Wayfinder'**
  String get wayfinder;

  /// No description provided for @wayfinderDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a full wing tour'**
  String get wayfinderDesc;

  /// No description provided for @happeningNow.
  ///
  /// In en, this message translates to:
  /// **'Happening Now'**
  String get happeningNow;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No live events at the moment.'**
  String get noEvents;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @workshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop: Hieroglyphs 101'**
  String get workshop;

  /// No description provided for @workshopDesc.
  ///
  /// In en, this message translates to:
  /// **'Starts in 20 min at Hall C'**
  String get workshopDesc;

  /// No description provided for @talk.
  ///
  /// In en, this message translates to:
  /// **'Talk: The Boy King'**
  String get talk;

  /// No description provided for @talkDesc.
  ///
  /// In en, this message translates to:
  /// **'Starts at 2:00 PM at Main Theater'**
  String get talkDesc;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tour.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get tour;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @museumNews.
  ///
  /// In en, this message translates to:
  /// **'Museum News'**
  String get museumNews;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @dataAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Data is anonymous'**
  String get dataAnonymous;

  /// No description provided for @analyticsNote.
  ///
  /// In en, this message translates to:
  /// **'Movement heatmaps are only used for analytics'**
  String get analyticsNote;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get allowLocationAccess;

  /// No description provided for @locationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot uses your location to guide you through museum exhibits and help you follow the robot during your visit.'**
  String get locationPermissionBody;

  /// No description provided for @dataReassurance.
  ///
  /// In en, this message translates to:
  /// **'Your data is anonymous and used only for navigation.'**
  String get dataReassurance;

  /// No description provided for @introSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover ancient wonders with Horus-Bot'**
  String get introSubtitle;

  /// No description provided for @introThe.
  ///
  /// In en, this message translates to:
  /// **'The '**
  String get introThe;

  /// No description provided for @introEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian'**
  String get introEgyptian;

  /// No description provided for @introMuseums.
  ///
  /// In en, this message translates to:
  /// **'Museums'**
  String get introMuseums;

  /// No description provided for @introSubtitleFull.
  ///
  /// In en, this message translates to:
  /// **'Explore Egypt with your Horus-Bot and its app.'**
  String get introSubtitleFull;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Horus'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Step into a world of ancient wonders, where every artifact has a story to tell.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Your Personal Guide'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Ask questions, hear stories, and explore the museum in a smarter, more immersive way.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Explore Seamlessly'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Navigate through exhibits with ease and stay connected to your guide throughout your journey.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Discover More'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In en, this message translates to:
  /// **'Uncover hidden stories, interact with exhibits, and make every visit unforgettable.'**
  String get onboarding4Desc;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @startExploring.
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get startExploring;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Discover Artifacts'**
  String get recommendedForYou;

  /// No description provided for @quizPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Time'**
  String get quizPromptTitle;

  /// No description provided for @quizPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'Would you like to take the quiz for this exhibit?'**
  String get quizPromptDescription;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @takeNow.
  ///
  /// In en, this message translates to:
  /// **'Take Now'**
  String get takeNow;

  /// No description provided for @didYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get didYouKnow;

  /// No description provided for @didYouKnowFact.
  ///
  /// In en, this message translates to:
  /// **'Tutankhamun\'s mask contains 10kg of gold.'**
  String get didYouKnowFact;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'● Online'**
  String get onlineStatus;

  /// No description provided for @mapSub.
  ///
  /// In en, this message translates to:
  /// **'Find exhibits and routes'**
  String get mapSub;

  /// No description provided for @exhibitsSub.
  ///
  /// In en, this message translates to:
  /// **'Browse nearby artifacts'**
  String get exhibitsSub;

  /// No description provided for @quizSub.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get quizSub;

  /// No description provided for @liveTourSub.
  ///
  /// In en, this message translates to:
  /// **'Follow Horus-Bot'**
  String get liveTourSub;

  /// No description provided for @scanExhibitsAR.
  ///
  /// In en, this message translates to:
  /// **'Scan Exhibits with AR'**
  String get scanExhibitsAR;

  /// No description provided for @visit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get visit;

  /// No description provided for @accountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Account & Preferences'**
  String get accountPreferences;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// No description provided for @liveTourActive.
  ///
  /// In en, this message translates to:
  /// **'Live Tour Active'**
  String get liveTourActive;

  /// No description provided for @currentlyVisiting.
  ///
  /// In en, this message translates to:
  /// **'Currently Visiting: {location}'**
  String currentlyVisiting(Object location);

  /// No description provided for @followHorusBot.
  ///
  /// In en, this message translates to:
  /// **'Follow Horus-Bot'**
  String get followHorusBot;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @robotHeadingTo.
  ///
  /// In en, this message translates to:
  /// **'Robot heading to: {location}'**
  String robotHeadingTo(Object location);

  /// No description provided for @exploreTheMuseum.
  ///
  /// In en, this message translates to:
  /// **'Explore the Museum'**
  String get exploreTheMuseum;

  /// No description provided for @followAndDiscover.
  ///
  /// In en, this message translates to:
  /// **'Follow the robot and uncover the stories behind ancient artifacts.'**
  String get followAndDiscover;

  /// No description provided for @museumExperience.
  ///
  /// In en, this message translates to:
  /// **'Museum Experience'**
  String get museumExperience;

  /// No description provided for @museumExperienceSub.
  ///
  /// In en, this message translates to:
  /// **'Customize how Horus-Bot guides you through the museum.'**
  String get museumExperienceSub;

  /// No description provided for @autoFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow Horus-Bot automatically'**
  String get autoFollow;

  /// No description provided for @nearbyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Show nearby exhibits'**
  String get nearbyAlerts;

  /// No description provided for @detailedExplanations.
  ///
  /// In en, this message translates to:
  /// **'Enable exhibit explanations'**
  String get detailedExplanations;

  /// No description provided for @voiceInteraction.
  ///
  /// In en, this message translates to:
  /// **'Enable voice interaction'**
  String get voiceInteraction;

  /// No description provided for @permissionsCenter.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsCenter;

  /// No description provided for @locationService.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationService;

  /// No description provided for @bluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// No description provided for @microphone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get microphone;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @settingsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Settings: Disabled'**
  String get settingsDisabled;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get appVersion;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Autonomous Museum Guide'**
  String get appTagline;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Benha University'**
  String get organization;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Computer & Communication Engineering Program'**
  String get department;

  /// No description provided for @projectInfo.
  ///
  /// In en, this message translates to:
  /// **'Project Information'**
  String get projectInfo;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @tutankhamunHall.
  ///
  /// In en, this message translates to:
  /// **'Tutankhamun Hall'**
  String get tutankhamunHall;

  /// No description provided for @fiveMinutesAway.
  ///
  /// In en, this message translates to:
  /// **'5 minutes away'**
  String get fiveMinutesAway;

  /// No description provided for @tutankhamunMask.
  ///
  /// In en, this message translates to:
  /// **'Tutankhamun Mask'**
  String get tutankhamunMask;

  /// No description provided for @goldenHallRecommended.
  ///
  /// In en, this message translates to:
  /// **'Golden Hall • Recommended now'**
  String get goldenHallRecommended;

  /// No description provided for @ancientPapyrus.
  ///
  /// In en, this message translates to:
  /// **'Ancient Papyrus'**
  String get ancientPapyrus;

  /// No description provided for @westWingStory.
  ///
  /// In en, this message translates to:
  /// **'West Wing • Story of Writing'**
  String get westWingStory;

  /// No description provided for @canopicJars.
  ///
  /// In en, this message translates to:
  /// **'Canopic Jars'**
  String get canopicJars;

  /// No description provided for @southHallMummification.
  ///
  /// In en, this message translates to:
  /// **'South Hall • Mummification Rituals'**
  String get southHallMummification;

  /// No description provided for @locationServiceSub.
  ///
  /// In en, this message translates to:
  /// **'Used for indoor navigation and exhibit guidance'**
  String get locationServiceSub;

  /// No description provided for @bluetoothSub.
  ///
  /// In en, this message translates to:
  /// **'Connect to nearby robot beacons'**
  String get bluetoothSub;

  /// No description provided for @microphoneSub.
  ///
  /// In en, this message translates to:
  /// **'Used for voice commands to Horus-Bot'**
  String get microphoneSub;

  /// No description provided for @cameraSub.
  ///
  /// In en, this message translates to:
  /// **'Used for scanning QR tickets and AR view'**
  String get cameraSub;

  /// No description provided for @notificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on your tour and robot status'**
  String get notificationsSub;

  /// No description provided for @audioGuideSub.
  ///
  /// In en, this message translates to:
  /// **'Automatically read exhibit information aloud.'**
  String get audioGuideSub;

  /// No description provided for @reduceAnimations.
  ///
  /// In en, this message translates to:
  /// **'Reduce Animations'**
  String get reduceAnimations;

  /// No description provided for @reduceAnimationsSub.
  ///
  /// In en, this message translates to:
  /// **'Simplifies motion effects for sensitive users.'**
  String get reduceAnimationsSub;

  /// No description provided for @simpleMode.
  ///
  /// In en, this message translates to:
  /// **'Simple Mode'**
  String get simpleMode;

  /// No description provided for @simpleModeSub.
  ///
  /// In en, this message translates to:
  /// **'Larger buttons and simplified layout.'**
  String get simpleModeSub;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get version;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Your AI companion.'**
  String get aboutDesc;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'Benha University'**
  String get university;

  /// No description provided for @program.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Computers and Artificial Intelligence'**
  String get program;

  /// No description provided for @tourStartingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour Starting'**
  String get tourStartingTitle;

  /// No description provided for @tourStartingMsg.
  ///
  /// In en, this message translates to:
  /// **'Your guided tour is starting. Follow Horus-Bot.'**
  String get tourStartingMsg;

  /// No description provided for @nextExhibitTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Exhibit Ahead'**
  String get nextExhibitTitle;

  /// No description provided for @nextExhibitMsg.
  ///
  /// In en, this message translates to:
  /// **'{location} is approaching.'**
  String nextExhibitMsg(Object location);

  /// No description provided for @quizAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Available'**
  String get quizAvailableTitle;

  /// No description provided for @quizAvailableMsg.
  ///
  /// In en, this message translates to:
  /// **'Test what you learned about {location}.'**
  String quizAvailableMsg(Object location);

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// No description provided for @smartTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip from the Guide'**
  String get smartTipTitle;

  /// No description provided for @robotNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is nearby'**
  String get robotNearbyTitle;

  /// No description provided for @robotNearbyMsg.
  ///
  /// In en, this message translates to:
  /// **'Follow the robot to continue your tour.'**
  String get robotNearbyMsg;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable these features to get the most out of your museum visit.'**
  String get permissionsSubtitle;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Used for indoor navigation, finding nearby exhibits, and following the robot.'**
  String get locationPermissionDesc;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts for tour starts, next exhibits, and quiz reminders.'**
  String get notificationPermissionDesc;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Needed for scanning QR tickets and future AR features.'**
  String get cameraPermissionDesc;

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Used for voice interaction and questions to Horus.'**
  String get micPermissionDesc;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE TO HOME'**
  String get continueBtn;

  /// No description provided for @benhaUniversity.
  ///
  /// In en, this message translates to:
  /// **'Benha University'**
  String get benhaUniversity;

  /// No description provided for @facultyEngineeringShoubra.
  ///
  /// In en, this message translates to:
  /// **'Faculty of Engineering at Shoubra'**
  String get facultyEngineeringShoubra;

  /// No description provided for @computerCommunicationProgram.
  ///
  /// In en, this message translates to:
  /// **'Computer & Communication Engineering Program'**
  String get computerCommunicationProgram;

  /// No description provided for @drMohamedHussein.
  ///
  /// In en, this message translates to:
  /// **'Dr. Mohamed Hussein'**
  String get drMohamedHussein;

  /// Quiz result message
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String youScored(int score, int total);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneButton;

  /// No description provided for @guestVisitor.
  ///
  /// In en, this message translates to:
  /// **'Guest Visitor'**
  String get guestVisitor;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicLanguage;

  /// No description provided for @webPermissionsNote.
  ///
  /// In en, this message translates to:
  /// **'Permissions are managed by your browser settings on web.'**
  String get webPermissionsNote;

  /// No description provided for @ticketConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Ticket confirmation'**
  String get ticketConfirmation;

  /// No description provided for @scanResult.
  ///
  /// In en, this message translates to:
  /// **'Scan result'**
  String get scanResult;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted'**
  String get feedbackSubmitted;

  /// No description provided for @horusBotTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot'**
  String get horusBotTitle;

  /// No description provided for @version1.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get version1;

  /// No description provided for @smartAutonomousGuide.
  ///
  /// In en, this message translates to:
  /// **'Smart Autonomous Museum Guide'**
  String get smartAutonomousGuide;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is a smart autonomous museum guide robot designed to enhance museum visitor experience through autonomous navigation, multilingual interaction, and a companion mobile application.'**
  String get projectDescription;

  /// No description provided for @projectDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Project Description'**
  String get projectDescriptionLabel;

  /// No description provided for @technologiesUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Technologies Used'**
  String get technologiesUsedLabel;

  /// No description provided for @developedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Developed By'**
  String get developedByLabel;

  /// No description provided for @teamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamLabel;

  /// No description provided for @supervisorLabel.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisorLabel;

  /// No description provided for @copyrightYear.
  ///
  /// In en, this message translates to:
  /// **'Copyright © 2026 Horus-Bot Project'**
  String get copyrightYear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
