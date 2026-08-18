# IndieTipsSDK — Requirements

## Overview

IndieTipsSDK is a Swift SDK that indie developers integrate into their iOS/macOS apps to let end users send voluntary tips (donations) to support the app or its developer. It targets Apple platforms and is distributed via Swift Package Manager.

## Goals

- Let developers add a "tip jar" experience to their app with minimal integration effort.
- Support one-time tips at developer-configurable price points.
- Handle payment processing, receipt validation, and error states so the host app doesn't have to.
- Provide a polished, customizable UI component out of the box, with the option for developers to build their own UI against the SDK's lower-level API.

## Target Platforms

- iOS 18+
- macOS 15+
- Swift 5.7+
- Distribution: Swift Package Manager (SPM)

## Functional Requirements

### Payments
- Use StoreKit 2 (In-App Purchase, consumable products) as the payment backend.
- Support multiple tip tiers (e.g. small/medium/large/custom amount), configured by the developer via product identifiers set up in App Store Connect.
- Handle purchase flow: initiate purchase, listen for transaction updates, verify transaction, finish transaction.
- Gracefully handle failure states: user cancellation, payment declined, network error, pending/deferred purchase (e.g. Ask to Buy).
- Prevent duplicate/unfinished transactions from being lost (restore unfinished transactions on launch).
- Support a "custom amount" tip tier (Apple's custom-amount In-App Purchase, available iOS 16.4+) in addition to preset tiers, letting the user enter their own tip amount.
- Support testing tip flows locally against Xcode's `.storekit` configuration file, so devs can preview and test purchases without hitting the real App Store sandbox.

### UI
- Provide a pre-built SwiftUI "Tip Jar" view that lists available tip tiers and lets the user pick and confirm one.
- The bundled UI's look and feel must be fully customizable by the host app, including at minimum: colors (background, accent, text), typography/fonts, corner radius/shape, spacing/layout, button styles, and tier card content (title, subtitle, icon/emoji per tier).
- Customization is expressed via a theme/style configuration object (or SwiftUI `ViewModifier`/environment-based styling) passed into the bundled view, with sensible defaults so theming is opt-in.
- Support fully custom per-element rendering via SwiftUI view builders (e.g. custom tier row content, custom call-to-action button), not just color/font tokens, so a host app can restyle the UI to match its own design system.
- Support light/dark mode and Dynamic Type, including when custom theming is applied.
- Localized pricing display: tip tier prices are shown using StoreKit's localized price strings, correctly formatted for the user's currency/region.
- Built-in success feedback on a completed tip (e.g. haptic feedback on iOS, a confetti/celebratory animation), enabled by default and customizable/overridable by the host app.
- Emit a completion callback/closure or async result indicating success, cancellation, or failure, so the host app can show its own confirmation UI if desired.
- Allow developers to use just the underlying purchase API without the bundled UI.
- Accessibility: all interactive elements (tier cards, buttons, custom-amount field) expose VoiceOver labels, values, and hints; success/error states are announced via accessibility notifications.

### Configuration
- Developer configures the SDK once at app launch with their set of product identifiers.
- No server/backend required for v1 — all tipping is handled client-side via StoreKit.

### Tip History
- Expose an API to query the current user's tipping history from local StoreKit transaction data, e.g. whether they have tipped before and their total lifetime tip amount, so host apps can show a thank-you badge or small perk without needing a server.

### App Store Review Prompt
- Provide an optional hook to trigger Apple's `SKStoreReviewController` review prompt after a successful tip, since a completed tip is a natural moment of goodwill to ask for a review. Off by default; host app opts in.
- Expose that hook as a standalone public API (e.g. `IndieTipsSDK.requestReview()`) that the host app can call directly at any time, not only via the automatic post-tip trigger — so devs can invoke the review prompt from their own logic/timing if they don't want the automatic behavior.
- Provide the same opt-in automatic-trigger engine used for tip prompts (see Automatic Tip Prompt Triggers below) for the review prompt, using an independently configured set of conditions — launch count, days since install, days since last review prompt, session count, and custom developer signals (e.g. "after successful tip", "after N successful tips") — so devs can drive review requests off different thresholds than tip prompts.
- Track the review prompt's own state (launch count, install date, last-prompted date) separately from the tip prompt engine's state, since the two are configured and triggered independently.
- Respect Apple's system-level rate limit on `SKStoreReviewController` (a maximum of a few prompts per 365-day rolling window, enforced by iOS itself, outside the SDK's control) — the SDK's own cooldown is an additional, developer-configurable throttle on top of that, not a replacement for it.

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

### Analytics / Callbacks
- Expose hooks/delegates or Combine publishers for: tip started, tip succeeded, tip failed, tip cancelled, automatic tip prompt shown, automatic tip prompt dismissed, automatic review prompt triggered — so host apps can log analytics or show thank-you messaging.

## Non-Functional Requirements

- **Simplicity**: Integration should be possible in under ~10 lines of code for the default UI path.
- **No third-party dependencies** beyond Apple frameworks (StoreKit, SwiftUI, Combine) for v1.
- **Testability**: Core purchase logic must be unit-testable (abstract StoreKit behind a protocol so it can be mocked in tests).
- **Documentation**: Public API must have doc comments; README with a quickstart example.
- **Privacy**: SDK collects no user data and makes no network calls of its own (StoreKit calls go directly to Apple).

## Out of Scope (v1)

- Subscription-based tipping / recurring tips.
- Non-Apple platforms (Android, web).
- Server-side receipt validation or a backend dashboard. All receipt/transaction verification is done on-device via StoreKit 2's built-in `VerificationResult`.

## Open Questions

- Exact shape of the theming API (struct-based style tokens vs. SwiftUI environment values vs. view-builder injection, or a combination).
