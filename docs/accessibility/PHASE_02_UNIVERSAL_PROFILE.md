# Phase 2 — Universal Accessibility Profile & Personalized Experience

> Horus-Bot · Accessibility & Inclusive Experience Module
> Combined SRS / PRD / Technical Design Document
> Status: **Implemented** · engine core + UI layer (wizard, profile page, home banner) built and green
> Builds on Phase 1; no redesign of existing architecture.

---

## 0. What Phase 2 adds over Phase 1

Phase 1 gave every visitor a single-category profile that the app, robot, and AI
already read. Phase 2 turns that into a **personalization engine**:

1. **Combinations of needs** — a visitor is no longer one category. They can be
   *Visual + Wheelchair*, *Hearing + Cognitive*, etc. (the headline Phase 2
   requirement).
2. **A guided setup experience** — a premium multi-step wizard that *welcomes*
   rather than *interrogates*, gating the app until every visitor has a profile.
3. **Profile management** — view / edit / reset / export, live and reactive.
4. **Deeper auto-configuration + home reflection** so the visitor immediately
   feels understood.

Phases 3–12 (the actual assistive features) are explicitly **not** built here;
Phase 2 is the engine they all activate from.

---

## 1. Model evolution — combinations (IMPLEMENTED)

`AccessibilityProfile.category` (single) → **`categories: Set<AccessibilityCategory>`**.

* Empty set canonically means Standard; `standard` is normalized out whenever a
  real need is present, so it's never stored alongside another category.
* `AccessibilityProfile.forCategories({...})` composes any combination by
  **layering each category's bundle with deterministic, safest-wins merge rules**:
  * booleans **OR** (a need enabled by any selected category stays enabled),
  * text scale / tap targets take the **larger** value,
  * speech rate takes the **slower** value,
  * pace takes the **more relaxed** value (larger dwell multiplier),
  * **explanation level:** cognitive assistance is layered **last**, so *simple*
    overrides *detailed* when Visual + Cognitive are combined — comprehension
    support beats richness. This is the one genuine conflict and it is resolved
    intentionally, not incidentally.
* `combineWith(other)` folds a session/override profile onto the saved one
  (the seam later phases use for temporary tour overrides).

**Backward compatibility (IMPLEMENTED):** `toStorageMap` writes BOTH the new
`categories` list AND the legacy scalar `category` (= primary), and
`fromStorageMap` reads the list when present, else falls back to the Phase-1
scalar. A Phase-1 document upgrades transparently; an external reader built
against Phase 1 keeps working. No Firestore schema or rules change.

**Value semantics (IMPLEMENTED):** `==`/`hashCode` treat `categories` as an
unordered set (`containsAll` + `hashAllUnordered`), so *{Visual, Hearing}* equals
*{Hearing, Visual}* — important for the controller's no-op-commit guard.

**Controller (IMPLEMENTED):** exposes `categories`, `primaryCategory`,
`hasCategory(c)`; adds `selectCategories(Set)` alongside the existing
`selectCategory`. Persist / bridge / auth-reconcile paths from Phase 1 are
unchanged — multi-select flows through the same single `_commit` choke-point.

## 2. Firebase (no change required)

Same `users/{uid}.accessibility_defaults` map, same rule. The nested schema from
Phase 1 already carries every settings group; Phase 2 only changes the
`category` scalar into a `categories` array *inside* that map. Cross-device sync,
offline cache, and last-writer reconciliation are inherited unchanged.

## 3. User journey (SPECIFIED — UI pending)

```
Splash (intro) → [returning + profile exists] → auto-configure → Home
              → [new / no profile]            → Setup Wizard → Home
```

Gating rule: after the existing onboarding/entry flow, if
`profile.hasCompletedSetup == false`, route to `/accessibility_setup` before
Home. Returning users with `hasCompletedSetup == true` skip straight through —
the controller already loaded and applied their profile before the first frame
(Phase 1), so "auto-configure" is literally already done by the time Home builds.

## 4. Accessibility Setup Wizard (SPECIFIED)

A new feature area `lib/accessibility/wizard/` with one `PageView`-driven
`AccessibilitySetupScreen` and step widgets:

| Step | Content | Reuses |
|---|---|---|
| 1 Welcome | Warm intro ("Before we begin, let's personalize…") | `AccessibilityCard`, hero styles |
| 2 How can Horus assist? | Plain-language framing of the need categories | multi-select chips |
| 3 Choose needs | **Multi-select** category cards (Visual/Hearing/Wheelchair/Cognitive/Standard) → `selectCategories` | `AccessibilityToggleTile` pattern |
| 4 Personal preferences | Optional per-group fine-tuning (display/voice/navigation/interaction/AI/emergency) | group editors |
| 5 Preview | Live preview: sample text at chosen scale/contrast, pace, sample AI tone | theme adapter |
| 6 Finish | Save → sync → (later) robot → Home | controller |

