import Foundation

extension IndieAppGrowthKit {

    /// Host app configuration for Indie App Growth Kit.
    public struct Configuration {
        /// Product identifiers for the tip tiers, configured in App Store Connect.
        public var tipProductIdentifiers: [String]

        /// The host app's App Store ID, used for sharing and review prompts.
        public var appStoreID: String

        /// Optional recipient for email support, opened only by an explicit host-app action.
        public var supportEmail: String?

        public init(tipProductIdentifiers: [String], appStoreID: String, supportEmail: String? = nil) {
            self.tipProductIdentifiers = tipProductIdentifiers
            self.appStoreID = appStoreID
            self.supportEmail = supportEmail
        }
    }
}
