# Indie App Growth Kit

A Swift SDK that helps indie developers grow and sustain their iOS/macOS apps: voluntary tips, App Store review prompts, sharing, feedback collection, cross-promotion, and milestone celebrations — all client-side, no backend required.

See [REQUIREMENTS.md](REQUIREMENTS.md) for the full feature spec.

## Requirements

- iOS 18+ / macOS 15+
- Swift 6.0+
- Xcode 16+

## Installation

Add Indie App Growth Kit to your project via Swift Package Manager:

```
https://github.com/<your-org>/IndieAppGrowthKit
```

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