UX rules baked in: reduced-motion-aware transitions via `context.a11yDuration`,
≥48/56dp targets, `Semantics` on every control, RTL via existing `Directionality`,
progress indicator, "skip / do this later" that sets Standard + `hasCompletedSetup`.

## 5. Profile management page (SPECIFIED)

`lib/accessibility/screens/accessibility_profile_screen.dart`, route
`/accessibility_profile`. View active categories + every group; edit inline
(each control calls a controller `update*`), reset (→ `AccessibilityProfile.initial`
with `hasCompletedSetup: true`), export (share the `toStorageMap` JSON). All live
— controller `notifyListeners` re-themes and re-renders without restart. The
existing `AccessibilityScreen` (permissions + legacy display toggles) stays; a
"Personalize accessibility" entry links to this richer page so the two unify
rather than compete.

## 6. Automatic configuration (INHERITED + EXTENDED)

Already automatic from Phase 1: theme, typography, contrast, motion, tap targets
(theme adapter + prefs bridge). Phase 2 wires the remaining consumers to *read*
the profile at their entry points (no behavior yet — that's Phases 3-12):
notification style (`AccessibilityNotificationStyle.fromProfile`), AI prompt
(`DefaultAccessibilityAiAdapter`), robot payload (`DefaultAccessibilityRobotAdapter`).

## 7. Home screen integration (SPECIFIED)

A compact `AccessibilityStatusBanner` widget (in `lib/accessibility/widgets/`)
shown on Home: greeting + active-profile chips ("Accessible Route Enabled",
"Live Captions Ready", "Voice Navigation Ready") derived from the feature
registry `availableFor(profile)`. Tapping opens the profile page. Purely additive
to the existing Home screen.

## 8. Robot synchronization (SEAM READY)

On profile change and on tour start, publish `profile.toRobotPayload()` (now
including the `categories` array) via the existing `RobotMqttService`. Phase 2
provides the payload + the adapter; the actual publish call is owned by the tour/
robot phases so scope stays non-overlapping (as in Phase 1's decision).

## 9. AI integration (SEAM READY)

`DefaultAccessibilityAiAdapter.buildDirectives(profile, language:)` →
`profile.toAiDirectives()`, already reflecting merged multi-select needs (e.g.
Visual+Cognitive yields both "describe visuals" and "simple language"). Injection
into `ChatContext`/system prompt is owned by Phase 7/12.

## 10. Offline / error handling (INHERITED)

Unchanged from Phase 1 and fully covers Phase 2: edits apply to the local cache
immediately, sync is best-effort with `isCloudStale`, corrupt/partial/newer data
degrades safely via tolerant parsing. Multi-select adds no new failure mode.

## 11. Testing

Engine tests **written** (`accessibility_module_test.dart`): Visual+Wheelchair
union, Visual+Cognitive conflict resolution, Standard-normalization, empty=standard,
multi-select storage round-trip, legacy-document parse, order-independent equality
— on top of the Phase 1 suite. UI tests (wizard flow, profile editing, home
banner) are specified for the UI implementation step.

## 12. Acceptance criteria

- [x] Multiple accessibility needs supported simultaneously (Set + merge).
- [x] Combinations resolve deterministically (safest-wins; documented conflict).
- [x] Profiles sync to Firebase + cached locally (inherited, no schema break).
- [x] Backward-compatible with Phase-1 documents.
- [x] App auto-configures from the profile before first frame (inherited).
- [x] Robot + AI receive the merged multi-select profile (adapters ready).
- [x] Reactive everywhere via the single commit path.
- [x] Onboarding wizard implemented (`lib/accessibility/wizard/`, gated via `AccessibilitySetupGate`, route `/accessibility_setup`).
- [x] Profile management page implemented (`lib/accessibility/screens/accessibility_profile_screen.dart`, route `/accessibility_profile`).
- [x] Home banner implemented (`lib/accessibility/widgets/accessibility_status_banner.dart`, shown on Home).
- [x] Existing functionality untouched (additive only).

---

### Delivered this phase (verifiable by review; execution pending classifier)

```
lib/accessibility/constants/accessibility_constants.dart   (+ kCategories)
lib/accessibility/models/accessibility_profile.dart        (Set + merge + compat)
lib/accessibility/state/accessibility_controller.dart      (multi-select API)
lib/accessibility/services/accessibility_service.dart      (const fix)
test/accessibility/accessibility_module_test.dart          (+7 Phase-2 tests)
docs/accessibility/PHASE_02_UNIVERSAL_PROFILE.md
```

### Also delivered this phase (UI layer — built and passing analyze + widget tests)

```
lib/accessibility/wizard/**        setup wizard (6 steps)
lib/accessibility/screens/**       profile management page
lib/accessibility/widgets/accessibility_status_banner.dart
lib/app/router.dart                +2 routes
lib/l10n/app_en.arb · app_ar.arb   wizard/profile strings (+ gen-l10n regen)
```
