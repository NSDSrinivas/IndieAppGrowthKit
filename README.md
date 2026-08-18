# Indie App Growth Kit

A Swift SDK that helps indie developers grow and sustain their iOS/macOS apps: voluntary tips, App Store review prompts, sharing, feedback collection, cross-promotion, and milestone celebrations — all client-side, no backend required.

See [REQUIREMENTS.md](REQUIREMENTS.md) for the full feature spec.

## Requirements

- iOS 18+ / macOS 15+
- Swift 6.0+
- Xcode 16+

## Installation

Add Indie App Growth Kit to your project via Swift Package Manager.

In Xcode: File → Add Package Dependencies… and enter:

```
https://github.com/NSDSrinivas/IndieAppGrowthKit.git
```

Or add it to another package's `Package.swift`:

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

This is a private repository, so SPM will prompt you to authenticate with GitHub (via your Xcode-linked account or SSH key) the first time you resolve it.

## Quickstart

```swift
import IndieAppGrowthKit

// Once at app launch:
IndieAppGrowthKit.configure(
    .init(
        tipProductIdentifiers: ["com.yourapp.tip.small", "com.yourapp.tip.medium", "com.yourapp.tip.large"],
        appStoreID: "123456789"
    )
)
```

```swift
// Wherever makes sense in your app (e.g. a Settings screen):
TipJarView(store: IndieAppGrowthKit.tipStore)

ShareAppButton()
Button("Request Review") { ReviewPrompt.request() }
```

Every bundled view is fully themeable — see `TipJarTheme` and `.tipJarTheme(_:)`. See [MILESTONES.md](MILESTONES.md) for the full feature-by-feature build log, including every other hook (tip history, automatic prompts, feedback, cross-promotion, milestone celebrations, What's New, and the debug overlay), and `Demo/IndieAppGrowthKitDemo/` for a runnable example of all of them (`swift run IndieAppGrowthKitDemo`).

## Status

This SDK is under active development. The public API is not yet stable. See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE).
