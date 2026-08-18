import XCTest
import StoreKit
import StoreKitTest
@testable import IndieAppGrowthKit

/// Full purchase-flow integration tests against a real local StoreKit test
/// session (backed by `TestTips.storekit`), exercising the real
/// `StoreKitProvider`. `Product`/`Transaction` have no public initializers,
/// so this — not hand-written mocks — is Apple's supported way to test the
/// success/restore paths.
///
/// `SKTestSession` requires the test bundle to run inside a code-signed host
/// app with local StoreKit testing entitlements. A bare `swift test` from
/// the command line doesn't provide that, so these tests skip (rather than
/// fail) when StoreKit reports `.notEntitled`; run them from Xcode
/// (`open Package.swift`) to actually exercise the purchase flow.
final class TipStoreStoreKitTestTests: XCTestCase {
    private var session: SKTestSession!

    private let productIdentifiers = [
        "com.indieappgrowthkit.test.tip.small",
        "com.indieappgrowthkit.test.tip.medium",
        "com.indieappgrowthkit.test.tip.large",
    ]

    override func setUpWithError() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "TestTips", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
    }

    override func tearDownWithError() throws {
        session?.clearTransactions()
        session = nil
    }

    /// Skips the test instead of failing when StoreKit refuses to operate
    /// because the process isn't a properly entitled host app.
    private func skipIfNotEntitled(_ error: Error) throws {
        if let storeKitError = error as? StoreKitError, case .notEntitled = storeKitError {
            throw XCTSkip("StoreKitTest requires a code-signed host app; run from Xcode instead of `swift test`.")
        }
        throw error
    }

    /// `Product.products(for:)` doesn't throw `.notEntitled` when the test
    /// session never actually activated — it just silently returns an empty
    /// list. So an empty product list after `start()` is also a sign we're
    /// running outside a properly entitled host app, not a real failure.
    private func startOrSkipIfUnavailable(_ store: TipStore) async throws {
        do {
            try await store.start()
        } catch {
            try skipIfNotEntitled(error)
        }
        if await store.products.isEmpty {
            throw XCTSkip("StoreKitTest session did not activate (no products loaded); run from Xcode instead of `swift test`.")
        }
    }

    func testLoadProducts() async throws {
        let store = TipStore(productIdentifiers: productIdentifiers)
        try await startOrSkipIfUnavailable(store)

        let loadedIdentifiers = Set(await store.products.map(\.id))
        XCTAssertEqual(loadedIdentifiers, Set(productIdentifiers))
    }

    func testSuccessfulPurchaseIsFinished() async throws {
        let store = TipStore(productIdentifiers: productIdentifiers)
        try await startOrSkipIfUnavailable(store)

        let outcome = try await store.purchase(identifier: "com.indieappgrowthkit.test.tip.small")
        XCTAssertEqual(outcome, .success)

        var unfinishedCount = 0
        for await _ in Transaction.unfinished { unfinishedCount += 1 }
        XCTAssertEqual(unfinishedCount, 0)
    }

    func testRestoresUnfinishedTransactionsOnStart() async throws {
        do {
            _ = try await session.buyProduct(identifier: "com.indieappgrowthkit.test.tip.medium")
        } catch {
            try skipIfNotEntitled(error)
            return
        }

        var unfinishedBefore = 0
        for await _ in Transaction.unfinished { unfinishedBefore += 1 }
        XCTAssertEqual(unfinishedBefore, 1)

        let store = TipStore(productIdentifiers: productIdentifiers)
        try await startOrSkipIfUnavailable(store)

        var unfinishedAfter = 0
        for await _ in Transaction.unfinished { unfinishedAfter += 1 }
        XCTAssertEqual(unfinishedAfter, 0)
    }
}
