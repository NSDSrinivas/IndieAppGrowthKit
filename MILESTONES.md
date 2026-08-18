# Indie App Growth Kit — Build Milestones

This tracks the order features get built in, so each milestone lands on a tested foundation rather than parallel half-finished pieces. Every milestone maps to a section of [REQUIREMENTS.md](REQUIREMENTS.md) and is done only when its acceptance criteria pass — including exercising it from the sample app (see bottom).

Status legend: ⬜ not started · 🚧 in progress · ✅ done

## M0 — Project Scaffolding ✅
- SPM package (`Package.swift`, iOS 18+/macOS 15+, Swift 6.0), README, LICENSE, `.gitignore`.
- **Acceptance:** `swift build` and `swift test` succeed.

## M1 — Purchase Engine Core ✅
- `StoreProviding` protocol abstracts StoreKit 2 (`Sources/IndieAppGrowthKit/Purchases/StoreProviding.swift`); `StoreKitProvider` is the real implementation, backed by `Product.products(for:)`, `Product.purchase()`, `Transaction.updates`, `Transaction.unfinished`, `Transaction.finish()`.
- `TipStore` (actor, `Purchases/TipStore.swift`) orchestrates: `start()` restores unfinished transactions then loads products; `purchase(identifier:)`/`purchase(_:)` submit a purchase, verify (`VerificationResult`), and finish on success. `TipPurchaseOutcome` (`.success`/`.pending`/`.cancelled`) models StoreKit's non-error outcomes explicitly rather than conflating them with thrown errors; genuine failures (declined, network, verification failure) propagate via `throws`.
- Wired into the public API: `IndieAppGrowthKit.configure(_:)` now builds a real `TipStore` from `Configuration.tipProductIdentifiers`, exposed as `IndieAppGrowthKit.tipStore`.
- **Scope change found during implementation:** the "custom amount" tip tier from REQUIREMENTS.md was descoped for v1. `Product`'s custom-amount purchase path goes through Apple's Advanced Commerce API, which requires the developer's own backend to produce a signed JWS per purchase — that's a hard requirement for a server, which conflicts with this SDK's no-backend design goal. REQUIREMENTS.md updated accordingly; v1 supports any number of discrete preset tiers instead.
- **Testing strategy note:** `Product`/`Transaction` have no public initializers, so a hand-written mock can't fabricate a successful purchase or a real transaction — only Apple's StoreKitTest framework (`SKTestSession`, backed by a `.storekit` config) can exercise those paths, and `SKTestSession` itself only works inside a code-signed, entitled host app (not a bare CLI `swift test` binary). So test coverage is split in two: `TipStoreTests.swift` uses a hand-written `MockStoreProvider` for everything that doesn't need a real `Product`/`Transaction` (error propagation, product-not-found, no-op restore) and runs everywhere including CI; `TipStoreStoreKitTestTests.swift` exercises the real success/restore paths via `SKTestSession` and `TestTips.storekit`, skipping itself (not failing) with `XCTSkip` when the sandbox lacks the StoreKit testing entitlement — run it from Xcode to get real coverage.
- App-extension/App-Clip friendliness carries forward as a non-functional requirement, not independently verified at this milestone (needs a real extension target to check, deferred to later manual verification alongside the sample app).
- **Acceptance:** `swift test` passes with 0 failures (4 run, 3 gracefully skipped outside Xcode). `swift build`/`swift run IndieAppGrowthKitDemo` succeed; the demo's "Purchase Engine (real)" row in `HomeView` calls `IndieAppGrowthKit.tipStore.start()` and lets you buy a tip, so the milestone is exercised from the sample app as required — full purchase-flow verification against `Demo.storekit` still needs Xcode (see Demo/README.md), since that's the same StoreKitTest entitlement constraint.

