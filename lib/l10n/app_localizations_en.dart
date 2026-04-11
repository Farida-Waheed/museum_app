// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horus';

  @override
  String get exploreEgypt => 'Explore Egypt With Horus-Bot';

  @override
  String nextStop(Object location, Object time) {
    return 'Next stop: $location in $time min';
  }

  @override
  String get exhibits => 'Exhibits';

  @override
  String get visited => 'Visited';

  @override
  String get duration => 'Duration';

  @override
  String get todaysHighlights => 'Today\'s Highlights';

  @override
  String get mapPreview => 'Map Preview';

  @override
  String get fullView => 'Full View';

  @override
  String get horusBot => 'Horus';

  @override
  String get talkToHorusBot => 'Ask the Guide';

  @override
  String get askTheGuide => 'Ask the Guide';

  @override
  String get guideStatus => 'Guide Status';

  @override
  String get alwaysAvailable => 'Always available';

  @override
  String get discoverStoryBehind => 'Discover the story behind everything';

  @override
  String get aboutHorusBot => 'About the Guide';

  @override
  String get you => 'You';

  @override
  String get exhibit => 'Exhibit';

  @override
  String get guestUser => 'Guest User';

  @override
  String get chatHeaderTitle => 'Horus Guide';

  @override
  String get chatHeaderSubtitle =>
      'Ask your museum questions while you follow Horus-Bot.';

  @override
  String get micPermissionTitle => 'Microphone';

  @override
  String get micPermissionDenied => 'Microphone permission was denied.';

  @override
  String get micPermissionSettings =>
      'Please enable microphone access from Settings.';

  @override
  String get micListening => 'Listening... Speak now.';

  @override
  String get moreInfo => 'More info';

  @override
  String get moreInfoText =>
      'Ask about tickets, opening hours, events, exhibits, or directions.';

  @override
  String get humanSupportLabel => 'Request live human support';

  @override
  String get humanSupportAck => 'Live human support request received.';

  @override
  String get humanSupportRequested => 'Human support requested';

  @override
  String get humanSupportRequestPending =>
      'A human representative will respond shortly.';

  @override
  String get quickHelpTopics => 'Quick help topics';

  @override
  String get askButton => 'Ask';

  @override
  String robotArrivalIn(Object time) {
    return 'Arrival in $time';
  }

  @override
  String get supportRequestStatus => 'Request status';

  @override
  String get supportStatusPending => 'Pending';

  @override
  String get supportStatusInProgress => 'In Progress';

  @override
  String get supportStatusResolved => 'Resolved';

  @override
  String get chatLoading => 'Horus is thinking...';

  @override
  String get chatInputHint => 'Ask the Guide while you follow Horus-Bot.';

  @override
  String get exploreMuseum => 'Explore the museum';

  @override
  String get profile => 'Profile';

  @override
  String get map => 'Map';

  @override
  String get quiz => 'Quiz';

  @override
  String get liveTour => 'Live Tour';

  @override
  String get tourPlanner => 'Tour Planner';

  @override
  String get events => 'Events';

  @override
  String get achievements => 'Achievements';

  @override
  String get language => 'Language';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get feedback => 'Feedback';

  @override
  String get settings => 'Settings';

  @override
  String get privacyPermissions => 'Location Permission';

  @override
  String get privacyText =>
      'Horus-Bot uses Bluetooth and Location to guide you inside the museum.';

  @override
  String get deny => 'Deny';

  @override
  String get allow => 'Allow';

  @override
  String get mainGallery => 'Main exhibition gallery';

  @override
  String get comfortableApp => 'Make the app comfortable for you';

  @override
  String get adjustSettings =>
      'Adjust text size, contrast, and language to suit your needs.';

  @override
  String get displayText => 'Display & Text';

  @override
  String get highContrast => 'High contrast mode';

  @override
  String get highContrastSubtitle =>
      'Increase color and element contrast for low vision or low light.';

  @override
  String get appearanceMode => 'Appearance mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get textSize => 'Text size';

  @override
  String get smaller => 'Smaller';

  @override
  String get larger => 'Larger';

  @override
  String get appLanguage => 'App language';

  @override
  String get appLanguageSubtitle =>
      'Choose your preferred app language; Horus-Bot remains your tour leader.';

  @override
  String get saveNote => 'These settings are saved on this device only.';

  @override
  String get settingsAccessibility => 'Settings & Accessibility';

  @override
  String get done => 'Done';

  @override
  String get scanAnother => 'Scan Another';

  @override
  String get ticketVerified => 'Ticket Verified';

  @override
  String get invalidQr => 'Invalid QR Code';

  @override
  String get scanTicket => 'Scan Ticket';

  @override
  String get alignQr => 'Align QR Code within the frame';

  @override
  String get audioGuide => 'Audio Guide Mode';

  @override
  String get audioPlaying => 'Playing the audio guide...';

  @override
  String get audioNarration => 'Tap to listen to a short narration.';

  @override
  String get addedToBookmarks => 'Exhibit added to your list.';

  @override
  String get removedFromBookmarks => 'Exhibit removed from your list.';

  @override
  String get description => 'Description';

  @override
  String get origin => 'Origin';

  @override
  String get period => 'Period';

  @override
  String get gallery => 'Gallery';

  @override
  String get addToMyRoute => 'Add to my route';

  @override
  String get viewOnMap => 'View on map';

  @override
  String get addedToRoute => 'Added to your route.';

  @override
  String get openingMap => 'Opening the map at this gallery.';

  @override
  String get live => 'LIVE';

  @override
  String get robotDescribing =>
      'The robot is currently describing this exhibit.';

  @override
  String get liveTranscript => 'Live transcript';

  @override
  String get accessibilityMuteNote =>
      'You can mute the robot and follow only the text at any time.';

  @override
  String get guidedMode => 'Guided Mode';

  @override
  String get selfPacedMode => 'Self-paced Mode';

  @override
  String get currentStop => 'Current Stop';

  @override
  String get nextStopLabel => 'Next Stop';

  @override
  String get previousStop => 'Previous Stop';

  @override
  String get tourProgress => 'Tour Progress';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get skip => 'Skip';

  @override
  String get robotWaiting => 'Robot is waiting for you at the next stop.';

  @override
  String get robotMoving => 'Robot is moving to the next exhibit.';

  @override
  String get connectionLost => 'Connection lost. Reconnecting...';

  @override
  String get myJourney => 'My Journey';

  @override
  String get exhibitsFound => 'Exhibits Found';

  @override
  String get factsDiscovered => 'Facts Discovered';

  @override
  String get takeQuickQuiz => 'Take a quick quiz about this exhibit!';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get visitSummary => 'Visit Summary';

  @override
  String get endTour => 'End Tour';

  @override
  String get congrats => 'Congratulations!';

  @override
  String get visitComplete => 'You have completed your museum journey.';

  @override
  String get exhibitsVisited => 'Exhibits Visited';

  @override
  String get totalTime => 'Total Time';

  @override
  String get shareVisit => 'Share my visit';

  @override
  String get pioneer => 'Pioneer';

  @override
  String get pioneerDesc => 'Visit your first exhibit';

  @override
  String get scholar => 'Scholar';

  @override
  String get scholarDesc => 'Discover 5 facts';

  @override
  String get wayfinder => 'Wayfinder';

  @override
  String get wayfinderDesc => 'Complete a full wing tour';

  @override
  String get happeningNow => 'Happening Now';

  @override
  String get noEvents => 'No live events at the moment.';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get workshop => 'Workshop: Hieroglyphs 101';

  @override
  String get workshopDesc => 'Starts in 20 min at Hall C';

  @override
  String get talk => 'Talk: The Boy King';

  @override
  String get talkDesc => 'Starts at 2:00 PM at Main Theater';

  @override
  String get home => 'Home';

  @override
  String get tour => 'Tour';

  @override
  String get tickets => 'Tickets';

  @override
  String get museumNews => 'Museum News';

  @override
  String get seeAll => 'See All';

  @override
  String get dataAnonymous => 'Data is anonymous';

  @override
  String get analyticsNote => 'Movement heatmaps are only used for analytics';

  @override
  String get notNow => 'Not now';

  @override
  String get allowLocationAccess => 'Enable Location';

  @override
  String get locationPermissionBody =>
      'Horus-Bot uses your location to guide you through museum exhibits and help you follow the robot during your visit.';

  @override
  String get dataReassurance =>
      'Your data is anonymous and used only for navigation.';

  @override
  String get introSubtitle => 'Discover ancient wonders with Horus-Bot';

  @override
  String get introThe => 'The ';

  @override
  String get introEgyptian => 'Egyptian';

  @override
  String get introMuseums => 'Museums';

  @override
  String get introSubtitleFull =>
      'Explore Egypt with Horus-Bot and its companion app.';

  @override
  String get onboarding1Title => 'Welcome to Horus';

  @override
  String get onboarding1Desc =>
      'Step into a world of ancient wonders, where every artifact has a story to tell.';

  @override
  String get onboarding2Title => 'Your Personal Guide';

  @override
  String get onboarding2Desc =>
      'Ask questions, hear stories, and explore the museum with Horus-Bot and its companion app.';

  @override
  String get onboarding3Title => 'Explore Seamlessly';

  @override
  String get onboarding3Desc =>
      'Navigate through exhibits with ease and stay connected to your guide throughout your journey.';

  @override
  String get onboarding4Title => 'Discover More';

  @override
  String get onboarding4Desc =>
      'Uncover hidden stories, interact with exhibits, and make every visit unforgettable.';

  @override
  String get next => 'Next';

  @override
  String get startExploring => 'Start Exploring';

  @override
  String get recommendedForYou => 'Discover Artifacts';

  @override
  String get quizPromptTitle => 'Quiz Time';

  @override
  String get quizPromptDescription =>
      'Would you like to take the quiz for this exhibit?';

  @override
  String get later => 'Later';

  @override
  String get takeNow => 'Take Now';

  @override
  String get didYouKnow => 'Did You Know?';

  @override
  String get didYouKnowFact => 'Tutankhamun\'s mask contains 10kg of gold.';

  @override
  String get onlineStatus => '● Online';

  @override
  String get mapSub => 'Find exhibits and routes';

  @override
  String get exhibitsSub => 'Browse nearby artifacts';

  @override
  String get quizSub => 'Test your knowledge';

  @override
  String get liveTourSub => 'Follow Horus-Bot';

  @override
  String get scanExhibitsAR => 'Scan Exhibits with AR';

  @override
  String get visit => 'Visit';

  @override
  String get accountPreferences => 'Account & Preferences';

  @override
  String get extras => 'Extras';

  @override
  String get liveTourActive => 'Live Tour Active';

  @override
  String currentlyVisiting(Object location) {
    return 'Currently Visiting: $location';
  }

  @override
  String get followHorusBot => 'Follow Horus-Bot';

  @override
  String get startNavigation => 'Start Navigation';

  @override
  String robotHeadingTo(Object location) {
    return 'Robot heading to: $location';
  }

  @override
  String get exploreTheMuseum => 'Explore the Museum';

  @override
  String get followAndDiscover =>
      'Follow the robot and uncover the stories behind ancient artifacts.';

  @override
  String get museumMap => 'Museum Map';

  @override
  String get grandEgyptianMuseum => 'Grand Egyptian Museum';

  @override
  String get eastWingGoldenArtifacts => 'East Wing • Golden Artifacts';

  @override
  String get entrance => 'Entrance';

  @override
  String get explain => 'Explain';

  @override
  String get generateMyRoute => 'Generate My Route';

  @override
  String get customizeTourDescription =>
      'Customize your museum tour based on your interests and available time.';

  @override
  String get interestsQuestion => 'What are your interests?';

  @override
  String get visitorStatistics => 'Visitor Statistics';

  @override
  String get myTours => 'My Tours';

  @override
  String get savedExhibits => 'Saved Exhibits';

  @override
  String get learningProgress => 'Learning Progress';

  @override
  String get quickPreferences => 'Quick Preferences';

  @override
  String get signOut => 'Sign Out';

  @override
  String get explorerLabel => 'Explorer';

  @override
  String memberSince(Object period) {
    return 'Member since $period';
  }

  @override
  String get tours => 'Tours';

  @override
  String get artifactsLabel => 'Artifacts';

  @override
  String get quizScoreLabel => 'Quiz Score';

  @override
  String get newKingdomHighlights => 'New Kingdom Highlights';

  @override
  String get tutankhamunTreasures => 'Tutankhamun Treasures';

  @override
  String get museumTickets => 'Museum Tickets';

  @override
  String get bookTicketsEarly => 'Book your tickets early to save time.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get change => 'Change';

  @override
  String get ticketTypes => 'Ticket Types';

  @override
  String get adult => 'Adult';

  @override
  String get ages12Plus => 'Ages 12+';

  @override
  String get student => 'Student';

  @override
  String get withValidID => 'With valid ID';

  @override
  String get child => 'Child';

  @override
  String get ages5to11 => 'Ages 5-11';

  @override
  String get totalLabel => 'Total';

  @override
  String get continueLabel => 'Continue';

  @override
  String get ticketsConfirmed => 'Tickets Confirmed';

  @override
  String reservedTickets(Object date, Object tickets) {
    return 'Reserved $tickets ticket(s) for $date.';
  }

  @override
  String get viewMyTickets => 'View My Tickets';

  @override
  String get museumEntryTicket => 'Museum entry ticket';

  @override
  String get ticketID => 'Ticket ID';

  @override
  String get priceLabel => 'Price';

  @override
  String get activeStatus => 'Active';

  @override
  String get expiredStatus => 'Expired';

  @override
  String get showEntryCode => 'Show entry code';

  @override
  String get noTicketsYet => 'No tickets yet';

  @override
  String get ticketsEmptyDesc =>
      'When you buy tickets from the booking screen, they will appear here for entry.';

  @override
  String get searchExhibits => 'Search Exhibits';

  @override
  String get searchByExhibitName => 'Search by exhibit name...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noResultsFoundDesc =>
      'Try a different word or check the spelling.';

  @override
  String get tapToViewDetailsAndAudioGuide =>
      'Tap to view details and audio guide';

  @override
  String get currentTour => 'Current tour';

  @override
  String get progressLabel => 'Progress';

  @override
  String get durationLabel => 'Duration';

  @override
  String get completedLabel => 'Completed';

  @override
  String get visitedLabel => 'Visited';

  @override
  String get notVisitedYetLabel => 'Not visited yet';

  @override
  String get quizzesCompleted => 'Quizzes Completed';

  @override
  String get totalQuizScoreLabel => 'Total Quiz Score';

  @override
  String get skippedQuizzes => 'Skipped Quizzes';

  @override
  String get howWasYourVisit => 'How was your visit today?';

  @override
  String get rateYourExperience =>
      'Rate your experience with the museum and Horus-Bot.';

  @override
  String get overallRating => 'Overall rating';

  @override
  String get feedbackAboutOptional => 'What is this feedback about? (optional)';

  @override
  String get tellUsMoreOptional => 'Tell us more (optional)';

  @override
  String get feedbackPrompt => 'What worked well or could be improved?';

  @override
  String get writeFeedbackHere => 'Write your feedback here...';

  @override
  String get feedbackUsedNote =>
      'Feedback is used only for research and improving the visitor experience.';

  @override
  String get submitFeedback => 'Submit feedback';

  @override
  String get excellentThankYou => 'Excellent, thank you!';

  @override
  String get greatExperience => 'Great experience.';

  @override
  String get overallGood => 'Overall good.';

  @override
  String get needsImprovement => 'Needs some improvement.';

  @override
  String get notGoodExperience => 'Not a good experience.';

  @override
  String get pleaseAddRatingOrComment =>
      'Please add a rating or a short comment first.';

  @override
  String memberSinceNote(Object period) {
    return 'Member since $period';
  }

  @override
  String get museumExperience => 'Museum Experience';

  @override
  String get museumExperienceSub =>
      'Customize how Horus-Bot guides you through the museum.';

  @override
  String get autoFollow => 'Follow Horus-Bot automatically';

  @override
  String get nearbyAlerts => 'Show nearby exhibits';

  @override
  String get detailedExplanations => 'Enable exhibit explanations';

  @override
  String get permissionsCenter => 'Permissions';

  @override
  String get locationService => 'Location';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get microphone => 'Microphone';

  @override
  String get camera => 'Camera';

  @override
  String get notifications => 'Notifications';

  @override
  String get enable => 'Enable';

  @override
  String get settingsDisabled => 'Settings: Disabled';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'Version 1.0';

  @override
  String get appTagline => 'Companion app for Horus-Bot';

  @override
  String get developedBy => 'Developed by';

  @override
  String get organization => 'Benha University';

  @override
  String get department => 'Computer & Communication Engineering Program';

  @override
  String get projectInfo => 'Project Information';

  @override
  String get team => 'Team';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get tutankhamunHall => 'Tutankhamun Hall';

  @override
  String get fiveMinutesAway => '5 minutes away';

  @override
  String get tutankhamunMask => 'Tutankhamun Mask';

  @override
  String get goldenHallRecommended => 'Golden Hall • Recommended now';

  @override
  String get ancientPapyrus => 'Ancient Papyrus';

  @override
  String get westWingStory => 'West Wing • Story of Writing';

  @override
  String get canopicJars => 'Canopic Jars';

  @override
  String get southHallMummification => 'South Hall • Mummification Rituals';

  @override
  String get locationServiceSub =>
      'Used for indoor navigation and exhibit guidance';

  @override
  String get bluetoothSub => 'Connect to nearby robot beacons';

  @override
  String get cameraSub => 'Used for scanning QR tickets and AR view';

  @override
  String get notificationsSub => 'Stay updated on your tour and robot status';

  @override
  String get audioGuideSub => 'Automatically read exhibit information aloud.';

  @override
  String get reduceAnimations => 'Reduce Animations';

  @override
  String get reduceAnimationsSub =>
      'Simplifies motion effects for sensitive users.';

  @override
  String get simpleMode => 'Simple Mode';

  @override
  String get simpleModeSub => 'Larger buttons and simplified layout.';

  @override
  String get version => 'Version 1.0';

  @override
  String get aboutDesc => 'Your companion to Horus-Bot.';

  @override
  String get university => 'Benha University';

  @override
  String get program => 'Faculty of Computers and Artificial Intelligence';

  @override
  String get tourStartingTitle => 'Tour Starting';

  @override
  String get tourStartingMsg =>
      'Your guided tour is starting. Follow Horus-Bot while using the app for extra details.';

  @override
  String get nextExhibitTitle => 'Next Exhibit Ahead';

  @override
  String nextExhibitMsg(Object location) {
    return '$location is approaching.';
  }

  @override
  String get quizAvailableTitle => 'Quiz Available';

  @override
  String quizAvailableMsg(Object location) {
    return 'Test what you learned about $location.';
  }

  @override
  String get takeQuiz => 'Take Quiz';

  @override
  String get smartTipTitle => 'Tip from the Guide';

  @override
  String get robotNearbyTitle => 'Horus-Bot is nearby';

  @override
  String get robotNearbyMsg =>
      'Follow the robot and keep using the app for extra details.';

  @override
  String get permissionsTitle => 'App Permissions';

  @override
  String get permissionsSubtitle =>
      'Enable these features to get the most out of your museum visit.';

  @override
  String get locationPermissionTitle => 'Location Access';

  @override
  String get locationPermissionDesc =>
      'Used for indoor navigation, finding nearby exhibits, and following the robot.';

  @override
  String get notificationPermissionTitle => 'Notifications';

  @override
  String get notificationPermissionDesc =>
      'Receive alerts for tour starts, next exhibits, and quiz reminders.';

  @override
  String get cameraPermissionTitle => 'Camera Access';

  @override
  String get cameraPermissionDesc =>
      'Needed for scanning QR tickets and future AR features.';

  @override
  String get continueBtn => 'CONTINUE TO HOME';

  @override
  String get benhaUniversity => 'Benha University';

  @override
  String get facultyEngineeringShoubra => 'Faculty of Engineering at Shoubra';

  @override
  String get computerCommunicationProgram =>
      'Computer & Communication Engineering Program';

  @override
  String get drMohamedHussein => 'Dr. Mohamed Hussein';

  @override
  String youScored(int score, int total) {
    return 'You scored $score out of $total';
  }

  @override
  String get retry => 'RETRY';

  @override
  String get doneButton => 'DONE';

  @override
  String get guestVisitor => 'Guest Visitor';

  @override
  String get englishLanguage => 'English';

  @override
  String get arabicLanguage => 'Arabic';

  @override
  String get webPermissionsNote =>
      'Permissions are managed by your browser settings on web.';

  @override
  String get ticketConfirmation => 'Ticket confirmation';

  @override
  String get scanResult => 'Scan result';

  @override
  String get feedbackSubmitted => 'Feedback submitted';

  @override
  String get horusBotTitle => 'Horus-Bot';

  @override
  String get version1 => 'Version 1.0';

  @override
  String get smartAutonomousGuide => 'Smart Autonomous Museum Guide';

  @override
  String get projectDescription =>
      'Horus-Bot is a smart autonomous museum guide robot designed to enhance museum visitor experience through autonomous navigation, multilingual interaction, and a companion mobile application.';

  @override
  String get projectDescriptionLabel => 'Project Description';

  @override
  String get technologiesUsedLabel => 'Technologies Used';

  @override
  String get developedByLabel => 'Developed By';

  @override
  String get teamLabel => 'Team';

  @override
  String get supervisorLabel => 'Supervisor';

  @override
  String get copyrightYear => 'Copyright © 2026 Horus-Bot Project';

  @override
  String get notificationExplanationTitle =>
      'Stay Connected with Notifications';

  @override
  String get notificationExplanationBody =>
      'Receive timely updates about your museum journey to make the most of your visit.';

  @override
  String get notificationExampleTourStarting =>
      'Your tour will start in 10 minutes';

  @override
  String get notificationExampleNextExhibit =>
      'Next exhibit is ahead: Tutankhamun Hall';

  @override
  String get notificationExampleQuizAvailable =>
      'Quick quiz available for Ancient Egypt';

  @override
  String get notificationExampleTicketReminder => 'Your museum visit is today';

  @override
  String get notificationExplanationAllow => 'Allow Notifications';

  @override
  String get notificationExplanationDecline => 'Not Now';

  @override
  String get notificationPermissionDeniedTitle => 'Notifications Disabled';

  @override
  String get notificationPermissionDeniedBody =>
      'To receive tour updates and reminders, enable notifications in your device settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notificationSettingsSubtitle =>
      'Choose which notifications you want to receive';

  @override
  String get enableAllNotifications => 'Enable All Notifications';

  @override
  String get disableAllNotifications => 'Disable All Notifications';

  @override
  String get tourUpdatesCategory => 'Tour Updates';

  @override
  String get tourUpdatesCategoryDesc => 'Tour starts, progress, and completion';

  @override
  String get exhibitRemindersCategory => 'Exhibit Reminders';

  @override
  String get exhibitRemindersCategoryDesc =>
      'Nearby exhibits and new discoveries';

  @override
  String get quizRemindersCategory => 'Quiz Reminders';

  @override
  String get quizRemindersCategoryDesc => 'Quiz availability notifications';

  @override
  String get guideRemindersCategory => 'Guide Reminders';

  @override
  String get guideRemindersCategoryDesc => 'Ask the guide suggestions';

  @override
  String get museumNewsCategory => 'Museum News';

  @override
  String get museumNewsCategoryDesc => 'Did you know facts and events';

  @override
  String get ticketRemindersCategory => 'Ticket Reminders';

  @override
  String get ticketRemindersCategoryDesc => 'Visit and event reminders';

  @override
  String get systemAlertsCategory => 'System Alerts';

  @override
  String get systemAlertsCategoryDesc => 'Connection and status updates';

  @override
  String get notificationPermissionStatus => 'Notification Permission';

  @override
  String get notificationPermissionGranted => 'Enabled';

  @override
  String get notificationPermissionDenied => 'Disabled';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get disableNotifications => 'Disable Notifications';

  @override
  String get quickSuggestions => 'Quick suggestions';

  @override
  String get chatInfoPopup =>
      'You can ask about tickets, events, hours, or exhibits.';

  @override
  String get supportConversationTitle => 'Support Conversation';

  @override
  String get supportRequestNotFound => 'Support request not found';

  @override
  String get supportReplyHint => 'Type your reply...';

  @override
  String get supportRequestFrom => 'From';

  @override
  String get supportRequestCreatedAt => 'Created at';

  @override
  String get supportInboxTitle => 'Support Inbox';

  @override
  String get supportNoRequests => 'No support requests';
}
