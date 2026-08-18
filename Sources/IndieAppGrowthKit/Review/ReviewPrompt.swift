import StoreKit
#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Triggers Apple's native App Store review prompt (`AppStore.requestReview`).
/// Callable directly by the host app at any time (not only via the
/// automatic-trigger path — see ``AutomaticReviewPromptController``).
public enum ReviewPrompt {
    /// Requests a review using the app's active window/scene, found
    /// automatically. A no-op if no active window/scene can be found (e.g.
    /// called before the app has finished launching).
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
