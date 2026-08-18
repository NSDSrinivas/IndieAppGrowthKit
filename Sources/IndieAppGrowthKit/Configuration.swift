import Foundation

extension IndieAppGrowthKit {

    /// Host app configuration for Indie App Growth Kit.
    public struct Configuration {
        /// Product identifiers for the tip tiers, configured in App Store Connect.
        public var tipProductIdentifiers: [String]

        /// The host app's App Store ID, used for sharing and review prompts.
        public var appStoreID: String

        public init(tipProductIdentifiers: [String], appStoreID: String) {
            self.tipProductIdentifiers = tipProductIdentifiers
            self.appStoreID = appStoreID
        }
    }
}