## M2 — Theming System ✅
- `TipJarTheme` (`Sources/IndieAppGrowthKit/Theming/TipJarTheme.swift`): `Colors`, `Typography`, `Metrics`, and `Strings` (all user-facing copy, so localization/rewording doesn't need a fork) sub-structs, plus `.default`.
- `\.tipJarTheme` environment value and `View.tipJarTheme(_:)` modifier (`TipJarTheme+Environment.swift`) — the injection mechanism every future bundled view (M3 onward) will read from instead of hardcoding appearance.
- Per-element view-builder injection (custom tier row/CTA content) is deferred to M3, since there's no real bundled view to attach builders to yet — tracked there, not dropped.
- **Acceptance:** `TipJarThemeTests.swift` proves the environment plumbing works (default value, custom value round-trips, distinct from default). `Demo/IndieAppGrowthKitDemo/ThemePreviewView.swift` is the throwaway test view: a "Theme Switcher" row in the sample app toggles between `.default` and a deliberately extreme custom theme (different colors, fonts, corner radius, and every string) on a view that reads every themeable property — nothing left hardcoded.

## M3 — Tip Jar UI ✅
- `TipJarView<TierContent: View>` (`Sources/IndieAppGrowthKit/UI/TipJarView.swift`): loads products via a `TipStore`, renders one row per tier (default: `DefaultTierRow`, fully replaceable via the `tierContent` view builder — the per-element customization point promised in REQUIREMENTS.md), reports `TipJarCompletion` (`.success`/`.cancelled`/`.pending`/`.failed`) per attempt.
- Success feedback: `SuccessHaptic` (`UINotificationFeedbackGenerator` on iOS, no-op elsewhere) + a dependency-free `ConfettiView` overlay, both from `UI/SuccessFeedback.swift`.
- Localized pricing via `Product.displayPrice`/`displayName` directly (already locale-correct from StoreKit); light/dark and Dynamic Type come for free from reading system fonts/colors through the theme rather than hardcoding either.
- The non-removable "Powered by Indie App Growth Kit" link (`IndieAppGrowthKitLinks.repository`) is always rendered, styled through the theme like everything else.
- Accessibility: each tier row is one combined accessibility element with label (product name), value (price), and hint (the themed purchase-button copy); the title carries the `.isHeader` trait.
- **Acceptance:** `TipJarViewSupportTests.swift` covers `TipJarCompletion` equality and the repository link. `swift build`/`swift run IndieAppGrowthKitDemo` succeed with no crash. The demo's "Bundled Tip Jar UI" row presents the real view. Full manual verification (purchase flow end-to-end, light/dark, custom theme, VoiceOver) needs Xcode + `Demo.storekit` (now checked in) per the same StoreKitTest entitlement constraint noted in M1 — tracked as a standing manual QA step before any release, not blocking further milestone development.

## M4 — Tip History ✅
- `TipHistory` (`Sources/IndieAppGrowthKit/Purchases/TipHistory.swift`): `hasTipped`, `tipCount`, and `totalsByCurrency` (a dictionary since a user could tip across storefronts/currencies over the app's lifetime, not just one running total).
- `TipStore.tipHistory()` computes it by walking `StoreProviding.allTransactions()` (new protocol method; `StoreKitProvider` backs it with `Transaction.all`), filtering to this store's product identifiers, and summing `transaction.price`/`transaction.currency` per verified transaction — purely local, no server round-trip, consistent with the SDK's no-backend design.
- **Acceptance:** `TipHistoryTests.swift` (mock-based, runs everywhere) covers the empty-history case. The demo's "Tip History (real)" row calls `IndieAppGrowthKit.tipStore.tipHistory()` and displays the result; full verification of a non-empty history needs a real purchase first (same Xcode + `Demo.storekit` path as M1/M3).

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
  - `Demo.storekit` configuration file (preset tip tiers) plus an Xcode scheme pointed at it for real purchase-flow testing (see `Demo/README.md`).
  - A **Theme Switcher** screen once M2 lands, toggling between the default theme and a deliberately different custom theme (different colors/fonts/copy), to continuously prove every bundled view stays fully re-themeable.
  - A **Debug Panel** screen once M13 lands, embedding the debug overlay plus controls to fast-forward simulated launch count/days-since-install, so trigger conditions can be tested in seconds instead of days.
- **Purpose:** every milestone's acceptance criteria that says "verified in the sample app" is run against this target — it is the manual test harness for the whole SDK, kept in lockstep with the feature set.
- **Out of scope for the sample app:** App Store submission, real production product identifiers, or any polish beyond what's needed to exercise the SDK.
