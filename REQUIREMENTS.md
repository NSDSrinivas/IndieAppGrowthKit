# IndieTipsSDK — Requirements

## Overview

IndieTipsSDK is a Swift SDK that indie developers integrate into their iOS/macOS apps to let end users send voluntary tips (donations) to support the app or its developer. It targets Apple platforms and is distributed via Swift Package Manager.

## Goals

- Let developers add a "tip jar" experience to their app with minimal integration effort.
- Support one-time tips at developer-configurable price points.
- Handle payment processing, receipt validation, and error states so the host app doesn't have to.
- Provide a polished, customizable UI component out of the box, with the option for developers to build their own UI against the SDK's lower-level API.

## Target Platforms

- iOS 15+
- macOS 12+
- Swift 5.7+
- Distribution: Swift Package Manager (SPM)

## Functional Requirements

### Payments
- Use StoreKit 2 (In-App Purchase, consumable products) as the payment backend.
- Support multiple tip tiers (e.g. small/medium/large/custom amount), configured by the developer via product identifiers set up in App Store Connect.
- Handle purchase flow: initiate purchase, listen for transaction updates, verify transaction, finish transaction.
- Gracefully handle failure states: user cancellation, payment declined, network error, pending/deferred purchase (e.g. Ask to Buy).
- Prevent duplicate/unfinished transactions from being lost (restore unfinished transactions on launch).

### UI
- Provide a pre-built SwiftUI "Tip Jar" view that lists available tip tiers and lets the user pick and confirm one.
- The bundled UI's look and feel must be fully customizable by the host app, including at minimum: colors (background, accent, text), typography/fonts, corner radius/shape, spacing/layout, button styles, and tier card content (title, subtitle, icon/emoji per tier).
- Customization is expressed via a theme/style configuration object (or SwiftUI `ViewModifier`/environment-based styling) passed into the bundled view, with sensible defaults so theming is opt-in.
- Support fully custom per-element rendering via SwiftUI view builders (e.g. custom tier row content, custom call-to-action button), not just color/font tokens, so a host app can restyle the UI to match its own design system.
- Support light/dark mode and Dynamic Type, including when custom theming is applied.
- Emit a completion callback/closure or async result indicating success, cancellation, or failure, so the host app can show its own confirmation UI if desired.
- Allow developers to use just the underlying purchase API without the bundled UI.

### Configuration
- Developer configures the SDK once at app launch with their set of product identifiers.
- No server/backend required for v1 — all tipping is handled client-side via StoreKit.

### Analytics / Callbacks
- Expose hooks/delegates or Combine publishers for: tip started, tip succeeded, tip failed, tip cancelled — so host apps can log analytics or show thank-you messaging.

## Non-Functional Requirements

- **Simplicity**: Integration should be possible in under ~10 lines of code for the default UI path.
- **No third-party dependencies** beyond Apple frameworks (StoreKit, SwiftUI, Combine) for v1.
- **Testability**: Core purchase logic must be unit-testable (abstract StoreKit behind a protocol so it can be mocked in tests).
- **Documentation**: Public API must have doc comments; README with a quickstart example.
- **Privacy**: SDK collects no user data and makes no network calls of its own (StoreKit calls go directly to Apple).

## Out of Scope (v1)

- Subscription-based tipping / recurring tips.
- Non-Apple platforms (Android, web).
- Server-side receipt validation or a backend dashboard.
- Custom/arbitrary tip amounts (only preset tiers) — may be considered for a later version.

## Open Questions

- Minimum supported OS version — confirm iOS 15 / macOS 12 is acceptable, or whether older versions (needing StoreKit 1 fallback) must be supported.
- Whether a later version should add server-side receipt verification for fraud protection.
- Exact shape of the theming API (struct-based style tokens vs. SwiftUI environment values vs. view-builder injection, or a combination).
