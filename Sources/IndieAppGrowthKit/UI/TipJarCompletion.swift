import Foundation

/// The result reported to ``TipJarView``'s completion callback.
public enum TipJarCompletion: Equatable, Sendable {
    case success(productIdentifier: String)
    case cancelled
    case pending
    case failed(String)
}
