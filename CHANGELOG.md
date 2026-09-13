# Changelog

All notable changes to Indie App Growth Kit are documented here. Releases are tagged `vX.Y.Z` and follow [Semantic Versioning](https://semver.org/). See [MILESTONES.md](MILESTONES.md) for the detailed build log behind each entry.

## Unreleased

## [2.3.0] - 2026-09-13

### Added

- The Tip Jar now shows a blocking, themed progress loader for the full purchase attempt after a user selects a tip. Its default “Processing tip…” label can be customized with `TipJarTheme.Strings.purchaseProgressTitle`; purchase completion continues to report success, failure, cancellation, or pending status to the consuming app.

## [2.2.0] - 2026-09-12

### Added

- `ReviewPrompt.openReviewPage(appStoreID:)` opens the App Store write-review page for explicit user actions, defaulting to the configured app ID and returning the system URL-opening result.

- Added a [review integration guide](Documentation/ReviewIntegration.md) covering recommended user-action versus automatic usage, opening results, and migration. Linked it from the README and updated installation examples to 2.2.0.

### Fixed

- The review pre-prompt’s “Rate App” action now opens the review page instead of making a suppressible native request. Automatic requests without a pre-prompt still use StoreKit.
- Updated manual review examples to use `openReviewPage()`; consumers should migrate Settings buttons from `request()` to this API.

## [2.1.0] - 2026-09-12

### Added

- Optional `AutomaticReviewPromptController(resetOnAppVersionChange: true)` resets review activity and cooldowns when the consumer app’s public version changes. Defaults to false; preserves the install date and uses the first observed version as a baseline.

### Changed

- Centralized release and migration details in this changelog, with a README callout linking here.

### Fixed

- Corrected the Tip Jar attribution link to the SDK repository.
- Ordered loaded tip products by increasing price, using product ID to break ties.

## [2.0.0] - 2026-09-12

### Changed
- Refreshed the README with all seven offerings, integration lifecycle guidance; the 1.x migration guide is maintained below.
- Review pre-prompts now offer “Rate App” and “Maybe Later”; deferring dismisses the alert without a feedback action.
- Added optional `Configuration.supportEmail` and `FeedbackMail.openComposer(subject:body:)` for host-owned support buttons. Missing or malformed recipients do not open a mail client.

### Removed
- Breaking: removed `FeedbackFormView`, `.feedbackFormSheet(...)`, feedback form theme strings, and the review pre-prompt’s `onNegativeResponse` callback. Replace form entry points with your own button calling `FeedbackMail.openComposer`; remove the callback from review modifiers.

### Migrating from 1.x

Version 2.0.0 removes the in-app feedback flow. Update your package dependency to `2.0.0` and make these changes:

| Removed API | Replacement |
| --- | --- |
| `FeedbackFormView` and `.feedbackFormSheet(...)` | Your own support button calling `FeedbackMail.openComposer(subject:body:)` |
| `.automaticReviewPrompt(..., onNegativeResponse:)` or its trailing callback | Remove the callback; “Maybe Later” only dismisses the alert |
| `feedbackFormTitle`, `feedbackFormPlaceholder`, `feedbackFormSubmitButtonTitle` theme strings | Remove these initializer arguments and property accesses |

Provide `supportEmail` in configuration to use the new recipient-free email call. The existing explicit-recipient `FeedbackMail.openComposer(to:subject:body:)` API remains available. Neither API opens anything for a missing or empty address. Existing tip and review trigger state is retained; this release does not reset cooldowns.

## [1.0.0] - 2026-08-26

### Added
- Core StoreKit 2 tip purchase engine (`TipStore`, `StoreProviding`), with restore-on-launch and full verification.
- SDK-wide theming system (`TipJarTheme`, `.tipJarTheme(_:)`) covering colors, typography, spacing, and all copy.
- Bundled, fully themeable Tip Jar UI (`TipJarView`) with success haptics/confetti and a non-removable "Powered by Indie App Growth Kit" attribution link.
- Local tip history (`TipStore.tipHistory()`) — no server required.
- Generic on-device automatic-trigger engine (`AutomaticTriggerEngine`, `TriggerCondition`) reused by the tip prompt, review prompt, and What's New card.
- Automatic Tip Jar prompt (`AutomaticTipPromptController`, `.automaticTipPrompt(...)`).
- Share App hook (`ShareAppButton`, built on `ShareLink`).
- App Store review prompt (`ReviewPrompt.request()`, `AutomaticReviewPromptController`, `.automaticReviewPrompt(...)`) with an optional "Enjoying the app?" pre-prompt that can route negative responses to feedback instead of the system prompt.
- Feedback hook: `FeedbackMail` (`mailto:`-based composer) and a bundled `FeedbackFormView`.
- Cross-promotion hook (`PromotedApp`, `CrossPromotionView`).
- Milestone celebration hook (`.milestoneCelebration(...)`), reusing the Tip Jar's success feedback for any developer-defined milestone.
- What's New prompt (`WhatsNewController`, `WhatsNewView`, `.automaticWhatsNew(...)`), shown at most once per app version.
- Debug-only trigger-state overlay (`AutomaticTriggerDebugOverlay`), stripped from release builds.
- A runnable sample app (`Demo/IndieAppGrowthKitDemo`) exercising every feature above.

### Changed
- Target platforms raised to iOS 18+ / macOS 15+ (from an initial iOS 15+ / macOS 12+ draft).

### Known limitations (see MILESTONES.md for details)
- True custom-amount tipping is out of scope for v1: it requires Apple's Advanced Commerce API, which needs a signing backend and conflicts with this SDK's no-server design. Use as many discrete preset tiers as you like instead.
- `ShareLink` (used by `ShareAppButton`) has no public completion callback on iOS/macOS today, so there's no share-outcome event.
- Purchase-flow and StoreKitTest-backed tests require running from Xcode with a StoreKit configuration attached to the scheme; they skip themselves (rather than fail) under a bare `swift test`.
