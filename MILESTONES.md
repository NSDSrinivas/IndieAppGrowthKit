# Indie App Growth Kit — Build Milestones

This tracks the order features get built in, so each milestone lands on a tested foundation rather than parallel half-finished pieces. Every milestone maps to a section of [REQUIREMENTS.md](REQUIREMENTS.md) and is done only when its acceptance criteria pass — including exercising it from the sample app (see bottom).

Status legend: ⬜ not started · 🚧 in progress · ✅ done

## M0 — Project Scaffolding ✅
- SPM package (`Package.swift`, iOS 18+/macOS 15+, Swift 6.0), README, LICENSE, `.gitignore`.
- **Acceptance:** `swift build` and `swift test` succeed.

## M1 — Purchase Engine Core ⬜
- Abstract StoreKit 2 behind a protocol (e.g. `StoreProvider`) so purchase logic is unit-testable without hitting real StoreKit.
- Implement product loading, purchase initiation, `Transaction.updates` listening, `VerificationResult` handling, transaction finishing.
- Restore unfinished transactions on launch.
- Handle failure states: cancellation, decline, network error, pending/Ask-to-Buy.
- Support custom-amount tip tier (iOS 16.4+ API, available since our iOS 18+ floor).
- Works from app extensions/App Clips, not only the main app target.
- **Acceptance:** Unit tests cover success, cancellation, failure, pending, and restore paths using a mock `StoreProvider`. Manually verified against Xcode's local `.storekit` config in the sample app.

## M2 — Theming System ⬜
- Define the theme/style configuration object (colors, typography, shape, spacing, button styles, copy overrides) and view-builder injection points, used by every bundled view.
- **Acceptance:** A throwaway test view can be fully re-themed (colors, fonts, all copy) with zero default styling visible, proving no bundled view hardcodes appearance or text.

## M3 — Tip Jar UI ⬜
- Bundled SwiftUI Tip Jar view: tier list, custom-amount entry, localized pricing, light/dark + Dynamic Type, success feedback (haptics/confetti), completion callback, "Powered by Indie App Growth Kit" non-removable attribution link to the GitHub repo, VoiceOver labels/hints.
- Built on M1 (purchase engine) + M2 (theming).
- **Acceptance:** Manual purchase flow completes end-to-end in the sample app against the `.storekit` config, in both light/dark mode, with a custom theme applied, with VoiceOver on.

## M4 — Tip History ⬜
- API to query whether the user has tipped and their lifetime tip total from local transaction data.
- **Acceptance:** Unit test with mock transactions; sample app displays "You've tipped $X total" after a test purchase.

## M5 — Automatic Trigger Engine (shared infra) ⬜
- Generic, reusable engine: launch count, days-since-install, days-since-last-prompt cooldown, session count, custom developer signal — AND-combined, on-device persisted state (`UserDefaults`), dismiss-count cap.
- Built standalone first since the tip prompt, review prompt, and What's New prompt all reuse it with independent state namespaces.
- **Acceptance:** Unit tests simulate launch sequences and assert the engine fires/doesn't fire per each condition type and combination, including cooldown and dismiss-cap suppression.

## M6 — Automatic Tip Prompt ⬜
- Wire the Tip Jar (M3) to the trigger engine (M5) with its own condition set and state namespace; never fires if the user already tipped.
- **Acceptance:** Sample app demonstrates the auto-prompt firing after configured conditions (verified via the debug overlay, M11, or accelerated test config).

## M7 — Share App Hook ⬜
- `shareApp()` presenting the native share sheet with the App Store link, optional custom message, iPad popover anchor, outcome callback.
- **Acceptance:** Manual test on iPhone and iPad (popover positioning) in the sample app; share completion/cancellation callback verified.

## M8 — App Store Review Prompt ⬜
- `requestReview()` standalone API + automatic trigger via M5 with independent state/conditions.
- Optional review → feedback pre-prompt fallback (routes negative responses to M9 instead of `SKStoreReviewController`).
- **Acceptance:** Manual verification that `requestReview()` invokes the system prompt; automatic trigger fires per configured conditions; fallback correctly redirects to the feedback hook when declined.

