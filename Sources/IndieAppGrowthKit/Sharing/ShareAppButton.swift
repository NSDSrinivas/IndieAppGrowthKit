import SwiftUI

/// A "share this app" control the host app places wherever it wants (e.g. a
/// Settings screen), pre-populated with the app's App Store link. Backed by
/// SwiftUI's `ShareLink`, so it presents the real native system share sheet
/// (`UIActivityViewController` on iOS, `NSSharingServicePicker` on macOS)
/// including AirDrop, Messages, Mail, and any installed social apps, with
/// correct iPad popover anchoring handled by the platform — no hand-rolled
/// `UIViewControllerRepresentable`/`NSViewRepresentable` needed.
///
/// - Note: `ShareLink` does not expose a completion callback for the share
///   sheet's outcome — that's a platform API limitation, not an omission
///   here. REQUIREMENTS.md's "outcome callback" is satisfied where the
///   platform makes it available; iOS/macOS's `ShareLink` currently doesn't.
public struct ShareAppButton<Label: View>: View {
    private let url: URL
    private let message: String?
    private let label: () -> Label

    /// - Parameters:
    ///   - appStoreID: The app's numeric App Store ID (as configured in `Configuration`).
    ///   - message: Optional developer-supplied share text shown alongside the link.
    ///   - label: The button's content. Defaults to a "Share App" label with a system icon.
    public init(appStoreID: String, message: String? = nil, @ViewBuilder label: @escaping () -> Label) {
        self.url = AppStoreLink.url(forAppStoreID: appStoreID)
        self.message = message
        self.label = label
    }

    public var body: some View {
        if let message {
            ShareLink(item: url, message: Text(message), label: label)
        } else {
            ShareLink(item: url, label: label)
        }
    }
}

extension ShareAppButton where Label == SwiftUI.Label<Text, Image> {
    public init(appStoreID: String, message: String? = nil) {
        self.init(appStoreID: appStoreID, message: message) {
            SwiftUI.Label("Share App", systemImage: "square.and.arrow.up")
        }
    }

    /// Convenience using the App Store ID from ``IndieAppGrowthKit/configure(_:)``,
    /// so the host app doesn't have to repeat it at every call site.
    public init(message: String? = nil) {
        self.init(appStoreID: IndieAppGrowthKit.configuration.appStoreID, message: message)
    }
}

enum AppStoreLink {
    static func url(forAppStoreID appStoreID: String) -> URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
    }
}
