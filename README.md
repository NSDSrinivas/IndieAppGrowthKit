# Indie App Growth Kit

A Swift SDK that helps indie developers grow and sustain their iOS/macOS apps: voluntary tips, App Store review prompts, sharing, feedback collection, cross-promotion, and milestone celebrations — all client-side, no backend required.

See [REQUIREMENTS.md](REQUIREMENTS.md) for the full feature spec and [MILESTONES.md](MILESTONES.md) for the feature-by-feature build log.

## Requirements

- iOS 18+ / macOS 15+
- Swift 6.0+
- Xcode 16+

## Installation

Add Indie App Growth Kit to your project via Swift Package Manager.

**In Xcode:** File → Add Package Dependencies… and enter:

```
https://github.com/NSDSrinivas/IndieAppGrowthKit.git
```

Choose the `main` branch (or pin to a released tag once one exists), then add the `IndieAppGrowthKit` library product to your app target.

**Or, in another package's `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/NSDSrinivas/IndieAppGrowthKit.git", branch: "main")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["IndieAppGrowthKit"]
    )
]
```

This is a private repository, so SPM will prompt you to authenticate with GitHub (via your Xcode-linked account or SSH key) the first time you resolve it. Make sure whatever machine/CI resolves the package has access to the repo (an SSH key or a GitHub account added as a collaborator).

## Quickstart

Configure the SDK once at app launch, then use whichever features you need — every piece below is independent, so you only wire up what your app actually uses.

```swift
import SwiftUI
import IndieAppGrowthKit

