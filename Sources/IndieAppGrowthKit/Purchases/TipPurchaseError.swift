import Foundation

/// Errors surfaced by ``TipStore`` beyond the outcomes already modeled by
/// ``TipPurchaseOutcome`` (cancelled, pending are outcomes, not errors).
public enum TipPurchaseError: Error, Equatable, Sendable {
    /// The signed transaction/receipt failed StoreKit's cryptographic verification.
    case verificationFailed
    /// No product was found for the requested identifier.
    case productNotFound
}

/// The result of a successfully *submitted* purchase request. `.success`
/// means the transaction was verified and finished; `.pending` and
/// `.cancelled` are not errors — StoreKit purchase requests can legitimately
/// end either way (e.g. Ask to Buy, or the user dismissing the payment sheet).
public enum TipPurchaseOutcome: Equatable, Sendable {
    case success
    case pending
    case cancelled
}
