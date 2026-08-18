import StoreKit

/// Abstracts the subset of StoreKit 2 that ``TipStore`` needs, so purchase
/// logic can be unit-tested against a mock instead of real StoreKit.
public protocol StoreProviding: Sendable {
    func products(for identifiers: [String]) async throws -> [Product]
    func purchase(_ product: Product) async throws -> Product.PurchaseResult
    func unfinishedTransactions() async -> [VerificationResult<Transaction>]
    func finish(_ transaction: Transaction) async
    var transactionUpdates: AsyncStream<VerificationResult<Transaction>> { get }
    /// All of the user's transactions recorded on this device, finished or not.
    func allTransactions() async -> [VerificationResult<Transaction>]
}

/// Real ``StoreProviding`` implementation backed by StoreKit 2.
public struct StoreKitProvider: StoreProviding {
    public init() {}

    public func products(for identifiers: [String]) async throws -> [Product] {
        try await Product.products(for: identifiers)
    }

    public func purchase(_ product: Product) async throws -> Product.PurchaseResult {
        try await product.purchase()
    }

    public func unfinishedTransactions() async -> [VerificationResult<Transaction>] {
        var results: [VerificationResult<Transaction>] = []
        for await result in Transaction.unfinished {
            results.append(result)
        }
        return results
    }

    public func finish(_ transaction: Transaction) async {
        await transaction.finish()
    }

    public func allTransactions() async -> [VerificationResult<Transaction>] {
        var results: [VerificationResult<Transaction>] = []
        for await result in Transaction.all {
            results.append(result)
        }
        return results
    }

    public var transactionUpdates: AsyncStream<VerificationResult<Transaction>> {
        AsyncStream { continuation in
            let task = Task {
                for await update in Transaction.updates {
                    continuation.yield(update)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
