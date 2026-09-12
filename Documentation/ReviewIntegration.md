# App Store review integration

Available in Indie App Growth Kit 2.2.0 and later. Configure the SDK at launch with your app’s numeric App Store ID before using the default review link. See the [README quickstart](../README.md#quickstart) for complete configuration.

## Recommended usage

| Entry point | API / behavior |
| --- | --- |
| Settings “Rate App” button or another explicit user action | `await ReviewPrompt.openReviewPage()` opens the App Store write-review page |
| SDK alert’s “Rate App” action | The SDK opens the same review page automatically |
| Automatic review opportunity without an alert | `.automaticReviewPrompt(controller:)` uses the native StoreKit request, subject to Apple’s display policy |
| Host-managed automatic review opportunity | `ReviewPrompt.request()` requests the native StoreKit dialog |

Do not call `ReviewPrompt.request()` from a button or alert action: Apple may suppress the dialog, leaving the tap with no visible result. Use the direct review-page API for these actions, as recommended by [Apple’s review integration guidance](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews).

## Settings and other explicit actions

```swift
import SwiftUI
import IndieAppGrowthKit

struct ReviewSettingsRow: View {
    var body: some View {
        Button("Rate Number Circuit") {
            Task { await ReviewPrompt.openReviewPage() }
        }
    }
}
```

The SDK reads `Configuration.appStoreID`, constructs the HTTPS App Store URL with `action=write-review`, and opens it using the platform API on iOS or macOS. Consumers do not need to build URLs or import UIKit/AppKit.

To review a different app, pass its numeric ID:

```swift
let opened = await ReviewPrompt.openReviewPage(appStoreID: "123456789")
```

The return value reports whether the system opened the URL. Invalid IDs and failed open requests return `false`; callers can use this result to offer a retry. A `true` result does not confirm that the page loaded or that a rating was submitted. The direct link bypasses native prompt suppression, but still depends on App Store availability, connectivity, and the user’s ability to review the app.

## Automatic opportunities

Keep a controller owned by your app and record the events used by its conditions:

```swift
let reviewController = AutomaticReviewPromptController(
    conditions: [.launchCount(atLeast: 5), .daysSinceLastPrompt(atLeast: 30)]
)

// Record once per app launch through your app's launch lifecycle.
await reviewController.recordLaunch()
```

Attach the modifier where an automatic opportunity should be evaluated:

```swift
ContentView()
    .automaticReviewPrompt(controller: reviewController)
```

Without `prePromptTitle`, this requests the native in-app review dialog. Apple controls whether it appears; the SDK cannot detect suppression or review submission. It does not automatically open an external page when the native request is suppressed.

If using the SDK’s optional alert:

```swift
ContentView()
    .automaticReviewPrompt(
        controller: reviewController,
        prePromptTitle: "Enjoying the app?"
    )
```

“Rate App” opens the App Store review page because it is an explicit user action. “Maybe Later” dismisses the alert and records a dismissal. The cooldown begins when the alert is presented. Direct calls to `openReviewPage()` do not evaluate or change automatic prompt conditions or cooldowns.

## Migrating existing integrations

Replace manual `ReviewPrompt.request()` calls with `Task { await ReviewPrompt.openReviewPage() }` inside synchronous SwiftUI button actions. Keep `request()` for automatic opportunities. Existing SDK alert integrations get the corrected “Rate App” behavior after upgrading, with no call-site changes.

Validate the explicit action on a device using a published app ID. Test native prompt behavior separately: a visible development dialog does not establish that the production system will display it. The SDK does not track whether a user completed a review.

See the [changelog](../CHANGELOG.md) for release and migration details and the [README](../README.md) for other SDK integrations.
