# Indie App Growth Kit — Requirements

## Overview

Indie App Growth Kit (Swift API namespace: `IndieAppGrowthKit`) is a Swift SDK that indie developers integrate into their iOS/macOS apps to help them grow and sustain their app: accepting voluntary tips/donations, prompting for App Store reviews, sharing the app, collecting feedback, cross-promoting other apps, and celebrating user milestones. It targets Apple platforms and is distributed via Swift Package Manager.

## Goals

- Let developers add a "tip jar" experience to their app with minimal integration effort.
- Support one-time tips at developer-configurable price points.
- Handle payment processing, receipt validation, and error states so the host app doesn't have to.
- Provide a polished, customizable UI component out of the box, with the option for developers to build their own UI against the SDK's lower-level API.

## Target Platforms

- iOS 18+
- macOS 15+
- Swift 6.0+
- Distribution: Swift Package Manager (SPM)

## Functional Requirements

### Payments
- Use StoreKit 2 (In-App Purchase, consumable products) as the payment backend.
- Support multiple tip tiers (e.g. small/medium/large/extra-large), configured by the developer via product identifiers set up in App Store Connect.
- Handle purchase flow: initiate purchase, listen for transaction updates, verify transaction, finish transaction.
- Gracefully handle failure states: user cancellation, payment declined, network error, pending/deferred purchase (e.g. Ask to Buy).
- Prevent duplicate/unfinished transactions from being lost (restore unfinished transactions on launch).
- ~~Support a "custom amount" tip tier letting the user enter their own tip amount.~~ **Descoped for v1** (discovered during M1 implementation): true custom-amount consumable purchases go through Apple's Advanced Commerce API, which requires the app's backend to produce a signed JWS for each purchase — that needs a server, directly conflicting with this SDK's no-backend/no-network-calls-of-its-own requirement. v1 instead supports as many discrete preset tiers as the developer wants to configure (e.g. $1/$3/$5/$10/$25), which covers the same goal (letting the user pick their own amount) without a server. True arbitrary-amount entry is a candidate for a later version if/when server-side signing is added.
- Support testing tip flows locally against Xcode's `.storekit` configuration file, so devs can preview and test purchases without hitting the real App Store sandbox.

### UI
- Provide a pre-built SwiftUI "Tip Jar" view that lists available tip tiers and lets the user pick and confirm one.
- **Every bundled view in the SDK** — Tip Jar, What's New card, Cross-Promotion list, bundled Feedback form, and any other shipped UI — must be fully customizable by the host app, including at minimum: colors (background, accent, text), typography/fonts, all user-facing text/copy (labels, titles, button text, messages), corner radius/shape, spacing/layout, button styles, icons/imagery, and general branding (e.g. a host app logo/header). This is a blanket requirement, not specific to the Tip Jar view alone.
- Customization is expressed via a theme/style configuration object (or SwiftUI `ViewModifier`/environment-based styling) passed into each bundled view, with sensible defaults so theming is opt-in.
- Support fully custom per-element rendering via SwiftUI view builders (e.g. custom tier row content, custom call-to-action button), not just color/font tokens, so a host app can restyle any bundled view to match its own design system.
- Support light/dark mode and Dynamic Type, including when custom theming is applied.
- The Tip Jar view displays a "Powered by Indie App Growth Kit" attribution link that opens the SDK's GitHub repository in the system browser. Its position and text styling follow the same theming system as the rest of the view, but the link itself is non-removable — the host app cannot hide or disable it.
- Localized pricing display: tip tier prices are shown using StoreKit's localized price strings, correctly formatted for the user's currency/region.
- Built-in success feedback on a completed tip (e.g. haptic feedback on iOS, a confetti/celebratory animation), enabled by default and customizable/overridable by the host app.
- Emit a completion callback/closure or async result indicating success, cancellation, or failure, so the host app can show its own confirmation UI if desired.
- Allow developers to use just the underlying purchase API without the bundled UI.
- Accessibility: all interactive elements (tier cards, buttons) expose VoiceOver labels, values, and hints; success/error states are announced via accessibility notifications.

### Configuration
- Developer configures the SDK once at app launch with their set of product identifiers.
- No server/backend required for v1 — all tipping is handled client-side via StoreKit.