## M9 — Feedback / Bug Report Hook ⬜
- `requestFeedback()` via mail composer or bundled themed form; used standalone and as the M8 fallback destination.
- **Acceptance:** Manual test of both mail-composer and bundled-form paths in the sample app; form submission callback delivers entered text to the host app.

## M10 — Cross-Promotion Hook ⬜
- API + themed bundled UI listing developer-configured other apps; taps open their App Store listings.
- **Acceptance:** Sample app configured with two dummy App Store IDs; tapping each opens the correct listing.

## M11 — Milestone Celebration Hook ⬜
- `celebrate(milestone:)` generalizing M3's success feedback for arbitrary developer-reported milestones; optional bundled tip/review nudge.
- **Acceptance:** Sample app fires a celebration from a "Simulate Milestone" test button and confirms feedback animation + optional nudges appear.

## M12 — What's New Prompt ⬜
- Once-per-version card wired to M5's trigger engine (version-change condition), themed, developer-supplied content.
- **Acceptance:** Sample app shows the card on a simulated version bump and not again on subsequent launches at the same version.

## M13 — Debug Overlay ⬜
- Debug-only overlay showing live trigger-engine state for all features (launch count, days since install/last-prompt, dismiss count, enabled state) with reset/simulate controls; stripped from release builds.
- **Acceptance:** Overlay visible in the sample app's debug build, absent in a release build; state resettable without reinstalling.

## M14 — Accessibility & Localization Pass ⬜
- Full VoiceOver audit across all bundled views; confirm localized pricing display across at least two locales/currencies in the sample app or simulator.
- **Acceptance:** VoiceOver walkthrough of every bundled view completes without unlabeled controls; pricing renders correctly under a non-USD simulator locale.

## M15 — Documentation & Release Prep ⬜
- Doc comments on all public API; README quickstart kept current; CHANGELOG started.
- **Acceptance:** No public symbol without a doc comment (spot-checked); README quickstart matches the actual API surface.

---

## Sample App — `Demo/IndieAppGrowthKitDemo`

A minimal SwiftUI app scaffolded alongside M0 (present from the start, not deferred to M1–M3) that exists purely to exercise the SDK end-to-end during development — not shipped, not part of the SPM package's public product.

- **Structure:** An `.executableTarget` (`IndieAppGrowthKitDemo`) declared in the root `Package.swift`, source at `Demo/IndieAppGrowthKitDemo/`, depending on the `IndieAppGrowthKit` library target directly — no separate Xcode project or workspace needed. Runs via `swift run IndieAppGrowthKitDemo`. Builds for macOS so it's runnable straight from the CLI; see `Demo/README.md` for why, and for how to spot-check iOS/theming milestones in Simulator once there's UI to check.
- **`HomeView`:** one row per feature, each labeled with the milestone that implements it and a status (`Not yet implemented` / `Ready`). A row moves from placeholder to a real, wired-up action as its milestone lands — a milestone isn't done until its `HomeView` row does the real thing, not until it merely compiles.
- **Planned additions as milestones land:**
  - `Demo.storekit` configuration file (tip tiers + custom amount) once M1 lands, plus an Xcode scheme pointed at it for real purchase-flow testing (see `Demo/README.md`).
  - A **Theme Switcher** screen once M2 lands, toggling between the default theme and a deliberately different custom theme (different colors/fonts/copy), to continuously prove every bundled view stays fully re-themeable.
  - A **Debug Panel** screen once M13 lands, embedding the debug overlay plus controls to fast-forward simulated launch count/days-since-install, so trigger conditions can be tested in seconds instead of days.
- **Purpose:** every milestone's acceptance criteria that says "verified in the sample app" is run against this target — it is the manual test harness for the whole SDK, kept in lockstep with the feature set.
- **Out of scope for the sample app:** App Store submission, real production product identifiers, or any polish beyond what's needed to exercise the SDK.
