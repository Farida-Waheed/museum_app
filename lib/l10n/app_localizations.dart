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
  /// **'Horus-Bot'**
  String get appTitle;

  /// No description provided for @exploreEgypt.
  ///
  /// In en, this message translates to:
  /// **'Explore Egypt with Horus-Bot'**
  String get exploreEgypt;

  /// No description provided for @nextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop: {location} in {time} min'**
  String nextStop(String location, int time);

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
  /// **'Horus-Bot'**
  String get horusBot;

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
  /// **'Display & text'**
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
  /// **'Audio guide'**
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

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Horus-Bot'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Desc.
  ///
  /// In en, this message translates to:
  /// **'Your smart guide to the museum. Navigate exhibits, follow the robot, and discover hidden stories.'**
  String get onboarding1Desc;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Meet Horus-Bot'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Desc.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent museum guide. Ask questions, listen to explanations, and explore during your visit.'**
  String get onboarding2Desc;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Guided Tour Mode'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Desc.
  ///
  /// In en, this message translates to:
  /// **'Automatic guidance through exhibits. Stay connected with Horus-Bot throughout your journey.'**
  String get onboarding3Desc;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Explore & Learn'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Desc.
  ///
  /// In en, this message translates to:
  /// **'Discover artifacts, ask questions, and enjoy interactive museum quizzes.'**
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
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @talkToHorusBot.
  ///
  /// In en, this message translates to:
  /// **'Talk to Horus-Bot'**
  String get talkToHorusBot;

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
  /// **'Follow Horus-Bot and discover ancient Egypt'**
  String get followAndDiscover;
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
