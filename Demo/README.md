# IndieAppGrowthKit Demo

A minimal SwiftUI app that integrates every Indie App Growth Kit feature, used as a manual test harness during development (see [MILESTONES.md](../MILESTONES.md)). It is not part of the distributed library.

## Running it

Runs as a macOS app via Swift Package Manager, no separate Xcode project needed:

```
swift run IndieAppGrowthKitDemo
```

## Structure

- `IndieAppGrowthKitDemo/DemoApp.swift` — app entry point; calls `IndieAppGrowthKit.configure(...)`.
- `IndieAppGrowthKitDemo/HomeView.swift` — one row per feature, linking to the milestone that implements it. Rows are wired up to the real API as each milestone lands.
- `IndieAppGrowthKitDemo/ThemePreviewView.swift` — the M2 "Theme Switcher" screen.
- `Demo.storekit` — local StoreKit product catalog matching the identifiers in `DemoApp.swift`.

## Purchase engine (M1) and Tip Jar UI (M3)

The "Purchase Engine (real)" row and the "Bundled Tip Jar UI" row both call into the real `IndieAppGrowthKit.tipStore`. `Product`/`Transaction` can only be exercised against a real (possibly local-test) StoreKit environment — there's no way to fake a purchase outside of one — and `swift run` from the CLI isn't an entitled StoreKit host, so product loading will report 0 products when run that way. To exercise real purchases:

1. Open the package in Xcode (`open Package.swift`), select the `IndieAppGrowthKitDemo` scheme, and set its StoreKit configuration (Scheme → Options → StoreKit Configuration) to `Demo.storekit` (already checked in here).
2. Run from Xcode to exercise real purchase flows, including the bundled Tip Jar UI, without hitting the App Store sandbox.

The same constraint applies to the SDK's own test suite: `Tests/IndieAppGrowthKitTests/TipStoreStoreKitTestTests.swift` exercises the real purchase/restore paths via `SKTestSession`, and skips itself with a clear message when run outside Xcode rather than failing.

## iOS testing

The demo target builds for macOS so it can run directly via SPM without an Xcode project. Since the SDK also targets iOS 18+, UI/theming milestones (M2–M3 onward) should additionally be spot-checked in an iOS Simulator — either by adding an iOS-targeted app wrapper project later, or via Xcode Previews on the SwiftUI views directly.
