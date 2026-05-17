// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Horus-Bot';

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
  String get horusBot => 'Horus-Bot';

  @override
  String get talkToHorusBot => 'Ask Horus';

  @override
  String get askTheGuide => 'Ask Horus';

  @override
  String get askDuringActiveTourOnly =>
      'You can ask Horus during an active tour only.';

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
      'Use this when Horus cannot hear you clearly.';

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
  String get humanSupport => 'Human Support';

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
  String get askButton => 'Ask Horus';

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
  String get chatInputHint => 'Ask Horus during your live tour.';

  @override
  String get exploreMuseum => 'Explore the museum';

  @override
  String get profile => 'Profile';

  @override
  String get memories => 'Memories';

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
  String get robotQrInMuseumMode =>
      'This is a robot QR code and cannot be used for museum entry.';

  @override
  String get connectedReady =>
      'Connected and ready. Your Horus-Bot can now start the tour.';

  @override
  String get museumTicketInRobotMode =>
      'This museum ticket is not valid for robot connection.';

  @override
  String get notHorusBotQr => 'This QR code is not a Horus-Bot robot code.';

  @override
  String get connectToHorusBot => 'Connect to Horus-Bot';

  @override
  String get scanMuseumEntryTicket => 'Scan Museum Entry Ticket';

  @override
  String get scanRobotQrSubtitle =>
      'Hold the robot QR code inside the frame to connect.';

  @override
  String get scanMuseumQrSubtitle =>
      'Hold your museum entry ticket QR code inside the frame.';

  @override
  String get qrMuseumEntryTitle => 'Museum Entry Scan';

  @override
  String get qrMuseumEntrySubtitle =>
      'Scan a Museum Entry QR for the gate. This will not connect to Horus-Bot.';

  @override
  String get qrRobotPairingTitle => 'Robot Pairing';

  @override
  String get qrRobotPairingSubtitle =>
      'Scan the physical Horus-Bot QR when you arrive. Your Horus-Bot Tour Ticket proves eligibility, but Robot Pairing is a separate scan.';

  @override
  String get qrEntryVerifiedTitle => 'Museum Entry Ticket verified';

  @override
  String get qrEntryVerifiedMessage => 'Use this QR at the museum gate.';

  @override
  String get qrMuseumInvalidMessage => 'This is not a valid Museum Entry QR.';

  @override
  String get qrMuseumSignInRequiredMessage =>
      'Please sign in before verifying a museum entry ticket.';

  @override
  String get qrMuseumTicketNotFoundMessage =>
      'This museum ticket was not found.';

  @override
  String get qrMuseumTicketWrongUserMessage =>
      'This ticket does not belong to the signed-in account.';

  @override
  String get qrMuseumTicketInactiveMessage =>
      'This ticket is not active and cannot be used.';

  @override
  String get qrMuseumTicketExpiredMessage =>
      'This ticket date has already passed.';

  @override
  String get qrMuseumValidationFailedMessage =>
      'Unable to verify this museum ticket. Please try again.';

  @override
  String get qrRobotTicketRequiredTitle => 'Robot tour ticket required';

  @override
  String get qrRobotTicketRequiredMessage =>
      'Please buy a robot tour ticket before pairing with Horus-Bot.';

  @override
  String get qrRobotConnectedTitle => 'Horus-Bot connected';

  @override
  String get qrRobotConnectedMessage =>
      'You are ready to start your guided tour.';

  @override
  String get qrOpenLiveTour => 'Open Live Tour';

  @override
  String get qrAlignCode => 'Align the QR code inside the frame';

  @override
  String get qrReference => 'Ref';

  @override
  String get qrSignInRequiredTitle => 'Sign in required';

  @override
  String get qrSignInRequiredMessage =>
      'Please sign in before pairing with Horus-Bot.';

  @override
  String get qrRobotNotFoundTitle => 'Robot not found';

  @override
  String get qrRobotNotFoundMessage =>
      'This Horus-Bot is not registered. Please ask museum staff for help.';

  @override
  String get qrRobotUnavailableTitle => 'Horus-Bot unavailable';

  @override
  String get qrRobotUnavailableMessage =>
      'Horus-Bot is currently unavailable. Please try another robot or ask museum staff.';

  @override
  String get qrRobotBusyTitle => 'Horus-Bot is busy';

  @override
  String get qrRobotBusyMessage =>
      'This Horus-Bot is already paired with another tour. Please scan an available robot or ask museum staff.';

  @override
  String get qrPairingPermissionDeniedTitle => 'Pairing blocked';

  @override
  String get qrPairingPermissionDeniedMessage =>
      'This content is currently unavailable.';

  @override
  String get qrPairingNetworkMessage =>
      'Connection issue. Please check your internet connection and try again.';

  @override
  String get qrPairingUnknownMessage =>
      'Robot pairing failed. Please try again.';

  @override
  String get simulateRobotScan => 'Simulate Robot Scan';

  @override
  String get prototypeOnly => 'Prototype only';

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
  String get liveTourLockedTitle => 'Live Tour Unavailable';

  @override
  String get liveTourLockedDesc =>
      'Connect to Horus Bot to start your live guided tour';

  @override
  String get liveTourReconnectSubtitle =>
      'Scan the robot QR code again to continue your guided tour.';

  @override
  String get liveTourPausedDesc =>
      'Your tour is currently paused. Resume to continue.';

  @override
  String get scanQRToConnect => 'Scan QR code at museum entrance to connect';

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
  String get tapToViewDetailsAudioGuide =>
      'Tap to view details and audio guide';

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
  String get retry => 'Try again';

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
  String get ticketConfirmation => 'Ticket Confirmation';

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
      'Voice with Horus is primary. Type here only when the museum is too noisy.';

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

  @override
  String get welcomeToHorusBot => 'Welcome to Horus-Bot';

  @override
  String get howAreYouUsingTheAppToday => 'How are you using the app today?';

  @override
  String get planMyVisit => 'Plan My Visit';

  @override
  String get planMyVisitDescription =>
      'Explore the museum, buy tickets, and prepare your visit.';

  @override
  String get startMyTour => 'Start My Tour';

  @override
  String get startMyTourDescription =>
      'Use your tickets, connect to Horus-Bot, and begin the guided experience.';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Create Account';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phone => 'Phone Number';

  @override
  String get phoneHint => 'Enter your phone number (optional)';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signUp => 'Sign Up';

  @override
  String get loggingIn => 'Logging in';

  @override
  String get signingUp => 'Creating account';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registerFailed => 'Registration failed. Please try again.';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String get loginSuccess => 'Logged in successfully!';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get myAccount => 'My Account';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get viewTickets => 'View Tickets';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get buyTickets => 'Buy Tickets';

  @override
  String get loggedInAs => 'Logged in as';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get loginToViewTickets => 'Log in to view your tickets';

  @override
  String get loginToStartTour => 'Log in to start your tour';

  @override
  String get accountRequired => 'Account Required';

  @override
  String get createOrLoginToPreserve =>
      'Create an account or log in to save your tickets, payments, and robot tour access.';

  @override
  String get accountRequiredForPurchase =>
      'You need to create an account or log in before purchasing tickets.';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get visitHistory => 'Visit History';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get accountAlreadyExists => 'This email is already registered';

  @override
  String get visitDate => 'Visit Date';

  @override
  String get timeSlot => 'Time Slot';

  @override
  String get ticketsPlanVisitTitle => 'Plan Your Visit';

  @override
  String get ticketsPlanVisitSubtitle =>
      'Choose museum entry, add an optional Horus-Bot tour, and save everything to your account.';

  @override
  String get ticketsAccountRequiredTitle => 'Account required';

  @override
  String get ticketsAccountRequiredBody =>
      'Log in or create an account to save tickets, sync with your website account, keep robot photos, and preserve tour progress.';

  @override
  String get ticketsLoginRequired =>
      'Log in or create an account before checkout.';

  @override
  String get ticketsVisitDetails => 'Visit Details';

  @override
  String get ticketsMuseumEntryTitle => 'Museum Entry';

  @override
  String get ticketsMuseumEntrySubtitle =>
      'Select visitor categories and quantities for the Museum Entry Ticket.';

  @override
  String get ticketsRobotTourTitle => 'Horus-Bot Tour';

  @override
  String get ticketsRobotTourSubtitle =>
      'Robot tour eligibility is separate from museum entry.';

  @override
  String get ticketsNoRobotTour => 'No Robot Tour';

  @override
  String get ticketsNoRobotTourDesc =>
      'Museum entry only. You can explore at your own pace.';

  @override
  String get ticketsStandardTour => 'Standard Tour';

  @override
  String get ticketsStandardTourDesc =>
      'A ready-made Horus-Bot route for first-time visitors.';

  @override
  String get ticketsPersonalizedTour => 'Personalized Tour';

  @override
  String get ticketsPersonalizedTourDesc =>
      'Customize exhibits, themes, pace, accessibility, and photo spots.';

  @override
  String get ticketsStandardConfigTitle => 'Standard Tour Setup';

  @override
  String ticketsDurationValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get ticketsEnglish => 'English';

  @override
  String get ticketsArabic => 'Arabic';

  @override
  String get ticketsRecommendedRoute =>
      'Recommended route: Tutankhamun highlights, royal mummies, ancient tools, and the grand statue atrium.';

  @override
  String get ticketsPersonalizedSummaryTitle => 'Personalized Tour';

  @override
  String get ticketsPersonalizedPhase3 =>
      'Customize your Horus-Bot experience with exhibits, themes, pacing, accessibility preferences, and storytelling style.';

  @override
  String get ticketsCustomizeTour => 'Customize Tour';

  @override
  String get ticketsComingNext =>
      'Open Customize Tour to finish your personalized Horus-Bot plan.';

  @override
  String get tourCustomizeTitle => 'Build Your Personal Journey';

  @override
  String get tourCustomizeSubtitle =>
      'Choose what Horus-Bot should focus on before your museum visit.';

  @override
  String get tourCustomizeExhibitsTitle => 'Exhibits and artifacts';

  @override
  String get tourCustomizeExhibitsSubtitle =>
      'Pick the stops you want Horus-Bot to prioritize.';

  @override
  String get tourCustomizeThemesTitle => 'Themes and interests';

  @override
  String get tourCustomizeThemesSubtitle =>
      'Shape the storytelling style for your guided route.';

  @override
  String get tourCustomizeAccessibilityTitle => 'Accessibility needs';

  @override
  String get tourCustomizeAccessibilitySubtitle =>
      'Tell Horus-Bot how to make the route easier to follow.';

  @override
  String get tourCustomizeVisitorModeTitle => 'Visitor mode';

  @override
  String get tourCustomizePaceTitle => 'Pace';

  @override
  String get tourCustomizePhotoSpotsTitle => 'Photo spots';

  @override
  String get tourCustomizePhotoSpotsSubtitle =>
      'Include recommended places for photos during the tour.';

  @override
  String get tourCustomizeAvoidCrowdsTitle => 'Avoid crowded areas';

  @override
  String get tourCustomizeAvoidCrowdsSubtitle =>
      'Prefer quieter paths when the museum route allows it.';

  @override
  String get tourCustomizeSummaryTitle => 'Personalized tour summary';

  @override
  String get tourCustomizeSelectedExhibits => 'Selected exhibits';

  @override
  String get tourCustomizeSelectedThemes => 'Selected themes';

  @override
  String get tourCustomizeNotSelected => 'Not selected';

  @override
  String get tourCustomizeSave => 'Save Personalized Tour';

  @override
  String get tourCustomizeSelectExhibitError =>
      'Select at least one exhibit or artifact.';

  @override
  String get tourCustomizeDurationError => 'Choose a tour duration.';

  @override
  String get tourCustomizeLanguageError => 'Choose a storytelling language.';

  @override
  String get tourCustomizeVisitorModeError => 'Choose a visitor mode.';

  @override
  String get tourCustomizePaceError => 'Choose a tour pace.';

  @override
  String get tourThemeAncientKings => 'Ancient kings';

  @override
  String get tourThemeDailyLife => 'Daily life';

  @override
  String get tourThemeMummies => 'Mummies and afterlife';

  @override
  String get tourThemeSymbols => 'Symbols and mythology';

  @override
  String get tourThemeArchitecture => 'Architecture';

  @override
  String get tourThemeHiddenStories => 'Hidden stories';

  @override
  String get tourThemePhotoHighlights => 'Photo highlights';

  @override
  String get tourAccessStepFree => 'Step-free route';

  @override
  String get tourAccessFewerStairs => 'Fewer stairs';

  @override
  String get tourAccessSeatingBreaks => 'Seating breaks';

  @override
  String get tourAccessSlowNarration => 'Slower narration';

  @override
  String get tourAccessHighContrast => 'High-contrast guidance';

  @override
  String get tourAccessAudioFirst => 'Audio-first guidance';

  @override
  String get tourVisitorAdults => 'Adults';

  @override
  String get tourVisitorStudents => 'Students';

  @override
  String get tourVisitorKidsFamily => 'Kids and family';

  @override
  String get tourVisitorDisabled => 'Disabled visitors';

  @override
  String get tourPaceRelaxed => 'Relaxed';

  @override
  String get tourPaceNormal => 'Normal';

  @override
  String get tourPaceFast => 'Fast';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get ticketsOrderSummaryTitle => 'Order Summary';

  @override
  String get ticketsMuseumSubtotal => 'Museum subtotal';

  @override
  String get ticketsRobotSubtotal => 'Robot tour subtotal';

  @override
  String get ticketsMockCheckoutNote =>
      'Cash only for now. Pay at the museum counter when you arrive.';

  @override
  String get ticketsCheckout => 'Checkout';

  @override
  String get ticketsSelectMuseumEntryFirst =>
      'Select at least one museum entry ticket before checkout.';

  @override
  String get ticketsCompletePersonalizedTourFirst =>
      'Customize and save your personalized tour before checkout.';

  @override
  String get ticketsPurchaseComplete =>
      'Purchase complete. Your tickets were saved.';

  @override
  String get ticketId => 'Ticket ID';

  @override
  String get active => 'Active';

  @override
  String get expired => 'Expired';

  @override
  String get useQrAtMuseumEntrance => 'Use this QR at the museum entrance';

  @override
  String get minutes => 'minutes';

  @override
  String get includedFeatures => 'Included Features';

  @override
  String get startTourSetup => 'Start Tour Setup';

  @override
  String get scanQrOnRobot =>
      'Scan the QR on the physical Horus-Bot robot to connect';

  @override
  String get myTicketsWalletTitle => 'My Tickets';

  @override
  String get myTicketsWalletSubtitle =>
      'Your Museum Entry Ticket, Horus-Bot Tour Ticket, and booking details are saved here.';

  @override
  String get myTicketsSignInTitle => 'Sign in to view your tickets';

  @override
  String get myTicketsSignInBody =>
      'Your account saves tickets, robot photos, tour progress, and website sync.';

  @override
  String get myTicketsEmptyTitle => 'No tickets yet';

  @override
  String get myTicketsEmptyBody =>
      'Buy your Museum Entry Ticket and optional Horus-Bot Tour Ticket to see them here.';

  @override
  String get myTicketsBuyTickets => 'Buy Tickets';

  @override
  String get cashPaymentAtCounterTitle => 'Cash payment at counter';

  @override
  String cashPaymentAtCounterBody(String total) {
    return 'Cash only for now. Payment status: Pay at counter. Total due at the museum counter: $total.';
  }

  @override
  String get review => 'Review';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String get paymentStatusPayAtCounter => 'Payment status: Pay at counter';

  @override
  String get egyptianArabic => 'Egyptian Arabic';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get bookingCancelled => 'Booking cancelled.';

  @override
  String get paymentStatus => 'Payment status';

  @override
  String myTicketsOrderCode(String code) {
    return 'Order #$code';
  }

  @override
  String get myTicketsNotAvailable => 'Not available';

  @override
  String get myTicketsTotalPaid => 'Total due';

  @override
  String get myTicketsPurchasedAt => 'Purchased';

  @override
  String get myTicketsMuseumPassTitle => 'Museum Entry Ticket';

  @override
  String get myTicketsEntryQr => 'Entry QR';

  @override
  String get myTicketsTotalVisitors => 'Total visitors';

  @override
  String get myTicketsCategoryBreakdown => 'Category breakdown';

  @override
  String get myTicketsNoCategoryBreakdown => 'No category breakdown saved.';

  @override
  String get myTicketsMuseumGateCode => 'Museum Entry Ticket code';

  @override
  String get myTicketsMuseumQrExplanation =>
      'Museum Entry QR is used at the museum gate.';

  @override
  String get myTicketsShowEntryQr => 'Show Entry QR';

  @override
  String get myTicketsUseAtGate => 'Use this at the museum gate.';

  @override
  String get myTicketsRobotPassTitle => 'Horus-Bot Robot Tour Ticket';

  @override
  String get myTicketsRobotPassCode => 'Horus-Bot Tour Ticket code';

  @override
  String get myTicketsRobotPairingSeparate =>
      'Robot pairing happens later inside the mobile app by scanning the physical robot QR.';

  @override
  String get myTicketsPhysicalRobotQrNote =>
      'Your robot tour ticket will be ready in the app. Pairing happens at the museum by scanning the physical robot QR.';

  @override
  String get myTicketsNoPreferencesSaved =>
      'No personalization details were saved with this ticket.';

  @override
  String get myTicketsPreferencesSummary => 'Preferences summary';

  @override
  String get myTicketsSelectedExhibitsCount => 'Selected exhibits';

  @override
  String get myTicketsThemes => 'Themes';

  @override
  String get myTicketsVisitorMode => 'Visitor mode';

  @override
  String get myTicketsPace => 'Pace';

  @override
  String get myTicketsAccessibilityNeeds => 'Accessibility needs';

  @override
  String get myTicketsPhotoSpots => 'Photo spots';

  @override
  String get myTicketsAvoidCrowds => 'Avoid crowds';

  @override
  String get myTicketsRouteSummary => 'Route summary';

  @override
  String get myTicketsRouteName => 'Route name';

  @override
  String get myTicketsRouteStops => 'Route stops';

  @override
  String get myTicketsStandardRouteName => 'Horus-Bot Highlights Route';

  @override
  String get myTicketsNone => 'None';

  @override
  String get myTicketsOpenLiveTour => 'Open Live Tour';

  @override
  String get myTicketsContinueTour => 'Continue Tour';

  @override
  String get myTicketsViewSummary => 'View Summary';

  @override
  String get myTicketsUsed => 'Used';

  @override
  String get myTicketsCancelled => 'Cancelled';

  @override
  String get pending => 'Pending';

  @override
  String get status => 'Status';

  @override
  String get tourType => 'Tour type';

  @override
  String get close => 'Close';

  @override
  String get homeExploreWithHorus => 'Explore With Horus';

  @override
  String homeWelcomeUser(Object name) {
    return 'Welcome $name, follow Horus through the museum.';
  }

  @override
  String get homeGuestSubtitle =>
      'Guest visit mode - follow Horus through the museum.';

  @override
  String get homeReadyLabel => 'READY TO EXPLORE?';

  @override
  String get homeReadyTitle => 'Ready to explore?';

  @override
  String get homeReadySubtitle =>
      'Buy your ticket or scan your robot QR when you arrive.';

  @override
  String get homeConnectionLostLabel => 'CONNECTION LOST';

  @override
  String get homeReconnectTitle => 'Reconnect to Horus-Bot';

  @override
  String get homeReconnectSubtitle => 'Stay close to the robot or scan again.';

  @override
  String get homeTourCompletedLabel => 'TOUR COMPLETED';

  @override
  String get homeTourCompletedTitle => 'Tour completed';

  @override
  String get homeTourCompletedSubtitle =>
      'Summary available inside your tour view.';

  @override
  String get homeTourPausedLabel => 'TOUR PAUSED';

  @override
  String get homeTourPausedTitle => 'Resume your museum tour';

  @override
  String get homeTourPausedSubtitle =>
      'Resume your museum tour when you are ready.';

  @override
  String get homeHorusSpeakingLabel => 'HORUS IS SPEAKING NOW';

  @override
  String get homeHorusMovingLabel => 'HORUS IS MOVING';

  @override
  String get homeHorusWaitingLabel => 'HORUS IS WAITING';

  @override
  String get homeListenRobotSubtitle =>
      'Listen to the robot for the full story.';

  @override
  String homeCurrentStopValue(Object exhibit) {
    return 'Current stop: $exhibit';
  }

  @override
  String get homeStayCloseSubtitle => 'Stay close to your guide while moving.';

  @override
  String get homeAskOrContinueSubtitle =>
      'Ask a short question or continue to the next stop.';

  @override
  String get homeMuseumTicketReadyLabel => 'MUSEUM TICKET READY';

  @override
  String get homeMuseumTicketReadyTitle => 'Museum ticket ready';

  @override
  String get homeConnectTourSubtitle =>
      'Connect to Horus-Bot to start your guided tour.';

  @override
  String get homeConnectedLabel => 'CONNECTED TO HORUS-BOT';

  @override
  String get homeConnectedTitle => 'Connected to Horus-Bot';

  @override
  String get homeNextStopCaps => 'NEXT STOP';

  @override
  String get homeTutankhamunHall => 'Tutankhamun Hall';

  @override
  String get homeGoldenHall => 'Golden Hall';

  @override
  String homeMinutesAway(Object location, Object minutes) {
    return '$minutes minutes away - $location';
  }

  @override
  String homeBattery(Object percent) {
    return 'Battery $percent%';
  }

  @override
  String get homeSyncedNow => 'synced just now';

  @override
  String homeSyncedMinutesAgo(Object minutes) {
    return 'synced $minutes min ago';
  }

  @override
  String homeSyncedHoursAgo(Object hours) {
    return 'synced $hours hr ago';
  }

  @override
  String get homeReconnectAction => 'Reconnect';

  @override
  String get homeResumeTourAction => 'Resume Tour';

  @override
  String get homeContinueTourAction => 'Continue Tour';

  @override
  String get homeScanRobotQr => 'Scan Robot QR';

  @override
  String get homeNoTicketsYet => 'No tickets yet';

  @override
  String get homeMuseumAndRobotTicketsReady =>
      'Museum and robot tour tickets ready';

  @override
  String get homeOneTicketReady => '1 ticket ready';

  @override
  String homeTicketsSaved(Object count) {
    return '$count tickets saved';
  }

  @override
  String get homeComplete => 'Complete';

  @override
  String get homeStopsVisited => 'Stops visited';

  @override
  String get homeTimeLeft => 'Time left';

  @override
  String get homeCurrentExhibitCaps => 'CURRENT EXHIBIT';

  @override
  String get homeDiscoverArtifactsCaps => 'DISCOVER ARTIFACTS';

  @override
  String get homeHorusExplainingStop => 'Horus is explaining this stop';

  @override
  String get homeContinueStory => 'Continue the story';

  @override
  String get homePreviewBeforeHorus => 'Preview before Horus arrives';

  @override
  String get homeTapForDetails => 'Tap for details';

  @override
  String get homeGoldenHallRecommended => 'Golden Hall - Recommended now';

  @override
  String get homeFullMap => 'Full map';

  @override
  String get homePairWithHorus => 'Pair with Horus';

  @override
  String get homeStoredQrCodes => 'Stored QR codes';

  @override
  String get homeExploreArtifacts => 'Explore artifacts';

  @override
  String get homePlanVisitTitle => 'Plan Your Museum Visit';

  @override
  String get homePlanVisitSubtitle =>
      'Buy tickets, prepare your tour, or start when you arrive.';

  @override
  String get homeQuickActions => 'QUICK ACTIONS';

  @override
  String get homeMuseumUpdate => 'MUSEUM UPDATE';

  @override
  String get liveTourCompletedTitle => 'Tour completed';

  @override
  String get liveTourCompletedSubtitle =>
      'You can view your summary and memories.';

  @override
  String get liveTourPausedTitle => 'Tour paused';

  @override
  String get liveTourPausedSubtitle =>
      'Resume when you are ready to continue with Horus-Bot.';

  @override
  String get liveTourFarTitle => 'You are far from Horus-Bot';

  @override
  String get liveTourFarSubtitle =>
      'Use map recovery to return to your guided route.';

  @override
  String get liveTourMovingTitle => 'Moving to next stop';

  @override
  String get liveTourMovingSubtitle =>
      'Horus-Bot is leading you to the next exhibit.';

  @override
  String get liveTourFinalTitle => 'Final exhibit in your tour';

  @override
  String get liveTourFinalSubtitle => 'You are at the last guided stop.';

  @override
  String get liveTourGuidingTitle => 'Horus-Bot is guiding now';

  @override
  String get liveTourGuidingSubtitle => 'Stay nearby and enjoy the story.';

  @override
  String get liveTourTranscriptIntro =>
      'Horus-Bot is narrating this stop. New lines appear here during the tour.';

  @override
  String liveTourSimWelcome(Object exhibit) {
    return 'Welcome to the $exhibit.';
  }

  @override
  String get liveTourSimSignificance =>
      'This artifact is extremely significant to our history.';

  @override
  String get liveTourSimDetails =>
      'Notice the intricate details on the surface.';

  @override
  String get liveTourSimDiscovery =>
      'It was discovered during a major excavation.';

  @override
  String get liveTourSimMoveCloser =>
      'Let\'s move closer to observe the craftsmanship.';

  @override
  String get mapTourCompletedSubtitle =>
      'Tour completed. Continue exploring exhibits freely.';

  @override
  String get mapTourPausedSubtitle =>
      'Tour paused. Return to Horus-Bot to continue.';

  @override
  String get mapActiveTourSubtitle => 'Follow Horus-Bot to your next stop.';

  @override
  String get mapRobotReadySubtitle => 'Horus-Bot is ready to guide you.';

  @override
  String get mapConnectForNavigationSubtitle =>
      'Connect from Home or Live Tour to start guided navigation.';

  @override
  String get mapExplorePreviewSubtitle =>
      'Tap an exhibit to preview its story.';

  @override
  String get mapReconnectToHorus => 'Reconnect to Horus-Bot';

  @override
  String get mapConnectToHorus => 'Connect to Horus-Bot';

  @override
  String get mapFollowingHorus => 'Following Horus-Bot';

  @override
  String get mapExploreOwnPace => 'Explore at your own pace';

  @override
  String get mapCurrent => 'Current';

  @override
  String get mapNext => 'Next';

  @override
  String get mapNow => 'Now';

  @override
  String get mapGuide => 'Guide';

  @override
  String get mapGuideActive => 'Active';

  @override
  String get mapGuideFree => 'Free';

  @override
  String get mapCurrentStop => 'Current stop';

  @override
  String get mapNextStop => 'Next stop';

  @override
  String get mapVisited => 'Visited';

  @override
  String get mapExhibit => 'Exhibit';

  @override
  String get mapTourCompletedTitle => 'Tour completed';

  @override
  String get mapTourCompletedStatusSubtitle =>
      'You can continue exploring the museum freely.';

  @override
  String get mapConnectingTitle => 'Connecting to Horus-Bot';

  @override
  String get mapConnectingSubtitle =>
      'Horus-Bot will appear on the map when ready.';

  @override
  String get mapPausedTitle => 'Tour paused';

  @override
  String get mapPausedStatusSubtitle =>
      'Return to Horus-Bot or resume your tour to continue.';

  @override
  String get mapGuidingTitle => 'Horus-Bot is guiding you';

  @override
  String get mapGuidingSubtitle => 'Follow Horus to the next stop.';

  @override
  String get mapReadyTitle => 'Horus-Bot is ready to guide you';

  @override
  String get mapReadyStatusSubtitle => 'Start your guided tour when ready.';

  @override
  String get mapNotConnectedTitle => 'Horus-Bot is not connected';

  @override
  String get mapNotConnectedSubtitle =>
      'Reconnect when needed, or keep exploring exhibits freely.';

  @override
  String get mapConnectForTourTitle => 'Connect to Horus-Bot for your tour';

  @override
  String get mapConnectForTourSubtitle =>
      'You can also explore exhibits freely from here.';

  @override
  String get mapExploreExhibitsTitle => 'Explore exhibits';

  @override
  String get mapViewDetails => 'View Details';

  @override
  String get mapFindHorusOnMap => 'Find Horus on Map';
}
