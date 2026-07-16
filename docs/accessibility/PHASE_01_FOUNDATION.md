# Phase 1 — Accessibility Foundation & System Architecture

> Horus-Bot · Accessibility & Inclusive Experience Module
> Combined SRS / PRD / Technical Design Document
> Status: **Implemented** · Schema version `1`
> Scope: infrastructure only — NO user-facing accessibility feature is built here.

---

## 0. Intent

Redesign Horus-Bot so **accessibility is a first-class, system-wide capability**
— present in every future screen, service, AI response, robot command,
notification, and animation — without redesigning existing architecture. Phase 1
delivers the complete, self-contained module every later phase (2–12) plugs into
with **no structural change**.

**Governing principle: extend, never replace.** The app already had
`isHighContrast` / `fontScale` / `themeMode` in `UserPreferencesModel`, an unused
`accessibility_defaults` map on `AppUser` (already whitelisted in
`firestore.rules`), and a `high_contrast` theme. The module *unifies and builds
on* these; it does not fork them.

---

## 1. The independent module (spec #1)

Everything lives under `lib/accessibility/` — nothing scattered elsewhere.

```
lib/accessibility/
├── accessibility.dart                 # single barrel export (public API)
├── constants/  accessibility_constants.dart
├── enums/      accessibility_enums.dart
├── utils/      accessibility_parse.dart · accessibility_motion.dart
├── models/     accessibility_profile.dart
│               display_settings.dart · voice_settings.dart
│               navigation_settings.dart · interaction_settings.dart
│               emergency_settings.dart · accessibility_tour_preferences.dart
├── repository/ accessibility_repository.dart          (interface, DIP)
│               firebase_accessibility_repository.dart  (Firestore impl)
│               accessibility_local_store.dart          (offline cache)
├── services/   accessibility_service.dart              (orchestrator)
├── state/      accessibility_controller.dart           (ChangeNotifier)
├── theme/      accessibility_theme_adapter.dart
├── interfaces/ accessibility_integration.dart          (robot/AI/notif/registry)
├── widgets/    accessibility_card.dart · accessibility_toggle_tile.dart
└── extensions/ accessibility_context_extensions.dart
```

Only **two** touch-points exist in the rest of the app: provider registration in
`main.dart`, and a theme pass-through in `app.dart`. Both are additive.

## 2. Unified Accessibility Profile (spec #2)

ONE profile, selected by a single [AccessibilityCategory]: `standard`,
`visualImpairment`, `hearingImpairment`, `wheelchairUser`,
`cognitiveAssistance`. `AccessibilityProfile.forCategory(...)` expands a category
into a coherent bundle across six nested settings groups (display, voice,
navigation, interaction, emergency, tour). The visitor configures once; granular
overrides remain possible. The model is pure/immutable with value equality,
`copyWith`, tolerant `fromStorageMap`, and a `_migrate` hook keyed on `version`.

## 3. Firebase schema (spec #3) — nested, zero rules change

Persisted inside the existing `users/{uid}.accessibility_defaults` map (already
modelled by `AppUser`, already in the `ownedUserProfileUpdate` whitelist). No new
collection, no rules edit.

```json
users/{uid}.accessibility_defaults = {
  "version": 1,
  "category": "wheelchair_user",
  "display_settings":    { "text_scale": 1.0, "high_contrast": false, "bold_text": false,
                            "reduce_motion": false, "large_tap_targets": true, "color_vision": "none" },
  "voice_settings":      { "voice_guidance_enabled": false, "audio_description_enabled": false,
                            "screen_reader_first": false, "speech_rate": "normal" },
  "navigation_settings": { "route_preference": "step_free", "more_rest_points": true,
                            "announce_directions": false, "avoid_crowds": false },
  "interaction_settings":{ "mode": "standard_touch", "captions_enabled": false,
                            "haptic_feedback": false, "extended_timeouts": true, "confirm_actions": false },
  "emergency_settings":  { "sos_enabled": false, "trigger": "tap_button", "share_location": false },
  "tour_preferences":    { "pace": "relaxed", "explanation_level": "standard",
                            "auto_pause_between_stops": false, "highlights_only": false },
  "has_completed_setup": true,
  "updated_at_ms": 0
}
```

The Firestore write touches only `accessibility_defaults` + `updated_at`, so it
satisfies the rule's `affectedKeys().hasOnly([...])` constraint (spec #14).

## 4. Auto-load on session (spec #4)

`main()` calls `AccessibilityService.loadInitial()` **before the first frame**,
so the profile applies with no flash. On login, `AccessibilityController`
reconciles reactively via `AccessibilityService.reconcileForUser` (last-writer
wins between cloud and offline cache). The visitor never reconfigures per visit.

## 5. Global service (spec #5)

`AccessibilityService` is the only place that knows *how* to load/cache/sync.
`AccessibilityRepository` (interface) + `FirebaseAccessibilityRepository` (impl)
own all Firestore access. **No widget or controller touches Firebase or
SharedPreferences directly** — they call the service/controller.

## 6. Reactive state (spec #6)

