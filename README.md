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

IndieAppGrowthKit.configure(
    .init(
        tipProductIdentifiers: ["com.yourapp.tip.small", "com.yourapp.tip.medium", "com.yourapp.tip.large"],
        appStoreID: "123456789"
    )
)
```

Then present the bundled Tip Jar view wherever makes sense in your app (e.g. a Settings screen).

## Status

This SDK is under active development. The public API is not yet stable.

## License

MIT — see [LICENSE](LICENSE).
