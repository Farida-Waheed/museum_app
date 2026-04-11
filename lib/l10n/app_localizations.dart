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

  /// No description provided for @discoverStoryBehind.
  ///
  /// In en, this message translates to:
  /// **'Discover the story behind everything'**
  String get discoverStoryBehind;

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

  /// No description provided for @chatHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus Guide'**
  String get chatHeaderTitle;

  /// No description provided for @chatHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask your museum questions while you follow Horus-Bot.'**
  String get chatHeaderSubtitle;

  /// No description provided for @micPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get micPermissionTitle;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was denied.'**
  String get micPermissionDenied;

  /// No description provided for @micPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Please enable microphone access from Settings.'**
  String get micPermissionSettings;

  /// No description provided for @micListening.
  ///
  /// In en, this message translates to:
  /// **'Listening... Speak now.'**
  String get micListening;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreInfo;

  /// No description provided for @moreInfoText.
  ///
  /// In en, this message translates to:
  /// **'Ask about tickets, opening hours, events, exhibits, or directions.'**
  String get moreInfoText;

  /// No description provided for @humanSupportLabel.
  ///
  /// In en, this message translates to:
  /// **'Request live human support'**
  String get humanSupportLabel;

  /// No description provided for @humanSupportAck.
  ///
  /// In en, this message translates to:
  /// **'Live human support request received.'**
  String get humanSupportAck;

  /// No description provided for @humanSupportRequested.
  ///
  /// In en, this message translates to:
  /// **'Human support requested'**
  String get humanSupportRequested;

  /// No description provided for @humanSupportRequestPending.
  ///
  /// In en, this message translates to:
  /// **'A human representative will respond shortly.'**
  String get humanSupportRequestPending;

  /// No description provided for @quickHelpTopics.
  ///
  /// In en, this message translates to:
  /// **'Quick help topics'**
  String get quickHelpTopics;

  /// No description provided for @askButton.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get askButton;

  /// No description provided for @robotArrivalIn.
  ///
  /// In en, this message translates to:
  /// **'Arrival in {time}'**
  String robotArrivalIn(Object time);

  /// No description provided for @supportRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request status'**
  String get supportRequestStatus;

  /// No description provided for @supportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get supportStatusPending;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportStatusResolved;

  /// No description provided for @chatLoading.
  ///
  /// In en, this message translates to:
  /// **'Horus is thinking...'**
  String get chatLoading;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the Guide while you follow Horus-Bot.'**
  String get chatInputHint;

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
  /// **'Choose your preferred app language; Horus-Bot remains your tour leader.'**
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
  /// **'Explore Egypt with Horus-Bot and its companion app.'**
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
  /// **'Ask questions, hear stories, and explore the museum with Horus-Bot and its companion app.'**
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

  /// No description provided for @museumMap.
  ///
  /// In en, this message translates to:
  /// **'Museum Map'**
  String get museumMap;

  /// No description provided for @grandEgyptianMuseum.
  ///
  /// In en, this message translates to:
  /// **'Grand Egyptian Museum'**
  String get grandEgyptianMuseum;

  /// No description provided for @eastWingGoldenArtifacts.
  ///
  /// In en, this message translates to:
  /// **'East Wing • Golden Artifacts'**
  String get eastWingGoldenArtifacts;

  /// No description provided for @entrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get entrance;

  /// No description provided for @explain.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get explain;

  /// No description provided for @generateMyRoute.
  ///
  /// In en, this message translates to:
  /// **'Generate My Route'**
  String get generateMyRoute;

  /// No description provided for @customizeTourDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize your museum tour based on your interests and available time.'**
  String get customizeTourDescription;

  /// No description provided for @interestsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are your interests?'**
  String get interestsQuestion;

  /// No description provided for @visitorStatistics.
  ///
  /// In en, this message translates to:
  /// **'Visitor Statistics'**
  String get visitorStatistics;

  /// No description provided for @myTours.
  ///
  /// In en, this message translates to:
  /// **'My Tours'**
  String get myTours;

  /// No description provided for @savedExhibits.
  ///
  /// In en, this message translates to:
  /// **'Saved Exhibits'**
  String get savedExhibits;

  /// No description provided for @learningProgress.
  ///
  /// In en, this message translates to:
  /// **'Learning Progress'**
  String get learningProgress;

  /// No description provided for @quickPreferences.
  ///
  /// In en, this message translates to:
  /// **'Quick Preferences'**
  String get quickPreferences;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @explorerLabel.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorerLabel;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {period}'**
  String memberSince(Object period);

  /// No description provided for @tours.
  ///
  /// In en, this message translates to:
  /// **'Tours'**
  String get tours;

  /// No description provided for @artifactsLabel.
  ///
  /// In en, this message translates to:
  /// **'Artifacts'**
  String get artifactsLabel;

  /// No description provided for @quizScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Quiz Score'**
  String get quizScoreLabel;

  /// No description provided for @newKingdomHighlights.
  ///
  /// In en, this message translates to:
  /// **'New Kingdom Highlights'**
  String get newKingdomHighlights;

  /// No description provided for @tutankhamunTreasures.
  ///
  /// In en, this message translates to:
  /// **'Tutankhamun Treasures'**
  String get tutankhamunTreasures;

  /// No description provided for @museumTickets.
  ///
  /// In en, this message translates to:
  /// **'Museum Tickets'**
  String get museumTickets;

  /// No description provided for @bookTicketsEarly.
  ///
  /// In en, this message translates to:
  /// **'Book your tickets early to save time.'**
  String get bookTicketsEarly;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @ticketTypes.
  ///
  /// In en, this message translates to:
  /// **'Ticket Types'**
  String get ticketTypes;

  /// No description provided for @adult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get adult;

  /// No description provided for @ages12Plus.
  ///
  /// In en, this message translates to:
  /// **'Ages 12+'**
  String get ages12Plus;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @withValidID.
  ///
  /// In en, this message translates to:
  /// **'With valid ID'**
  String get withValidID;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @ages5to11.
  ///
  /// In en, this message translates to:
  /// **'Ages 5-11'**
  String get ages5to11;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @ticketsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Tickets Confirmed'**
  String get ticketsConfirmed;

  /// No description provided for @reservedTickets.
  ///
  /// In en, this message translates to:
  /// **'Reserved {tickets} ticket(s) for {date}.'**
  String reservedTickets(Object date, Object tickets);

  /// No description provided for @viewMyTickets.
  ///
  /// In en, this message translates to:
  /// **'View My Tickets'**
  String get viewMyTickets;

  /// No description provided for @museumEntryTicket.
  ///
  /// In en, this message translates to:
  /// **'Museum entry ticket'**
  String get museumEntryTicket;

  /// No description provided for @ticketID.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID'**
  String get ticketID;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @expiredStatus.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredStatus;

  /// No description provided for @showEntryCode.
  ///
  /// In en, this message translates to:
  /// **'Show entry code'**
  String get showEntryCode;

  /// No description provided for @noTicketsYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get noTicketsYet;

  /// No description provided for @ticketsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'When you buy tickets from the booking screen, they will appear here for entry.'**
  String get ticketsEmptyDesc;

  /// No description provided for @searchExhibits.
  ///
  /// In en, this message translates to:
  /// **'Search Exhibits'**
  String get searchExhibits;

  /// No description provided for @searchByExhibitName.
  ///
  /// In en, this message translates to:
  /// **'Search by exhibit name...'**
  String get searchByExhibitName;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Try a different word or check the spelling.'**
  String get noResultsFoundDesc;

  /// No description provided for @tapToViewDetailsAndAudioGuide.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details and audio guide'**
  String get tapToViewDetailsAndAudioGuide;

  /// No description provided for @currentTour.
  ///
  /// In en, this message translates to:
  /// **'Current tour'**
  String get currentTour;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @visitedLabel.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get visitedLabel;

  /// No description provided for @notVisitedYetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not visited yet'**
  String get notVisitedYetLabel;

  /// No description provided for @quizzesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Completed'**
  String get quizzesCompleted;

  /// No description provided for @totalQuizScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Quiz Score'**
  String get totalQuizScoreLabel;

  /// No description provided for @skippedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Skipped Quizzes'**
  String get skippedQuizzes;

  /// No description provided for @howWasYourVisit.
  ///
  /// In en, this message translates to:
  /// **'How was your visit today?'**
  String get howWasYourVisit;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience with the museum and Horus-Bot.'**
  String get rateYourExperience;

  /// No description provided for @overallRating.
  ///
  /// In en, this message translates to:
  /// **'Overall rating'**
  String get overallRating;

  /// No description provided for @feedbackAboutOptional.
  ///
  /// In en, this message translates to:
  /// **'What is this feedback about? (optional)'**
  String get feedbackAboutOptional;

  /// No description provided for @tellUsMoreOptional.
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get tellUsMoreOptional;

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'What worked well or could be improved?'**
  String get feedbackPrompt;

  /// No description provided for @writeFeedbackHere.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback here...'**
  String get writeFeedbackHere;

  /// No description provided for @feedbackUsedNote.
  ///
  /// In en, this message translates to:
  /// **'Feedback is used only for research and improving the visitor experience.'**
  String get feedbackUsedNote;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit feedback'**
  String get submitFeedback;

  /// No description provided for @excellentThankYou.
  ///
  /// In en, this message translates to:
  /// **'Excellent, thank you!'**
  String get excellentThankYou;

  /// No description provided for @greatExperience.
  ///
  /// In en, this message translates to:
  /// **'Great experience.'**
  String get greatExperience;

  /// No description provided for @overallGood.
  ///
  /// In en, this message translates to:
  /// **'Overall good.'**
  String get overallGood;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs some improvement.'**
  String get needsImprovement;

  /// No description provided for @notGoodExperience.
  ///
  /// In en, this message translates to:
  /// **'Not a good experience.'**
  String get notGoodExperience;

  /// No description provided for @pleaseAddRatingOrComment.
  ///
  /// In en, this message translates to:
  /// **'Please add a rating or a short comment first.'**
  String get pleaseAddRatingOrComment;

  /// No description provided for @memberSinceNote.
  ///
  /// In en, this message translates to:
  /// **'Member since {period}'**
  String memberSinceNote(Object period);

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
  /// **'Companion app for Horus-Bot'**
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
  /// **'Your companion to Horus-Bot.'**
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
  /// **'Your guided tour is starting. Follow Horus-Bot while using the app for extra details.'**
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
  /// **'Follow the robot and keep using the app for extra details.'**
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
  /// **'Arabic'**
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

  /// No description provided for @notificationExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected with Notifications'**
  String get notificationExplanationTitle;

  /// No description provided for @notificationExplanationBody.
  ///
  /// In en, this message translates to:
  /// **'Receive timely updates about your museum journey to make the most of your visit.'**
  String get notificationExplanationBody;

  /// No description provided for @notificationExampleTourStarting.
  ///
  /// In en, this message translates to:
  /// **'Your tour will start in 10 minutes'**
  String get notificationExampleTourStarting;

  /// No description provided for @notificationExampleNextExhibit.
  ///
  /// In en, this message translates to:
  /// **'Next exhibit is ahead: Tutankhamun Hall'**
  String get notificationExampleNextExhibit;

  /// No description provided for @notificationExampleQuizAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quick quiz available for Ancient Egypt'**
  String get notificationExampleQuizAvailable;

  /// No description provided for @notificationExampleTicketReminder.
  ///
  /// In en, this message translates to:
  /// **'Your museum visit is today'**
  String get notificationExampleTicketReminder;

  /// No description provided for @notificationExplanationAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get notificationExplanationAllow;

  /// No description provided for @notificationExplanationDecline.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notificationExplanationDecline;

  /// No description provided for @notificationPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications Disabled'**
  String get notificationPermissionDeniedTitle;

  /// No description provided for @notificationPermissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'To receive tour updates and reminders, enable notifications in your device settings.'**
  String get notificationPermissionDeniedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive'**
  String get notificationSettingsSubtitle;

  /// No description provided for @enableAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable All Notifications'**
  String get enableAllNotifications;

  /// No description provided for @disableAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Disable All Notifications'**
  String get disableAllNotifications;

  /// No description provided for @tourUpdatesCategory.
  ///
  /// In en, this message translates to:
  /// **'Tour Updates'**
  String get tourUpdatesCategory;

  /// No description provided for @tourUpdatesCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Tour starts, progress, and completion'**
  String get tourUpdatesCategoryDesc;

  /// No description provided for @exhibitRemindersCategory.
  ///
  /// In en, this message translates to:
  /// **'Exhibit Reminders'**
  String get exhibitRemindersCategory;

  /// No description provided for @exhibitRemindersCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Nearby exhibits and new discoveries'**
  String get exhibitRemindersCategoryDesc;

  /// No description provided for @quizRemindersCategory.
  ///
  /// In en, this message translates to:
  /// **'Quiz Reminders'**
  String get quizRemindersCategory;

  /// No description provided for @quizRemindersCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Quiz availability notifications'**
  String get quizRemindersCategoryDesc;

  /// No description provided for @guideRemindersCategory.
  ///
  /// In en, this message translates to:
  /// **'Guide Reminders'**
  String get guideRemindersCategory;

  /// No description provided for @guideRemindersCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask the guide suggestions'**
  String get guideRemindersCategoryDesc;

  /// No description provided for @museumNewsCategory.
  ///
  /// In en, this message translates to:
  /// **'Museum News'**
  String get museumNewsCategory;

  /// No description provided for @museumNewsCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Did you know facts and events'**
  String get museumNewsCategoryDesc;

  /// No description provided for @ticketRemindersCategory.
  ///
  /// In en, this message translates to:
  /// **'Ticket Reminders'**
  String get ticketRemindersCategory;

  /// No description provided for @ticketRemindersCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Visit and event reminders'**
  String get ticketRemindersCategoryDesc;

  /// No description provided for @systemAlertsCategory.
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get systemAlertsCategory;

  /// No description provided for @systemAlertsCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Connection and status updates'**
  String get systemAlertsCategoryDesc;

  /// No description provided for @notificationPermissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermissionStatus;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get notificationPermissionDenied;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Disable Notifications'**
  String get disableNotifications;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestions'**
  String get quickSuggestions;

  /// No description provided for @chatInfoPopup.
  ///
  /// In en, this message translates to:
  /// **'You can ask about tickets, events, hours, or exhibits.'**
  String get chatInfoPopup;

  /// No description provided for @supportConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Conversation'**
  String get supportConversationTitle;

  /// No description provided for @supportRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Support request not found'**
  String get supportRequestNotFound;

  /// No description provided for @supportReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Type your reply...'**
  String get supportReplyHint;

  /// No description provided for @supportRequestFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get supportRequestFrom;

  /// No description provided for @supportRequestCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get supportRequestCreatedAt;

  /// No description provided for @supportInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Inbox'**
  String get supportInboxTitle;

  /// No description provided for @supportNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No support requests'**
  String get supportNoRequests;
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
