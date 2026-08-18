import Foundation

/// One entry in a ``CrossPromotionView`` list: another app by the same developer.
public struct PromotedApp: Identifiable, Equatable, Sendable {
    public var id: String { appStoreID }
    public let appStoreID: String
    public let name: String
    public let tagline: String
    /// SF Symbol name shown as a stand-in icon (no image loading of any kind
    /// — an actual icon would need the host app to supply a bundled asset,
    /// which is a display-layer concern for `iconView` to add later, not this model).
    public let systemImage: String

    public init(appStoreID: String, name: String, tagline: String, systemImage: String = "app.badge") {
        self.appStoreID = appStoreID
        self.name = name
        self.tagline = tagline
        self.systemImage = systemImage
    }

    var appStoreURL: URL { AppStoreLink.url(forAppStoreID: appStoreID) }
}