### Tip History
- Expose an API to query the current user's tipping history from local StoreKit transaction data, e.g. whether they have tipped before and their total lifetime tip amount, so host apps can show a thank-you badge or small perk without needing a server.

### Share App Hook
- Provide a standalone public API (e.g. `IndieAppGrowthKit.shareApp()`) that presents the native system share sheet (`UIActivityViewController` on iOS, `NSSharingServicePicker` on macOS) pre-populated with the app's App Store link, so the user can share it via Messages, email, social media, AirDrop, or any other share-sheet destination they have installed.
- The host app calls this hook explicitly from its own UI (e.g. a "Tell a friend" / "Share this app" row in a Settings screen) — this hook has no automatic-trigger engine of its own, unlike the tip and review prompts.
- The App Store link/ID is provided by the host app as part of SDK configuration; the SDK constructs the shareable App Store URL from it.
- Support an optional developer-supplied share message/text and, on iOS/iPadOS, accept the presenting view/anchor needed for popover presentation on iPad.
- Emit a callback/publisher indicating the share sheet's outcome (completed, cancelled, failed) where the platform APIs make that information available, for analytics purposes.

### App Store Review Prompt
- Provide an optional hook to trigger Apple's `SKStoreReviewController` review prompt after a successful tip, since a completed tip is a natural moment of goodwill to ask for a review. Off by default; host app opts in.
- Expose that hook as a standalone public API (e.g. `IndieAppGrowthKit.requestReview()`) that the host app can call directly at any time, not only via the automatic post-tip trigger — so devs can invoke the review prompt from their own logic/timing if they don't want the automatic behavior.
- Provide the same opt-in automatic-trigger engine used for tip prompts (see Automatic Tip Prompt Triggers below) for the review prompt, using an independently configured set of conditions — launch count, days since install, days since last review prompt, session count, and custom developer signals (e.g. "after successful tip", "after N successful tips") — so devs can drive review requests off different thresholds than tip prompts.
- Track the review prompt's own state (launch count, install date, last-prompted date) separately from the tip prompt engine's state, since the two are configured and triggered independently.
- Respect Apple's system-level rate limit on `SKStoreReviewController` (a maximum of a few prompts per 365-day rolling window, enforced by iOS itself, outside the SDK's control) — the SDK's own cooldown is an additional, developer-configurable throttle on top of that, not a replacement for it.
- Support an optional "review → feedback" fallback flow: present a lightweight pre-prompt ("Enjoying the app?") before the system review prompt; on a negative response, route the user to the Feedback/Bug Report hook (see below) instead of the App Store review prompt, so unhappy users are funneled to private feedback rather than a public bad review. Off by default; host app opts in and supplies the pre-prompt copy or a custom view.

### Feedback / Bug Report Hook
- Provide a standalone public API (e.g. `IndieAppGrowthKit.requestFeedback()`) that lets the user send feedback directly to the developer, via a mail composer (`MFMailComposeViewController`/`NSSharingService` mail, pre-addressed to a developer-configured support email with device/app version info pre-filled) or a minimal bundled in-SDK feedback form as a lighter-weight alternative.
- Callable directly by the host app at any time, and usable as the negative-response destination for the review prompt's "review → feedback" fallback flow described above.
- Bundled feedback form (if used instead of mail) follows the same full theming requirements as the rest of the bundled UI, and its submission is handled entirely by the host app (e.g. via a completion callback with the entered text) — the SDK does not transmit feedback anywhere itself, consistent with making no network calls of its own.

### Cross-Promotion Hook
- Provide an API and optional bundled UI for a developer to promote their other apps within the host app, configured with a developer-supplied list of promoted apps (App Store ID, name, icon, tagline).
- Tapping a promoted app opens its App Store listing (via `SKOverlay`/`SKStoreProductViewController` or a plain App Store URL).
- Fully themeable consistent with the rest of the bundled UI; usable standalone (e.g. in a Settings screen) or as one more automatic-trigger-engine-eligible surface.

