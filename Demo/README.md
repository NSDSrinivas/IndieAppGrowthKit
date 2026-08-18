# IndieAppGrowthKit Demo

A minimal SwiftUI app that integrates every Indie App Growth Kit feature, used as a manual test harness during development (see [MILESTONES.md](../MILESTONES.md)). It is not part of the distributed library.

## Running it

**macOS (quick check, no Xcode project needed):**

```
swift run IndieAppGrowthKitDemo
```

**iOS Simulator (recommended — real StoreKit purchases, real device sizing):**

An Xcode project isn't checked in; it's generated from `Demo/project.yml` via [XcodeGen](https://github.com/yonaskolb/XcodeGen).

1. Install XcodeGen (one-time): `brew install xcodegen`
2. Generate the project:
   ```
   cd Demo
   xcodegen generate
   ```
3. Open it: `open IndieAppGrowthKitDemo.xcodeproj`
4. In Xcode, select the `IndieAppGrowthKitDemo` scheme and an iOS Simulator destination, then Run (`⌘R`).

The scheme already points its StoreKit Configuration at `Demo.storekit`, so purchases/tips work out of the box — no extra setup needed. Re-run `xcodegen generate` after editing `project.yml` or adding/removing source files under `IndieAppGrowthKitDemo/`; the generated `.xcodeproj` is gitignored, so it must be regenerated after a fresh clone.

## Structure

- `IndieAppGrowthKitDemo/DemoApp.swift` — app entry point; calls `IndieAppGrowthKit.configure(...)`.
- `IndieAppGrowthKitDemo/HomeView.swift` — one row per feature, linking to the milestone that implements it. Rows are wired up to the real API as each milestone lands.
- `IndieAppGrowthKitDemo/ThemePreviewView.swift` — the M2 "Theme Switcher" screen.
- `Demo.storekit` — local StoreKit product catalog matching the identifiers in `DemoApp.swift`.

## Purchase engine (M1) and Tip Jar UI (M3)

The "Purchase Engine (real)" row and the "Bundled Tip Jar UI" row both call into the real `IndieAppGrowthKit.tipStore`. `Product`/`Transaction` can only be exercised against a real (possibly local-test) StoreKit environment — there's no way to fake a purchase outside of one — and `swift run` from the CLI isn't an entitled StoreKit host, so product loading will report 0 products when run that way. To exercise real purchases, generate and open `IndieAppGrowthKitDemo.xcodeproj` as described above and run the `IndieAppGrowthKitDemo` scheme on an iOS Simulator (its StoreKit Configuration is already set to `Demo.storekit`) to exercise real purchase flows, including the bundled Tip Jar UI, without hitting the App Store sandbox.

The same constraint applies to the SDK's own test suite: `Tests/IndieAppGrowthKitTests/TipStoreStoreKitTestTests.swift` exercises the real purchase/restore paths via `SKTestSession`, and skips itself with a clear message when run outside Xcode rather than failing.

## iOS testing

The demo target also builds directly for macOS via SPM for quick checks (`swift run IndieAppGrowthKitDemo`), no Xcode project needed. Since the SDK targets iOS 18+, UI/theming milestones should be spot-checked in an iOS Simulator using the generated Xcode project described above (or via Xcode Previews on the SwiftUI views directly).
