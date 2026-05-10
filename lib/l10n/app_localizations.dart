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
  /// **'Horus-Bot'**
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

  /// No description provided for @robotQrInMuseumMode.
  ///
  /// In en, this message translates to:
  /// **'This is a robot QR code and cannot be used for museum entry.'**
  String get robotQrInMuseumMode;

  /// No description provided for @connectedReady.
  ///
  /// In en, this message translates to:
  /// **'Connected and ready. Your Horus-Bot can now start the tour.'**
  String get connectedReady;

  /// No description provided for @museumTicketInRobotMode.
  ///
  /// In en, this message translates to:
  /// **'This museum ticket is not valid for robot connection.'**
  String get museumTicketInRobotMode;

  /// No description provided for @notHorusBotQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a Horus-Bot robot code.'**
  String get notHorusBotQr;

  /// No description provided for @connectToHorusBot.
  ///
  /// In en, this message translates to:
  /// **'Connect to Horus-Bot'**
  String get connectToHorusBot;

  /// No description provided for @scanMuseumEntryTicket.
  ///
  /// In en, this message translates to:
  /// **'Scan Museum Entry Ticket'**
  String get scanMuseumEntryTicket;

  /// No description provided for @scanRobotQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold the robot QR code inside the frame to connect.'**
  String get scanRobotQrSubtitle;

  /// No description provided for @scanMuseumQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold your museum entry ticket QR code inside the frame.'**
  String get scanMuseumQrSubtitle;

  /// No description provided for @qrMuseumEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Museum Entry Scan'**
  String get qrMuseumEntryTitle;

  /// No description provided for @qrMuseumEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a Museum Entry QR for the gate. This will not connect to Horus-Bot.'**
  String get qrMuseumEntrySubtitle;

  /// No description provided for @qrRobotPairingTitle.
  ///
  /// In en, this message translates to:
  /// **'Robot Pairing'**
  String get qrRobotPairingTitle;

  /// No description provided for @qrRobotPairingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the physical Horus-Bot QR when you arrive. Your robot tour pass proves eligibility, but pairing is a separate scan.'**
  String get qrRobotPairingSubtitle;

  /// No description provided for @qrEntryVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry pass verified'**
  String get qrEntryVerifiedTitle;

  /// No description provided for @qrEntryVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Use this QR at the museum gate.'**
  String get qrEntryVerifiedMessage;

  /// No description provided for @qrMuseumInvalidMessage.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid Museum Entry QR.'**
  String get qrMuseumInvalidMessage;

  /// No description provided for @qrRobotTicketRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Robot tour ticket required'**
  String get qrRobotTicketRequiredTitle;

  /// No description provided for @qrRobotTicketRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please buy a robot tour ticket before pairing with Horus-Bot.'**
  String get qrRobotTicketRequiredMessage;

  /// No description provided for @qrRobotConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot connected'**
  String get qrRobotConnectedTitle;

  /// No description provided for @qrRobotConnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'You are ready to start your guided tour.'**
  String get qrRobotConnectedMessage;

  /// No description provided for @qrOpenLiveTour.
  ///
  /// In en, this message translates to:
  /// **'Open Live Tour'**
  String get qrOpenLiveTour;

  /// No description provided for @qrAlignCode.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code inside the frame'**
  String get qrAlignCode;

  /// No description provided for @qrReference.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get qrReference;

  /// No description provided for @simulateRobotScan.
  ///
  /// In en, this message translates to:
  /// **'Simulate Robot Scan'**
  String get simulateRobotScan;

  /// No description provided for @prototypeOnly.
  ///
  /// In en, this message translates to:
  /// **'Prototype only'**
  String get prototypeOnly;

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

  /// No description provided for @liveTourLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Tour Unavailable'**
  String get liveTourLockedTitle;

  /// No description provided for @liveTourLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect to Horus Bot to start your live guided tour'**
  String get liveTourLockedDesc;

  /// No description provided for @liveTourReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the robot QR code again to continue your guided tour.'**
  String get liveTourReconnectSubtitle;

  /// No description provided for @liveTourPausedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your tour is currently paused. Resume to continue.'**
  String get liveTourPausedDesc;

  /// No description provided for @scanQRToConnect.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code at museum entrance to connect'**
  String get scanQRToConnect;

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
  /// **'Ticket Confirmation'**
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

  /// No description provided for @welcomeToHorusBot.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Horus-Bot'**
  String get welcomeToHorusBot;

  /// No description provided for @howAreYouUsingTheAppToday.
  ///
  /// In en, this message translates to:
  /// **'How are you using the app today?'**
  String get howAreYouUsingTheAppToday;

  /// No description provided for @planMyVisit.
  ///
  /// In en, this message translates to:
  /// **'Plan My Visit'**
  String get planMyVisit;

  /// No description provided for @planMyVisitDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore the museum, buy tickets, and prepare your visit.'**
  String get planMyVisitDescription;

  /// No description provided for @startMyTour.
  ///
  /// In en, this message translates to:
  /// **'Start My Tour'**
  String get startMyTour;

  /// No description provided for @startMyTourDescription.
  ///
  /// In en, this message translates to:
  /// **'Use your tickets, connect to Horus-Bot, and begin the guided experience.'**
  String get startMyTourDescription;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (optional)'**
  String get phoneHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loggingIn;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Creating account'**
  String get signingUp;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registerFailed;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccess;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @viewTickets.
  ///
  /// In en, this message translates to:
  /// **'View Tickets'**
  String get viewTickets;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @buyTickets.
  ///
  /// In en, this message translates to:
  /// **'Buy Tickets'**
  String get buyTickets;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get loggedInAs;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @loginToViewTickets.
  ///
  /// In en, this message translates to:
  /// **'Log in to view your tickets'**
  String get loginToViewTickets;

  /// No description provided for @loginToStartTour.
  ///
  /// In en, this message translates to:
  /// **'Log in to start your tour'**
  String get loginToStartTour;

  /// No description provided for @accountRequired.
  ///
  /// In en, this message translates to:
  /// **'Account Required'**
  String get accountRequired;

  /// No description provided for @createOrLoginToPreserve.
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to save your tickets, payments, and robot tour access.'**
  String get createOrLoginToPreserve;

  /// No description provided for @accountRequiredForPurchase.
  ///
  /// In en, this message translates to:
  /// **'You need to create an account or log in before purchasing tickets.'**
  String get accountRequiredForPurchase;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @visitHistory.
  ///
  /// In en, this message translates to:
  /// **'Visit History'**
  String get visitHistory;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get accountAlreadyExists;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitDate;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get timeSlot;

  /// No description provided for @ticketsPlanVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Visit'**
  String get ticketsPlanVisitTitle;

  /// No description provided for @ticketsPlanVisitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose museum entry, add an optional Horus-Bot tour, and save everything to your account.'**
  String get ticketsPlanVisitSubtitle;

  /// No description provided for @ticketsAccountRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Account required'**
  String get ticketsAccountRequiredTitle;

  /// No description provided for @ticketsAccountRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account to save tickets, sync with your website account, keep robot photos, and preserve tour progress.'**
  String get ticketsAccountRequiredBody;

  /// No description provided for @ticketsLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account before checkout.'**
  String get ticketsLoginRequired;

  /// No description provided for @ticketsVisitDetails.
  ///
  /// In en, this message translates to:
  /// **'Visit Details'**
  String get ticketsVisitDetails;

  /// No description provided for @ticketsMuseumEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Museum Entry'**
  String get ticketsMuseumEntryTitle;

  /// No description provided for @ticketsMuseumEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select visitor categories and quantities for the museum gate pass.'**
  String get ticketsMuseumEntrySubtitle;

  /// No description provided for @ticketsRobotTourTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot Tour'**
  String get ticketsRobotTourTitle;

  /// No description provided for @ticketsRobotTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Robot tour eligibility is separate from museum entry.'**
  String get ticketsRobotTourSubtitle;

  /// No description provided for @ticketsNoRobotTour.
  ///
  /// In en, this message translates to:
  /// **'No Robot Tour'**
  String get ticketsNoRobotTour;

  /// No description provided for @ticketsNoRobotTourDesc.
  ///
  /// In en, this message translates to:
  /// **'Museum entry only. You can explore at your own pace.'**
  String get ticketsNoRobotTourDesc;

  /// No description provided for @ticketsStandardTour.
  ///
  /// In en, this message translates to:
  /// **'Standard Tour'**
  String get ticketsStandardTour;

  /// No description provided for @ticketsStandardTourDesc.
  ///
  /// In en, this message translates to:
  /// **'A ready-made Horus-Bot route for first-time visitors.'**
  String get ticketsStandardTourDesc;

  /// No description provided for @ticketsPersonalizedTour.
  ///
  /// In en, this message translates to:
  /// **'Personalized Tour'**
  String get ticketsPersonalizedTour;

  /// No description provided for @ticketsPersonalizedTourDesc.
  ///
  /// In en, this message translates to:
  /// **'Customize exhibits, themes, pace, accessibility, and photo spots.'**
  String get ticketsPersonalizedTourDesc;

  /// No description provided for @ticketsStandardConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard Tour Setup'**
  String get ticketsStandardConfigTitle;

  /// No description provided for @ticketsDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String ticketsDurationValue(int minutes);

  /// No description provided for @ticketsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get ticketsEnglish;

  /// No description provided for @ticketsArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get ticketsArabic;

  /// No description provided for @ticketsRecommendedRoute.
  ///
  /// In en, this message translates to:
  /// **'Recommended route: Tutankhamun highlights, royal mummies, ancient tools, and the grand statue atrium.'**
  String get ticketsRecommendedRoute;

  /// No description provided for @ticketsPersonalizedSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized Tour'**
  String get ticketsPersonalizedSummaryTitle;

  /// No description provided for @ticketsPersonalizedPhase3.
  ///
  /// In en, this message translates to:
  /// **'Customize your Horus-Bot experience with exhibits, themes, pacing, accessibility preferences, and storytelling style.'**
  String get ticketsPersonalizedPhase3;

  /// No description provided for @ticketsCustomizeTour.
  ///
  /// In en, this message translates to:
  /// **'Customize Tour'**
  String get ticketsCustomizeTour;

  /// No description provided for @ticketsComingNext.
  ///
  /// In en, this message translates to:
  /// **'Open Customize Tour to finish your personalized Horus-Bot plan.'**
  String get ticketsComingNext;

  /// No description provided for @tourCustomizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Your Personal Journey'**
  String get tourCustomizeTitle;

  /// No description provided for @tourCustomizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what Horus-Bot should focus on before your museum visit.'**
  String get tourCustomizeSubtitle;

  /// No description provided for @tourCustomizeExhibitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exhibits and artifacts'**
  String get tourCustomizeExhibitsTitle;

  /// No description provided for @tourCustomizeExhibitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the stops you want Horus-Bot to prioritize.'**
  String get tourCustomizeExhibitsSubtitle;

  /// No description provided for @tourCustomizeThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themes and interests'**
  String get tourCustomizeThemesTitle;

  /// No description provided for @tourCustomizeThemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shape the storytelling style for your guided route.'**
  String get tourCustomizeThemesSubtitle;

  /// No description provided for @tourCustomizeAccessibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility needs'**
  String get tourCustomizeAccessibilityTitle;

  /// No description provided for @tourCustomizeAccessibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell Horus-Bot how to make the route easier to follow.'**
  String get tourCustomizeAccessibilitySubtitle;

  /// No description provided for @tourCustomizeVisitorModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Visitor mode'**
  String get tourCustomizeVisitorModeTitle;

  /// No description provided for @tourCustomizePaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get tourCustomizePaceTitle;

  /// No description provided for @tourCustomizePhotoSpotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo spots'**
  String get tourCustomizePhotoSpotsTitle;

  /// No description provided for @tourCustomizePhotoSpotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include recommended places for photos during the tour.'**
  String get tourCustomizePhotoSpotsSubtitle;

  /// No description provided for @tourCustomizeAvoidCrowdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Avoid crowded areas'**
  String get tourCustomizeAvoidCrowdsTitle;

  /// No description provided for @tourCustomizeAvoidCrowdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prefer quieter paths when the museum route allows it.'**
  String get tourCustomizeAvoidCrowdsSubtitle;

  /// No description provided for @tourCustomizeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized tour summary'**
  String get tourCustomizeSummaryTitle;

  /// No description provided for @tourCustomizeSelectedExhibits.
  ///
  /// In en, this message translates to:
  /// **'Selected exhibits'**
  String get tourCustomizeSelectedExhibits;

  /// No description provided for @tourCustomizeSelectedThemes.
  ///
  /// In en, this message translates to:
  /// **'Selected themes'**
  String get tourCustomizeSelectedThemes;

  /// No description provided for @tourCustomizeNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get tourCustomizeNotSelected;

  /// No description provided for @tourCustomizeSave.
  ///
  /// In en, this message translates to:
  /// **'Save Personalized Tour'**
  String get tourCustomizeSave;

  /// No description provided for @tourCustomizeSelectExhibitError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one exhibit or artifact.'**
  String get tourCustomizeSelectExhibitError;

  /// No description provided for @tourCustomizeDurationError.
  ///
  /// In en, this message translates to:
  /// **'Choose a tour duration.'**
  String get tourCustomizeDurationError;

  /// No description provided for @tourCustomizeLanguageError.
  ///
  /// In en, this message translates to:
  /// **'Choose a storytelling language.'**
  String get tourCustomizeLanguageError;

  /// No description provided for @tourCustomizeVisitorModeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a visitor mode.'**
  String get tourCustomizeVisitorModeError;

  /// No description provided for @tourCustomizePaceError.
  ///
  /// In en, this message translates to:
  /// **'Choose a tour pace.'**
  String get tourCustomizePaceError;

  /// No description provided for @tourThemeAncientKings.
  ///
  /// In en, this message translates to:
  /// **'Ancient kings'**
  String get tourThemeAncientKings;

  /// No description provided for @tourThemeDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get tourThemeDailyLife;

  /// No description provided for @tourThemeMummies.
  ///
  /// In en, this message translates to:
  /// **'Mummies and afterlife'**
  String get tourThemeMummies;

  /// No description provided for @tourThemeSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols and mythology'**
  String get tourThemeSymbols;

  /// No description provided for @tourThemeArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get tourThemeArchitecture;

  /// No description provided for @tourThemeHiddenStories.
  ///
  /// In en, this message translates to:
  /// **'Hidden stories'**
  String get tourThemeHiddenStories;

  /// No description provided for @tourThemePhotoHighlights.
  ///
  /// In en, this message translates to:
  /// **'Photo highlights'**
  String get tourThemePhotoHighlights;

  /// No description provided for @tourAccessStepFree.
  ///
  /// In en, this message translates to:
  /// **'Step-free route'**
  String get tourAccessStepFree;

  /// No description provided for @tourAccessFewerStairs.
  ///
  /// In en, this message translates to:
  /// **'Fewer stairs'**
  String get tourAccessFewerStairs;

  /// No description provided for @tourAccessSeatingBreaks.
  ///
  /// In en, this message translates to:
  /// **'Seating breaks'**
  String get tourAccessSeatingBreaks;

  /// No description provided for @tourAccessSlowNarration.
  ///
  /// In en, this message translates to:
  /// **'Slower narration'**
  String get tourAccessSlowNarration;

  /// No description provided for @tourAccessHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High-contrast guidance'**
  String get tourAccessHighContrast;

  /// No description provided for @tourAccessAudioFirst.
  ///
  /// In en, this message translates to:
  /// **'Audio-first guidance'**
  String get tourAccessAudioFirst;

  /// No description provided for @tourVisitorAdults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get tourVisitorAdults;

  /// No description provided for @tourVisitorStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get tourVisitorStudents;

  /// No description provided for @tourVisitorKidsFamily.
  ///
  /// In en, this message translates to:
  /// **'Kids and family'**
  String get tourVisitorKidsFamily;

  /// No description provided for @tourVisitorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled visitors'**
  String get tourVisitorDisabled;

  /// No description provided for @tourPaceRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get tourPaceRelaxed;

  /// No description provided for @tourPaceNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get tourPaceNormal;

  /// No description provided for @tourPaceFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get tourPaceFast;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @ticketsOrderSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get ticketsOrderSummaryTitle;

  /// No description provided for @ticketsMuseumSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Museum subtotal'**
  String get ticketsMuseumSubtotal;

  /// No description provided for @ticketsRobotSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Robot tour subtotal'**
  String get ticketsRobotSubtotal;

  /// No description provided for @ticketsMockCheckoutNote.
  ///
  /// In en, this message translates to:
  /// **'Mock checkout for prototype. Payment and backend sync will be added later.'**
  String get ticketsMockCheckoutNote;

  /// No description provided for @ticketsCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get ticketsCheckout;

  /// No description provided for @ticketsSelectMuseumEntryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select at least one museum entry ticket before checkout.'**
  String get ticketsSelectMuseumEntryFirst;

  /// No description provided for @ticketsCompletePersonalizedTourFirst.
  ///
  /// In en, this message translates to:
  /// **'Customize and save your personalized tour before checkout.'**
  String get ticketsCompletePersonalizedTourFirst;

  /// No description provided for @ticketsPurchaseComplete.
  ///
  /// In en, this message translates to:
  /// **'Purchase complete. Your tickets were saved.'**
  String get ticketsPurchaseComplete;

  /// No description provided for @ticketId.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID'**
  String get ticketId;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @useQrAtMuseumEntrance.
  ///
  /// In en, this message translates to:
  /// **'Use this QR at the museum entrance'**
  String get useQrAtMuseumEntrance;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @includedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Included Features'**
  String get includedFeatures;

  /// No description provided for @startTourSetup.
  ///
  /// In en, this message translates to:
  /// **'Start Tour Setup'**
  String get startTourSetup;

  /// No description provided for @scanQrOnRobot.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR on the physical Horus-Bot robot to connect'**
  String get scanQrOnRobot;

  /// No description provided for @myTicketsWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTicketsWalletTitle;

  /// No description provided for @myTicketsWalletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your museum entry passes, robot tour eligibility, and order details are saved here.'**
  String get myTicketsWalletSubtitle;

  /// No description provided for @myTicketsSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your tickets'**
  String get myTicketsSignInTitle;

  /// No description provided for @myTicketsSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Your account saves tickets, robot photos, tour progress, and website sync.'**
  String get myTicketsSignInBody;

  /// No description provided for @myTicketsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get myTicketsEmptyTitle;

  /// No description provided for @myTicketsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Buy your museum entry ticket and optional Horus-Bot tour pass to see them here.'**
  String get myTicketsEmptyBody;

  /// No description provided for @myTicketsBuyTickets.
  ///
  /// In en, this message translates to:
  /// **'Buy Tickets'**
  String get myTicketsBuyTickets;

  /// No description provided for @myTicketsOrderCode.
  ///
  /// In en, this message translates to:
  /// **'Order #{code}'**
  String myTicketsOrderCode(String code);

  /// No description provided for @myTicketsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get myTicketsNotAvailable;

  /// No description provided for @myTicketsTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get myTicketsTotalPaid;

  /// No description provided for @myTicketsPurchasedAt.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get myTicketsPurchasedAt;

  /// No description provided for @myTicketsMuseumPassTitle.
  ///
  /// In en, this message translates to:
  /// **'Museum Entry Pass'**
  String get myTicketsMuseumPassTitle;

  /// No description provided for @myTicketsEntryQr.
  ///
  /// In en, this message translates to:
  /// **'Entry QR'**
  String get myTicketsEntryQr;

  /// No description provided for @myTicketsTotalVisitors.
  ///
  /// In en, this message translates to:
  /// **'Total visitors'**
  String get myTicketsTotalVisitors;

  /// No description provided for @myTicketsCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get myTicketsCategoryBreakdown;

  /// No description provided for @myTicketsNoCategoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No category breakdown saved.'**
  String get myTicketsNoCategoryBreakdown;

  /// No description provided for @myTicketsMuseumGateCode.
  ///
  /// In en, this message translates to:
  /// **'Museum gate pass code'**
  String get myTicketsMuseumGateCode;

  /// No description provided for @myTicketsMuseumQrExplanation.
  ///
  /// In en, this message translates to:
  /// **'This is for the museum gate only.'**
  String get myTicketsMuseumQrExplanation;

  /// No description provided for @myTicketsShowEntryQr.
  ///
  /// In en, this message translates to:
  /// **'Show Entry QR'**
  String get myTicketsShowEntryQr;

  /// No description provided for @myTicketsUseAtGate.
  ///
  /// In en, this message translates to:
  /// **'Use this at the museum gate.'**
  String get myTicketsUseAtGate;

  /// No description provided for @myTicketsRobotPassTitle.
  ///
  /// In en, this message translates to:
  /// **'Robot Tour Pass'**
  String get myTicketsRobotPassTitle;

  /// No description provided for @myTicketsRobotPassCode.
  ///
  /// In en, this message translates to:
  /// **'Robot tour pass code'**
  String get myTicketsRobotPassCode;

  /// No description provided for @myTicketsRobotPairingSeparate.
  ///
  /// In en, this message translates to:
  /// **'This proves your robot tour eligibility. Robot pairing is a separate scan.'**
  String get myTicketsRobotPairingSeparate;

  /// No description provided for @myTicketsPhysicalRobotQrNote.
  ///
  /// In en, this message translates to:
  /// **'Scan the physical Horus-Bot QR when you arrive to pair with the robot.'**
  String get myTicketsPhysicalRobotQrNote;

  /// No description provided for @myTicketsNoPreferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'No personalization details were saved with this pass.'**
  String get myTicketsNoPreferencesSaved;

  /// No description provided for @myTicketsPreferencesSummary.
  ///
  /// In en, this message translates to:
  /// **'Preferences summary'**
  String get myTicketsPreferencesSummary;

  /// No description provided for @myTicketsSelectedExhibitsCount.
  ///
  /// In en, this message translates to:
  /// **'Selected exhibits'**
  String get myTicketsSelectedExhibitsCount;

  /// No description provided for @myTicketsThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get myTicketsThemes;

  /// No description provided for @myTicketsVisitorMode.
  ///
  /// In en, this message translates to:
  /// **'Visitor mode'**
  String get myTicketsVisitorMode;

  /// No description provided for @myTicketsPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get myTicketsPace;

  /// No description provided for @myTicketsAccessibilityNeeds.
  ///
  /// In en, this message translates to:
  /// **'Accessibility needs'**
  String get myTicketsAccessibilityNeeds;

  /// No description provided for @myTicketsPhotoSpots.
  ///
  /// In en, this message translates to:
  /// **'Photo spots'**
  String get myTicketsPhotoSpots;

  /// No description provided for @myTicketsAvoidCrowds.
  ///
  /// In en, this message translates to:
  /// **'Avoid crowds'**
  String get myTicketsAvoidCrowds;

  /// No description provided for @myTicketsRouteSummary.
  ///
  /// In en, this message translates to:
  /// **'Route summary'**
  String get myTicketsRouteSummary;

  /// No description provided for @myTicketsRouteName.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get myTicketsRouteName;

  /// No description provided for @myTicketsRouteStops.
  ///
  /// In en, this message translates to:
  /// **'Route stops'**
  String get myTicketsRouteStops;

  /// No description provided for @myTicketsStandardRouteName.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot Highlights Route'**
  String get myTicketsStandardRouteName;

  /// No description provided for @myTicketsNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get myTicketsNone;

  /// No description provided for @myTicketsOpenLiveTour.
  ///
  /// In en, this message translates to:
  /// **'Open Live Tour'**
  String get myTicketsOpenLiveTour;

  /// No description provided for @myTicketsContinueTour.
  ///
  /// In en, this message translates to:
  /// **'Continue Tour'**
  String get myTicketsContinueTour;

  /// No description provided for @myTicketsViewSummary.
  ///
  /// In en, this message translates to:
  /// **'View Summary'**
  String get myTicketsViewSummary;

  /// No description provided for @myTicketsUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get myTicketsUsed;

  /// No description provided for @myTicketsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get myTicketsCancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @tourType.
  ///
  /// In en, this message translates to:
  /// **'Tour type'**
  String get tourType;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @homeExploreWithHorus.
  ///
  /// In en, this message translates to:
  /// **'Explore With Horus'**
  String get homeExploreWithHorus;

  /// No description provided for @homeWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}, follow Horus through the museum.'**
  String homeWelcomeUser(Object name);

  /// No description provided for @homeGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guest visit mode - follow Horus through the museum.'**
  String get homeGuestSubtitle;

  /// No description provided for @homeReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'READY TO EXPLORE?'**
  String get homeReadyLabel;

  /// No description provided for @homeReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to explore?'**
  String get homeReadyTitle;

  /// No description provided for @homeReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy your ticket or scan your robot QR when you arrive.'**
  String get homeReadySubtitle;

  /// No description provided for @homeConnectionLostLabel.
  ///
  /// In en, this message translates to:
  /// **'CONNECTION LOST'**
  String get homeConnectionLostLabel;

  /// No description provided for @homeReconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to Horus-Bot'**
  String get homeReconnectTitle;

  /// No description provided for @homeReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay close to the robot or scan again.'**
  String get homeReconnectSubtitle;

  /// No description provided for @homeTourCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'TOUR COMPLETED'**
  String get homeTourCompletedLabel;

  /// No description provided for @homeTourCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour completed'**
  String get homeTourCompletedTitle;

  /// No description provided for @homeTourCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Summary available inside your tour view.'**
  String get homeTourCompletedSubtitle;

  /// No description provided for @homeTourPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'TOUR PAUSED'**
  String get homeTourPausedLabel;

  /// No description provided for @homeTourPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume your museum tour'**
  String get homeTourPausedTitle;

  /// No description provided for @homeTourPausedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resume your museum tour when you are ready.'**
  String get homeTourPausedSubtitle;

  /// No description provided for @homeHorusSpeakingLabel.
  ///
  /// In en, this message translates to:
  /// **'HORUS IS SPEAKING NOW'**
  String get homeHorusSpeakingLabel;

  /// No description provided for @homeHorusMovingLabel.
  ///
  /// In en, this message translates to:
  /// **'HORUS IS MOVING'**
  String get homeHorusMovingLabel;

  /// No description provided for @homeHorusWaitingLabel.
  ///
  /// In en, this message translates to:
  /// **'HORUS IS WAITING'**
  String get homeHorusWaitingLabel;

  /// No description provided for @homeListenRobotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to the robot for the full story.'**
  String get homeListenRobotSubtitle;

  /// No description provided for @homeCurrentStopValue.
  ///
  /// In en, this message translates to:
  /// **'Current stop: {exhibit}'**
  String homeCurrentStopValue(Object exhibit);

  /// No description provided for @homeStayCloseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay close to your guide while moving.'**
  String get homeStayCloseSubtitle;

  /// No description provided for @homeAskOrContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask a short question or continue to the next stop.'**
  String get homeAskOrContinueSubtitle;

  /// No description provided for @homeMuseumTicketReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'MUSEUM TICKET READY'**
  String get homeMuseumTicketReadyLabel;

  /// No description provided for @homeMuseumTicketReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Museum ticket ready'**
  String get homeMuseumTicketReadyTitle;

  /// No description provided for @homeConnectTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Horus-Bot to start your guided tour.'**
  String get homeConnectTourSubtitle;

  /// No description provided for @homeConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED TO HORUS-BOT'**
  String get homeConnectedLabel;

  /// No description provided for @homeConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected to Horus-Bot'**
  String get homeConnectedTitle;

  /// No description provided for @homeNextStopCaps.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP'**
  String get homeNextStopCaps;

  /// No description provided for @homeTutankhamunHall.
  ///
  /// In en, this message translates to:
  /// **'Tutankhamun Hall'**
  String get homeTutankhamunHall;

  /// No description provided for @homeGoldenHall.
  ///
  /// In en, this message translates to:
  /// **'Golden Hall'**
  String get homeGoldenHall;

  /// No description provided for @homeMinutesAway.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes away - {location}'**
  String homeMinutesAway(Object location, Object minutes);

  /// No description provided for @homeBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery {percent}%'**
  String homeBattery(Object percent);

  /// No description provided for @homeSyncedNow.
  ///
  /// In en, this message translates to:
  /// **'synced just now'**
  String get homeSyncedNow;

  /// No description provided for @homeSyncedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'synced {minutes} min ago'**
  String homeSyncedMinutesAgo(Object minutes);

  /// No description provided for @homeSyncedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'synced {hours} hr ago'**
  String homeSyncedHoursAgo(Object hours);

  /// No description provided for @homeReconnectAction.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get homeReconnectAction;

  /// No description provided for @homeResumeTourAction.
  ///
  /// In en, this message translates to:
  /// **'Resume Tour'**
  String get homeResumeTourAction;

  /// No description provided for @homeContinueTourAction.
  ///
  /// In en, this message translates to:
  /// **'Continue Tour'**
  String get homeContinueTourAction;

  /// No description provided for @homeScanRobotQr.
  ///
  /// In en, this message translates to:
  /// **'Scan Robot QR'**
  String get homeScanRobotQr;

  /// No description provided for @homeNoTicketsYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets yet'**
  String get homeNoTicketsYet;

  /// No description provided for @homeMuseumAndRobotTicketsReady.
  ///
  /// In en, this message translates to:
  /// **'Museum and robot tour tickets ready'**
  String get homeMuseumAndRobotTicketsReady;

  /// No description provided for @homeOneTicketReady.
  ///
  /// In en, this message translates to:
  /// **'1 ticket ready'**
  String get homeOneTicketReady;

  /// No description provided for @homeTicketsSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} tickets saved'**
  String homeTicketsSaved(Object count);

  /// No description provided for @homeComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get homeComplete;

  /// No description provided for @homeStopsVisited.
  ///
  /// In en, this message translates to:
  /// **'Stops visited'**
  String get homeStopsVisited;

  /// No description provided for @homeTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get homeTimeLeft;

  /// No description provided for @homeCurrentExhibitCaps.
  ///
  /// In en, this message translates to:
  /// **'CURRENT EXHIBIT'**
  String get homeCurrentExhibitCaps;

  /// No description provided for @homeDiscoverArtifactsCaps.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER ARTIFACTS'**
  String get homeDiscoverArtifactsCaps;

  /// No description provided for @homeHorusExplainingStop.
  ///
  /// In en, this message translates to:
  /// **'Horus is explaining this stop'**
  String get homeHorusExplainingStop;

  /// No description provided for @homeContinueStory.
  ///
  /// In en, this message translates to:
  /// **'Continue the story'**
  String get homeContinueStory;

  /// No description provided for @homePreviewBeforeHorus.
  ///
  /// In en, this message translates to:
  /// **'Preview before Horus arrives'**
  String get homePreviewBeforeHorus;

  /// No description provided for @homeTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get homeTapForDetails;

  /// No description provided for @homeGoldenHallRecommended.
  ///
  /// In en, this message translates to:
  /// **'Golden Hall - Recommended now'**
  String get homeGoldenHallRecommended;

  /// No description provided for @homeFullMap.
  ///
  /// In en, this message translates to:
  /// **'Full map'**
  String get homeFullMap;

  /// No description provided for @homePairWithHorus.
  ///
  /// In en, this message translates to:
  /// **'Pair with Horus'**
  String get homePairWithHorus;

  /// No description provided for @homeStoredQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Stored QR codes'**
  String get homeStoredQrCodes;

  /// No description provided for @homeExploreArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Explore artifacts'**
  String get homeExploreArtifacts;

  /// No description provided for @homePlanVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Museum Visit'**
  String get homePlanVisitTitle;

  /// No description provided for @homePlanVisitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy tickets, prepare your tour, or start when you arrive.'**
  String get homePlanVisitSubtitle;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get homeQuickActions;

  /// No description provided for @homeMuseumUpdate.
  ///
  /// In en, this message translates to:
  /// **'MUSEUM UPDATE'**
  String get homeMuseumUpdate;

  /// No description provided for @liveTourCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour completed'**
  String get liveTourCompletedTitle;

  /// No description provided for @liveTourCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can view your summary and memories.'**
  String get liveTourCompletedSubtitle;

  /// No description provided for @liveTourPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour paused'**
  String get liveTourPausedTitle;

  /// No description provided for @liveTourPausedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resume when you are ready to continue with Horus-Bot.'**
  String get liveTourPausedSubtitle;

  /// No description provided for @liveTourFarTitle.
  ///
  /// In en, this message translates to:
  /// **'You are far from Horus-Bot'**
  String get liveTourFarTitle;

  /// No description provided for @liveTourFarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use map recovery to return to your guided route.'**
  String get liveTourFarSubtitle;

  /// No description provided for @liveTourMovingTitle.
  ///
  /// In en, this message translates to:
  /// **'Moving to next stop'**
  String get liveTourMovingTitle;

  /// No description provided for @liveTourMovingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is leading you to the next exhibit.'**
  String get liveTourMovingSubtitle;

  /// No description provided for @liveTourFinalTitle.
  ///
  /// In en, this message translates to:
  /// **'Final exhibit in your tour'**
  String get liveTourFinalTitle;

  /// No description provided for @liveTourFinalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are at the last guided stop.'**
  String get liveTourFinalSubtitle;

  /// No description provided for @liveTourGuidingTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is guiding now'**
  String get liveTourGuidingTitle;

  /// No description provided for @liveTourGuidingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay nearby and enjoy the story.'**
  String get liveTourGuidingSubtitle;

  /// No description provided for @liveTourTranscriptIntro.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is narrating this stop. New lines appear here during the tour.'**
  String get liveTourTranscriptIntro;

  /// No description provided for @liveTourSimWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the {exhibit}.'**
  String liveTourSimWelcome(Object exhibit);

  /// No description provided for @liveTourSimSignificance.
  ///
  /// In en, this message translates to:
  /// **'This artifact is extremely significant to our history.'**
  String get liveTourSimSignificance;

  /// No description provided for @liveTourSimDetails.
  ///
  /// In en, this message translates to:
  /// **'Notice the intricate details on the surface.'**
  String get liveTourSimDetails;

  /// No description provided for @liveTourSimDiscovery.
  ///
  /// In en, this message translates to:
  /// **'It was discovered during a major excavation.'**
  String get liveTourSimDiscovery;

  /// No description provided for @liveTourSimMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Let\'s move closer to observe the craftsmanship.'**
  String get liveTourSimMoveCloser;

  /// No description provided for @mapTourCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tour completed. Continue exploring exhibits freely.'**
  String get mapTourCompletedSubtitle;

  /// No description provided for @mapTourPausedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tour paused. Return to Horus-Bot to continue.'**
  String get mapTourPausedSubtitle;

  /// No description provided for @mapActiveTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Horus-Bot to your next stop.'**
  String get mapActiveTourSubtitle;

  /// No description provided for @mapRobotReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is ready to guide you.'**
  String get mapRobotReadySubtitle;

  /// No description provided for @mapConnectForNavigationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect from Home or Live Tour to start guided navigation.'**
  String get mapConnectForNavigationSubtitle;

  /// No description provided for @mapExplorePreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap an exhibit to preview its story.'**
  String get mapExplorePreviewSubtitle;

  /// No description provided for @mapReconnectToHorus.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to Horus-Bot'**
  String get mapReconnectToHorus;

  /// No description provided for @mapConnectToHorus.
  ///
  /// In en, this message translates to:
  /// **'Connect to Horus-Bot'**
  String get mapConnectToHorus;

  /// No description provided for @mapFollowingHorus.
  ///
  /// In en, this message translates to:
  /// **'Following Horus-Bot'**
  String get mapFollowingHorus;

  /// No description provided for @mapExploreOwnPace.
  ///
  /// In en, this message translates to:
  /// **'Explore at your own pace'**
  String get mapExploreOwnPace;

  /// No description provided for @mapCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get mapCurrent;

  /// No description provided for @mapNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get mapNext;

  /// No description provided for @mapNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get mapNow;

  /// No description provided for @mapGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get mapGuide;

  /// No description provided for @mapGuideActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get mapGuideActive;

  /// No description provided for @mapGuideFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get mapGuideFree;

  /// No description provided for @mapCurrentStop.
  ///
  /// In en, this message translates to:
  /// **'Current stop'**
  String get mapCurrentStop;

  /// No description provided for @mapNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get mapNextStop;

  /// No description provided for @mapVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get mapVisited;

  /// No description provided for @mapExhibit.
  ///
  /// In en, this message translates to:
  /// **'Exhibit'**
  String get mapExhibit;

  /// No description provided for @mapTourCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour completed'**
  String get mapTourCompletedTitle;

  /// No description provided for @mapTourCompletedStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can continue exploring the museum freely.'**
  String get mapTourCompletedStatusSubtitle;

  /// No description provided for @mapConnectingTitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Horus-Bot'**
  String get mapConnectingTitle;

  /// No description provided for @mapConnectingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot will appear on the map when ready.'**
  String get mapConnectingSubtitle;

  /// No description provided for @mapPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tour paused'**
  String get mapPausedTitle;

  /// No description provided for @mapPausedStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to Horus-Bot or resume your tour to continue.'**
  String get mapPausedStatusSubtitle;

  /// No description provided for @mapGuidingTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is guiding you'**
  String get mapGuidingTitle;

  /// No description provided for @mapGuidingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Horus to the next stop.'**
  String get mapGuidingSubtitle;

  /// No description provided for @mapReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is ready to guide you'**
  String get mapReadyTitle;

  /// No description provided for @mapReadyStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your guided tour when ready.'**
  String get mapReadyStatusSubtitle;

  /// No description provided for @mapNotConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Horus-Bot is not connected'**
  String get mapNotConnectedTitle;

  /// No description provided for @mapNotConnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reconnect when needed, or keep exploring exhibits freely.'**
  String get mapNotConnectedSubtitle;

  /// No description provided for @mapConnectForTourTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to Horus-Bot for your tour'**
  String get mapConnectForTourTitle;

  /// No description provided for @mapConnectForTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can also explore exhibits freely from here.'**
  String get mapConnectForTourSubtitle;

  /// No description provided for @mapExploreExhibitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore exhibits'**
  String get mapExploreExhibitsTitle;

  /// No description provided for @mapViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get mapViewDetails;

  /// No description provided for @mapFindHorusOnMap.
  ///
  /// In en, this message translates to:
  /// **'Find Horus on Map'**
  String get mapFindHorusOnMap;
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
