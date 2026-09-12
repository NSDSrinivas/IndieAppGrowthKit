import StoreKit
#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Review entry points: use ``request()`` for automatic prompts and
/// ``openReviewPage(appStoreID:)`` for explicit user actions.
public enum ReviewPrompt {
    /// Opens the App Store's write-review page for a user-triggered action.
    /// Uses the configured app ID unless an explicit ID is supplied.
    /// This bypasses StoreKit prompt suppression. Returns whether the system
    /// opened the URL, not whether the page loaded or a review was submitted.
    /// Invalid IDs return false without opening anything.
    @discardableResult
    @MainActor
    public static func openReviewPage(appStoreID: String? = nil) async -> Bool {
        await openReviewPage(
            appStoreID: appStoreID ?? IndieAppGrowthKit.configuration.appStoreID,
            openURL: { url in
                #if canImport(UIKit) && !os(watchOS)
                return await UIApplication.shared.open(url, options: [:])
                #elseif canImport(AppKit)
                return NSWorkspace.shared.open(url)
                #else
                return false
                #endif
            }
        )
    }

    @MainActor
    static func openReviewPage(
        appStoreID: String,
        openURL: (URL) async -> Bool
    ) async -> Bool {
        guard let url = reviewURL(appStoreID: appStoreID) else { return false }
        return await openURL(url)
    }

    static func reviewURL(appStoreID: String) -> URL? {
        let id = appStoreID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, id.utf8.allSatisfy({ (48...57).contains($0) }),
              id.utf8.contains(where: { $0 != 48 }) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }

    /// Requests a review using the app's active window/scene, found
    /// automatically. A no-op if no active window/scene can be found (e.g.
    /// called before the app has finished launching). Apple may suppress this
    /// prompt. For buttons and alert actions, use ``openReviewPage(appStoreID:)``.
    @MainActor
    public static func request() {
        #if canImport(UIKit) && !os(watchOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        AppStore.requestReview(in: scene)
        #elseif canImport(AppKit)
        guard let controller = NSApplication.shared.keyWindow?.contentViewController else { return }
        AppStore.requestReview(in: controller)
        #endif
    }
}
