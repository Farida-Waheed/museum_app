/// Public entry point for the Accessibility & Inclusive Experience module.
///
/// Import this single file to access the whole module:
///   `import 'package:museum_app/accessibility/accessibility.dart';`
///
/// The module is self-contained (spec #1): models, enums, repository, service,
/// state, theme, widgets, extensions, interfaces, utils, and constants all live
/// under `lib/accessibility/`. No accessibility code is scattered elsewhere; the
/// only touch points in the rest of the app are the provider registration in
/// `main.dart` and the theme pass-through in `app.dart`.
library;

// Constants & enums
export 'constants/accessibility_constants.dart';
export 'enums/accessibility_enums.dart';

// Models
export 'models/accessibility_profile.dart';
export 'models/display_settings.dart';
export 'models/voice_settings.dart';
export 'models/navigation_settings.dart';
export 'models/interaction_settings.dart';
export 'models/emergency_settings.dart';
export 'models/accessibility_tour_preferences.dart';

// Data + service + state
export 'repository/accessibility_repository.dart';
export 'repository/firebase_accessibility_repository.dart';
export 'repository/accessibility_local_store.dart';
export 'services/accessibility_service.dart';
export 'state/accessibility_controller.dart';

// Integration seams
export 'interfaces/accessibility_integration.dart';

// Localization & presentation
export 'l10n/accessibility_l10n.dart';
export 'l10n/accessibility_category_presentation.dart';

// Theme, widgets, extensions, utils
export 'theme/accessibility_theme_adapter.dart';
export 'widgets/accessibility_card.dart';
export 'widgets/accessibility_toggle_tile.dart';
export 'widgets/accessibility_need_card.dart';
export 'widgets/accessibility_status_banner.dart';
export 'extensions/accessibility_context_extensions.dart';
export 'utils/accessibility_motion.dart';
export 'utils/accessibility_parse.dart';

// Screens & wizard
export 'wizard/accessibility_setup_screen.dart';
export 'wizard/accessibility_setup_gate.dart';
export 'screens/accessibility_profile_screen.dart';
