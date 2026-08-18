# Changelog

All notable changes to Indie App Growth Kit are documented here. The project hasn't cut a first release yet, so everything so far is under Unreleased. See [MILESTONES.md](MILESTONES.md) for the detailed build log behind each entry.

## Unreleased

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