@main
struct YourApp: App {
    init() {
        IndieAppGrowthKit.configure(
            .init(
                tipProductIdentifiers: ["com.yourapp.tip.small", "com.yourapp.tip.medium", "com.yourapp.tip.large"],
                appStoreID: "123456789"
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

The tip product identifiers must match In-App Purchase (consumable) products you've created in App Store Connect; `appStoreID` is your app's numeric App Store ID, used for sharing links and review prompts.

## Integration guide

`Demo/IndieAppGrowthKitDemo/` is a runnable reference implementation of everything below (`swift run IndieAppGrowthKitDemo`) — when in doubt, check how a screen there wires things up.

### Tipping

`IndieAppGrowthKit.tipStore` is the purchase engine (a `TipStore` actor) created for you by `configure(_:)`. The bundled `TipJarView` drives it end-to-end: loading products, submitting purchases, and reporting the outcome.

For an **on-demand** entry point (a "Tip the Developer" row in Settings, a standalone button, etc.), present it as a sheet with `.tipJarSheet(_:)`:

```swift
struct SettingsView: View {
    @State private var showTipJar = false

    var body: some View {
        List {
            Button("Tip the Developer") { showTipJar = true }
        }
        .tipJarSheet(isPresented: $showTipJar, store: IndieAppGrowthKit.tipStore) { completion in
            // completion is .success(productIdentifier:), .cancelled, .pending, or .failed(_)
        }
    }
}
```

For an **automatic** prompt shown once developer-configured conditions are met (e.g. after a few launches), use an `AutomaticTipPromptController` with `.automaticTipPrompt(_:)`. Conditions are AND-combined from `TriggerCondition` (`.launchCount`, `.daysSinceInstall`, `.daysSinceLastPrompt`, `.sessionCount`, `.customSignal`, `.dismissCountBelow`); the controller also never re-prompts once the user has already tipped.

```swift
let tipPromptController = AutomaticTipPromptController(
    conditions: [.launchCount(atLeast: 3), .daysSinceLastPrompt(atLeast: 7), .dismissCountBelow(maximum: 3)],
    tipStore: IndieAppGrowthKit.tipStore
)

// Call once per launch/session, e.g. in your root view's .task:
await tipPromptController.recordLaunch()
```

```swift
ContentView()
    .automaticTipPrompt(controller: tipPromptController, tipStore: IndieAppGrowthKit.tipStore) { completion in
        // handle completion
    }
```

`await IndieAppGrowthKit.tipStore.tipHistory()` returns a `TipHistory` (tip count + totals by currency) if you want to show the user their own tipping history.

### App Store reviews

`ReviewPrompt.request()` triggers Apple's native review prompt directly — call it any time (e.g. a manual "Rate this App" settings button), no UI to present since it's a system dialog.

For automatic prompting, use `AutomaticReviewPromptController` + `.automaticReviewPrompt(_:)`, same condition system as tipping but under its own independent namespace/state:

```swift
let reviewPromptController = AutomaticReviewPromptController(
    conditions: [.launchCount(atLeast: 5), .daysSinceLastPrompt(atLeast: 30)]
)
```

```swift
ContentView()
    .automaticReviewPrompt(
        controller: reviewPromptController,
        prePromptTitle: "Enjoying the app?",
        prePromptMessage: "We'd love to hear your feedback.",
        onNegativeResponse: { showFeedbackFormSheet = true }
    )
```

Passing `prePromptTitle` shows a lightweight "Enjoying the app?" alert first; a negative response routes to `onNegativeResponse` (typically your feedback flow) instead of the system prompt, so unhappy users go to private feedback rather than a public bad review. Omit it to go straight to `ReviewPrompt.request()`.

### Sharing

`ShareAppButton` wraps SwiftUI's native `ShareLink` (system share sheet, AirDrop/Messages/Mail/etc. included), pre-populated with your App Store link:

```swift
ShareAppButton(message: "Check out this app!")
```

Uses `appStoreID` from `configure(_:)` by default; pass `appStoreID:` explicitly to share a different app.

### Feedback

Two options, pick based on how much friction you want:

- `FeedbackMail.openComposer(to:subject:body:)` hands off to the user's Mail app (with `FeedbackMail.diagnosticsBody()` available to prefill app/OS version diagnostics).
- `FeedbackFormView` collects feedback in-app. For an on-demand entry point, present it with `.feedbackFormSheet(_:)`:

```swift
struct SettingsView: View {
    @State private var showFeedback = false

    var body: some View {
        List {
            Button("Send Feedback") { showFeedback = true }
        }
        .feedbackFormSheet(isPresented: $showFeedback) { text in
            // send `text` wherever your feedback should go — the SDK makes no network calls of its own
        }
    }
}
```

### Cross-promotion

`CrossPromotionView` renders a themed list of your other apps; tapping one opens its App Store listing. It's a static, non-modal list, so a pushed navigation destination (e.g. a "More Apps" settings row) is the natural fit rather than a sheet:

```swift
NavigationLink("More Apps") {
    CrossPromotionView(apps: [
        PromotedApp(appStoreID: "1111111111", name: "Weight Tracker", tagline: "Simple daily weight logging", systemImage: "scalemass"),
        PromotedApp(appStoreID: "2222222222", name: "Number Cruncher", tagline: "A handy calculator", systemImage: "function"),
    ])
    .navigationTitle("More Apps")
}
```

### Milestone celebrations

`.milestoneCelebration(trigger:)` fires confetti + haptic success feedback for any developer-defined in-app milestone (a streak, a completed goal, etc.) — unrelated to tipping. Set the binding to `true` to fire it; it resets to `false` automatically:

```swift
@State private var celebrating = false

Button("Complete Goal") { celebrating = true }
    .milestoneCelebration(trigger: $celebrating)
```

Optionally pass `reportingSignal:` plus your tip/review prompt controller(s) to report the moment as a `.customSignal(_:)`, so you can condition an automatic tip or review prompt on it (e.g. nudge for a tip right after a celebratory moment) without hardcoding the two flows together.

### What's New

`WhatsNewController` shows a themed "What's New" card at most once per app version. Content is entirely developer-supplied per version:

```swift
let whatsNewController = WhatsNewController()
```

```swift
ContentView()
    .automaticWhatsNew(controller: whatsNewController, title: "What's New in 1.1") {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tip jars with preset amounts", systemImage: "heart.fill")
            Label("Automatic review prompts", systemImage: "star.fill")
        }
    }
```

### Theming

Every bundled view (`TipJarView`, `FeedbackFormView`, `CrossPromotionView`, `WhatsNewView`) reads its colors, typography, metrics, and copy from a `TipJarTheme` via the `.tipJarTheme(_:)` environment modifier — nothing is hardcoded, so you can fully restyle to match your app's design system without forking any view. Apply it as high up your view hierarchy as you want the theme to reach; omit it entirely to use `.default`, which already tracks the system's light/dark appearance automatically.

```swift
ContentView()
    .tipJarTheme(.init(
        colors: .init(
            background: Color(.systemBackground),
            surface: Color(.secondarySystemBackground),
            accent: .yellow,
            primaryText: .primary,
            secondaryText: .secondary
        ),
        typography: .init(title: .title2.bold(), body: .body, price: .headline, caption: .caption),
        metrics: .init(cornerRadius: 16, spacing: 12, padding: 16),
        strings: .init(tipJarTitle: "Support this app", tipJarSubtitle: "...", purchaseButtonTitle: "Tip", poweredByText: "...")
    ))
```

A custom theme replaces the colors wholesale — `TipJarTheme` doesn't merge with `.default`, so supplying your own `colors` means you own light/dark support for them too. Prefer adaptive sources (system semantic colors as above, or Asset Catalog colors with Any/Dark variants) over fixed RGB/hex values, or your custom theme will look wrong in whichever appearance you didn't design for.

### Debug overlay

`AutomaticTriggerDebugOverlay` shows the live state (launch/session counts, dates, dismiss counts, custom signals) of every automatic-trigger controller you pass in, with a reset button per controller — useful for verifying trigger conditions without waiting out real cooldown periods. It renders nothing (`EmptyView`) outside of `DEBUG` builds, so it's safe to leave wired into a shipping app's debug menu:

```swift
AutomaticTriggerDebugOverlay(
    tipController: tipPromptController,
    reviewController: reviewPromptController,
    whatsNewController: whatsNewController
)
```

### Choosing a presentation style

The SDK's own automatic prompts set the precedent — match it when you trigger the same views on-demand, so the UI is consistent regardless of what triggered it:

| View | Automatic presentation | On-demand presentation |
| --- | --- | --- |
| `TipJarView` | `.sheet` (via `.automaticTipPrompt`) | `.tipJarSheet(_:)` |
| `FeedbackFormView` | — (no automatic trigger) | `.feedbackFormSheet(_:)` |
| Review pre-prompt | `.alert` (via `.automaticReviewPrompt`) | n/a — `ReviewPrompt.request()` is a system dialog |
| `WhatsNewView` | `.sheet` (via `.automaticWhatsNew`) | n/a — inherently version-triggered |
| `CrossPromotionView` | — (no automatic trigger) | Push (`NavigationLink`) — it's a static list, not a modal flow |

## Status

This SDK is under active development. The public API is not yet stable. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE).