### Milestone Celebration Hook
- Generalize the Automatic Tip Prompt Triggers' "custom developer signal" into a small standalone, reusable celebration API (e.g. `IndieAppGrowthKit.celebrate(milestone:)`) that a host app can call for any in-app milestone or streak, not only tipping-related ones.
- Reuses the same built-in success feedback (haptics/confetti) as a successful tip, and can optionally bundle a tip and/or review nudge alongside the celebration if the host app opts in, so a single milestone moment can prompt multiple engagement actions at once.

### Automatic Tip Prompt Triggers
- Provide an opt-in engagement engine that automatically presents the bundled Tip Jar UI when developer-defined conditions are met, so devs don't have to hand-roll their own launch-counting/timing logic.
- Supported trigger conditions (combinable, all optional, developer-configured):
  - **App launch count** — e.g. prompt after the Nth launch.
  - **Days since install** — e.g. prompt no earlier than N days after first launch.
  - **Days since last prompt** — minimum cooldown between automatic prompts, to avoid nagging.
  - **Session/usage count** — e.g. prompt after N foreground sessions, as an alternative to raw launch count.
  - **Custom developer signal** — an API for the host app to report its own "positive moment" events (e.g. completed onboarding, hit a milestone) that the engine can also condition on.
- All conditions are AND-combined by default (all configured conditions must be satisfied before a prompt fires); the engine evaluates conditions on each app launch/foreground.
- Never prompt automatically if the user has already tipped, has dismissed/declined the prompt more than a developer-configured number of times, or has an active cooldown in effect.
- Prompt state (launch count, install date, last-prompted date, dismiss count) is persisted locally on-device only (e.g. via `UserDefaults`), consistent with the SDK's no-backend, no-network-calls design.
- The automatic prompt is fully optional and off by default; the host app must explicitly configure and enable it. Devs can also disable it and drive prompting entirely themselves via the manual UI/API.
- Respect the same theming/customization requirements as the rest of the bundled UI when auto-presented.

### What's New Prompt
- Provide an opt-in "What's New" card/sheet shown at most once per app version, using the same automatic-trigger pattern as the tip and review prompts: it fires when the SDK detects the app's version has changed since the last recorded launch.
- Content (title, bullet list of highlights, optional image) is developer-supplied per version; fully themeable consistent with the rest of the bundled UI.
- State (last-seen version) persisted locally on-device only. Off by default; host app opts in and supplies content.

### Analytics / Callbacks
- Expose hooks/delegates or Combine publishers for: tip started, tip succeeded, tip failed, tip cancelled, automatic tip prompt shown, automatic tip prompt dismissed, automatic review prompt triggered, share app completed/cancelled/failed, feedback requested/submitted, cross-promotion app tapped, milestone celebrated, what's new shown — so host apps can log analytics or show thank-you messaging.

## Non-Functional Requirements

- **Simplicity**: Integration should be possible in under ~10 lines of code for the default UI path.
- **No third-party dependencies** beyond Apple frameworks (StoreKit, SwiftUI, Combine) for v1.
- **Testability**: Core purchase logic must be unit-testable (abstract StoreKit behind a protocol so it can be mocked in tests).
- **Documentation**: Public API must have doc comments; README with a quickstart example.
- **Privacy**: SDK collects no user data and makes no network calls of its own (StoreKit calls go directly to Apple).
- **Extension friendliness**: The core purchase API (tipping, tip history) must work correctly from app extensions and App Clips, not only the main app target, since indie devs increasingly ship these; automatic-trigger prompts and bundled UI are main-app-target only.
- **Debug overlay**: Provide a debug-only, opt-in on-screen overlay (stripped from release builds) showing the live state of all automatic-trigger engines — launch count, days since install, days since last prompt, dismiss count, per-feature enabled/disabled state — so developers can verify their trigger configuration without waiting out real cooldown periods. Includes a way to reset/simulate state for testing.

## Out of Scope (v1)

- Subscription-based tipping / recurring tips.
- Non-Apple platforms (Android, web).
- Server-side receipt validation or a backend dashboard. All receipt/transaction verification is done on-device via StoreKit 2's built-in `VerificationResult`.

## Open Questions

- Exact shape of the theming API (struct-based style tokens vs. SwiftUI environment values vs. view-builder injection, or a combination).
