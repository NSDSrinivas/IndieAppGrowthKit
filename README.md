# Indie App Growth Kit

A Swift SDK that helps indie developers grow and sustain their iOS/macOS apps: voluntary tips, App Store review prompts, sharing, email support, cross-promotion, and milestone celebrations — all client-side, no backend required.

> [!NOTE]
> Release history, breaking changes, and upgrade instructions are maintained in [CHANGELOG.md](CHANGELOG.md). Upgrading from 1.x? See the [2.0.0 migration guide](CHANGELOG.md#migrating-from-1x).

## Offerings

| Feature | What the SDK provides | How your app uses it |
| --- | --- | --- |
| Tip jar | StoreKit 2 purchases, themed tip UI, local tip count and totals by currency | Present manually or configure automatic prompts; automatic prompts stop after a tip |
| App Store reviews | Native review requests with an optional **Rate App / Maybe Later** alert | Request directly or configure automatic conditions and cooldowns |
| App sharing | Native sharing with your App Store link | Place `ShareAppButton` in your UI |
| Email support | Opens the email client using an optional support address | Call `FeedbackMail.openComposer()` from your own button or settings entry |
| Cross-promotion | Themed list of your other apps linking to their App Store pages | Present `CrossPromotionView` from your own navigation |
| Milestone celebrations | Confetti and supported haptics for achievements or other app events | Set a trigger binding; optionally report a custom prompt signal |
| What’s New | Themed update sheet, shown once for each detected app version | Supply your release content and attach `.automaticWhatsNew(...)` |

Supporting tools include shared theming, independent local prompt tracking, configurable trigger conditions, and a debug overlay. No backend is required. Email support has no bundled form or automatic entry point.

This README covers the current offerings and integration guide. [REQUIREMENTS.md](REQUIREMENTS.md) and [MILESTONES.md](MILESTONES.md) preserve the original specification and implementation history.

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

Choose "Up to Next Major Version" starting at `2.0.0` (or pin to a specific released tag), then add the `IndieAppGrowthKit` library product to your app target.

**Or, in another package's `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/NSDSrinivas/IndieAppGrowthKit.git", from: "2.0.0")
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
                appStoreID: "123456789",
                supportEmail: "support@example.com" // Optional
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

The tip product identifiers must match In-App Purchase (consumable) products you've created in App Store Connect; `appStoreID` is your app’s numeric App Store ID, used for sharing links. Native review requests use the active app window. Omit `supportEmail` if you do not offer email support.

## Integration guide

`Demo/IndieAppGrowthKitDemo/` is a runnable reference implementation of everything below (`swift run IndieAppGrowthKitDemo`) — when in doubt, check how a screen there wires things up.

### Integration checklist

1. Install the package and configure it once before accessing `tipStore` or `configuration`.
2. Choose the features your app needs and place their views or buttons in your own navigation.
3. For automatic tip/review prompts, retain each controller and explicitly record launches, sessions, or custom signals on that controller.
4. Attach automatic modifiers to the screen where you want the prompt evaluated. They check on appearance; recording a signal does not itself present a prompt. Record required events before presenting that screen.
5. Supply cooldown conditions and coordinate prompt placement so multiple prompts do not compete on the same screen.
6. Apply a theme if needed and use the debug overlay to inspect conditions during development.

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

`ReviewPrompt.request()` triggers Apple's native review prompt directly — call it any time (e.g. a manual "Rate this App" settings button), the SDK provides no custom review form. The call requests the system dialog; the SDK does not track whether a rating was submitted.

For automatic prompting, use `AutomaticReviewPromptController` + `.automaticReviewPrompt(_:)`, same condition system as tipping but under its own independent namespace/state. Record review launches with `await reviewPromptController.recordLaunch()`; recording a launch on the tip controller does not update the review controller:

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
        prePromptMessage: "We hope you’re enjoying using My App. Would you like to take a moment to rate it?"
    )
```

Passing `prePromptTitle` shows an optional alert with **Rate App** and **Maybe Later**. Rate App requests Apple’s review dialog; Maybe Later only dismisses the alert and records a dismissal. The configured cooldown starts when the pre-prompt is presented. Omit `prePromptTitle` to request the system dialog directly.

### Sharing

`ShareAppButton` wraps SwiftUI's native `ShareLink` (system share sheet, AirDrop/Messages/Mail/etc. included), pre-populated with your App Store link:

```swift
ShareAppButton(message: "Check out this app!")
```

Uses `appStoreID` from `configure(_:)` by default; pass `appStoreID:` explicitly to share a different app.

### Email support

The SDK provides an email-opening API only. Your app owns any support button or settings entry; no feedback view is bundled or offered by review prompts.

Provide an optional support address at configuration:

```swift
IndieAppGrowthKit.configure(.init(
    tipProductIdentifiers: ["com.example.tip.small"],
    appStoreID: "1234567890",
    supportEmail: "support@example.com"
))
```

Call from your own UI:

```swift
Button("Email Support") {
    FeedbackMail.openComposer(subject: "Support", body: "")
}
```

If no support email was provided, the call returns `false` without opening anything. You can also supply a recipient directly with `FeedbackMail.openComposer(to:subject:body:)`. Both paths reject empty or malformed recipients. The API opens the default email client via `mailto:`; it does not send email. `FeedbackMail.diagnosticsBody()` is available if you choose to include diagnostics.

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

Bundled views (`TipJarView`, `CrossPromotionView`, `WhatsNewView`) use `TipJarTheme` for shared styling via the `.tipJarTheme(_:)` environment modifier. The theme exposes colors, typography, metrics, and tip-jar copy. Review pre-prompt title and message are configured on its modifier; its button labels are “Rate App” and “Maybe Later”. Apply it as high up your view hierarchy as you want the theme to reach; omit it entirely to use `.default`, which already tracks the system's light/dark appearance automatically.

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
| Review pre-prompt | `.alert` (via `.automaticReviewPrompt`) | n/a — `ReviewPrompt.request()` is a system dialog |
| `WhatsNewView` | `.sheet` (via `.automaticWhatsNew`) | n/a — inherently version-triggered |
| `CrossPromotionView` | — (no automatic trigger) | Push (`NavigationLink`) — it's a static list, not a modal flow |

## Status

Current release: **2.0.0**. Swift Package Manager versions come from Git tags; `Package.swift` does not contain a package version. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE).
