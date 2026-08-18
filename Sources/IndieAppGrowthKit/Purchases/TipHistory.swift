import Foundation

/// The user's local tipping history, computed from their finished transactions.
public struct TipHistory: Equatable, Sendable {
    public let hasTipped: Bool
    public let tipCount: Int
    /// Lifetime tip total, keyed by currency code (e.g. "USD"), since a user
    /// could tip across storefronts/currencies over the app's lifetime.
    public let totalsByCurrency: [String: Decimal]

    public init(hasTipped: Bool, tipCount: Int, totalsByCurrency: [String: Decimal]) {
        self.hasTipped = hasTipped
        self.tipCount = tipCount
        self.totalsByCurrency = totalsByCurrency
    }

    public static let none = TipHistory(hasTipped: false, tipCount: 0, totalsByCurrency: [:])
}
