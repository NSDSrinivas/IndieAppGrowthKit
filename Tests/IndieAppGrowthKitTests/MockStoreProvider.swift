import StoreKit
@testable import IndieAppGrowthKit

/// A `StoreProviding` mock for logic that doesn't require a real `Product`
/// or `Transaction` instance (both types have no public initializer, so
/// paths that need a real one — a successful purchase, a restored
/// transaction — are covered separately by StoreKitTest-based integration
/// tests instead).
final class MockStoreProvider: StoreProviding, @unchecked Sendable {
    var productsError: Error?
    var unfinishedTransactionsResult: [VerificationResult<Transaction>] = []
    private(set) var finishCallCount = 0

    func products(for identifiers: [String]) async throws -> [Product] {
        if let productsError { throw productsError }
        return []
    }

    func purchase(_ product: Product) async throws -> Product.PurchaseResult {
        fatalError("Not exercised by mock-based tests: requires a real Product instance.")
    }

    func unfinishedTransactions() async -> [VerificationResult<Transaction>] {
        unfinishedTransactionsResult
    }

    func finish(_ transaction: Transaction) async {
        finishCallCount += 1
    }

    var transactionUpdates: AsyncStream<VerificationResult<Transaction>> {
        AsyncStream { $0.finish() }
    }
}

struct MockError: Error, Equatable {
    let message: String
}