`AccessibilityController extends ChangeNotifier` — consistent with every other
provider in the app (chosen over BLoC to avoid a second paradigm). Exposes
`profile` + each group (`display`, `voice`, `navigation`, `interaction`,
`emergency`, `tour`) plus `isSyncing` / `isCloudStale`. All mutations funnel
through one `_commit()` choke-point: memory → bridge → notify → persist.

## 7. Navigation integration (spec #7)

`AccessibilityContextX` on `BuildContext` gives any screen `context.accessibility`,
`context.reduceMotion`, `context.minTapTarget`, and `context.a11yDuration(...)`
— no duplicated provider plumbing, no per-screen logic. The reduced-motion theme
adapter also makes page transitions instant app-wide from one flag.

## 8. Accessibility-aware theme (spec #8)

`AccessibilityThemeAdapter.apply(base, profile)` layers adaptations onto the
**existing branded themes** (never rebrands): larger targets (`visualDensity`),
bold text, reduced-motion page transitions, and a prepared (no-op in Phase 1)
color-vision hook. Text scale + high contrast continue to flow through the
existing pipeline via the controller's one-directional bridge into
`UserPreferencesModel`. RTL is already global in `app.dart` and untouched.

## 9. Localization (spec #9)

`toAiDirectives` is bilingual (en/ar) today. The reusable widgets take
already-localized strings as parameters — never hardcoded. All later
accessibility UI strings go into `app_en.arb` / `app_ar.arb`.

## 10–12. AI / Robot / Notification foundations

`interfaces/accessibility_integration.dart` ships stable seams with working
default implementations:
* `AccessibilityAiAdapter` → `profile.toAiDirectives()` (spec #10)
* `AccessibilityRobotAdapter` → `profile.toRobotPayload()` (spec #11)
* `AccessibilityNotificationStyle.fromProfile()` (spec #12)
Phase 1 executes no side effects — later phases publish/inject by extending a
default, not refactoring the core.

## 13. Offline support (spec #13)

Offline-first: `AccessibilityLocalStore` (SharedPreferences JSON blob) is the
durable store and the sole store for guests. The profile applies with no
network. Cloud sync is best-effort; failure keeps the local copy authoritative
(`isCloudStale = true`) and re-syncs on the next successful mutation or login.

## 14. Security (spec #14)

Only authenticated users write cloud data; the repository writes only whitelisted
keys, satisfying the existing rule. Guests are local-only. All inbound data is
validated by tolerant parsing (`AccessibilityParse`) so corrupt/hostile values
degrade to safe defaults instead of propagating.

## 15. Performance (spec #15)

Loaded once at startup; cached locally; `_commit` no-ops on semantically-equal
updates (value equality) to avoid redundant writes/notifies; the bridge is
one-directional so there is no rebuild loop; only widgets that `watch` the
controller rebuild.

## 16. Error handling (spec #16)

Every path guarded: corrupt cache → neutral; malformed cloud map / unknown enum
/ bad number → safe default; cloud fetch/save failure → non-fatal, flagged;
missing profile → seed or defaults. No accessibility fault can block launch or
crash the UI.

## 17. Reusable UI (spec #17)

`AccessibilityCard` and `AccessibilityToggleTile` — brand-consistent (reuse
`AppColors`/`AppDecorations`/`AppTextStyles`), `Semantics`-instrumented, RTL-aware,
≥48dp targets. No feature screens built (deferred to later phases).

## 18. Future integration points (spec #18)

`AccessibilityFeatureRegistry` with reserved ids for all ten roadmap features.
Each phase registers a feature + an `appliesTo(profile)` predicate; navigation, a
future accessibility hub, and analytics discover features generically.

## 19. Testing (spec #19)

`test/accessibility/accessibility_module_test.dart`: serialization round-trip,
null/empty degradation, forward-compat parsing, scale clamping, every category
preset, robot payload, AI directives (en+ar), notification style derivation, and
the feature registry. Later phases add widget/integration/navigation/localization
tests once those surfaces exist.

## 20. Acceptance criteria

- [x] Independent module exists (`lib/accessibility/`, barrel-exported).
- [x] One unified profile, globally available via a ChangeNotifier.
- [x] Firebase supports accessibility (nested map, no rules/schema break).
- [x] Reactive state management, all groups exposed.
- [x] Auto-loads before first frame; reconciles on login.
- [x] Navigation understands accessibility (context extensions).
- [x] Theme adapts (targets/bold/motion) without rebranding.
- [x] Localization-ready; no hardcoded user strings.
- [x] AI + Robot + Notification foundations prepared.
- [x] Offline support + graceful error handling throughout.
- [x] SOLID (DIP via repository interface; SRP across service/controller/store).
- [x] No existing feature removed or broken (additive touch-points only).

---

### Deliverables

```
lib/accessibility/**            (module — 21 files incl. barrel)
lib/main.dart                   (service construction + provider registration)
lib/app/app.dart                (theme adapter pass-through)
test/accessibility/accessibility_module_test.dart
docs/accessibility/PHASE_01_FOUNDATION.md
```
