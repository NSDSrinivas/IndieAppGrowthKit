import XCTest
@testable import IndieAppGrowthKit

/// Logic-level tests that don't require a real `Product`/`Transaction`
/// instance, so they run reliably in any environment (CLI `swift test`
/// included). Purchase-flow tests that need real StoreKit types live in
/// TipStoreStoreKitTestTests.swift instead.
final class TipStoreTests: XCTestCase {
    private let productIdentifiers = [
        "com.indieappgrowthkit.test.tip.small",
        "com.indieappgrowthkit.test.tip.medium",
        "com.indieappgrowthkit.test.tip.large",
    ]

    func testStartPropagatesProductLoadError() async {
        let mock = MockStoreProvider()
        mock.productsError = MockError(message: "network unavailable")
        let store = TipStore(productIdentifiers: productIdentifiers, storeProvider: mock)

        do {
            try await store.start()
            XCTFail("Expected product load error to propagate")
        } catch let error as MockError {
            XCTAssertEqual(error, MockError(message: "network unavailable"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testStartWithNoUnfinishedTransactionsDoesNotFinishAnything() async throws {
        let mock = MockStoreProvider()
        mock.unfinishedTransactionsResult = []
        let store = TipStore(productIdentifiers: productIdentifiers, storeProvider: mock)

        try await store.start()

        XCTAssertEqual(mock.finishCallCount, 0)
    }

    func testPurchaseUnknownIdentifierThrowsProductNotFoundWithoutCallingStore() async throws {
        let mock = MockStoreProvider()
        let store = TipStore(productIdentifiers: productIdentifiers, storeProvider: mock)
        try await store.start()

        do {
            _ = try await store.purchase(identifier: "com.indieappgrowthkit.test.tip.nonexistent")
            XCTFail("Expected productNotFound to be thrown")
        } catch TipPurchaseError.productNotFound {
            // expected — and since mock.purchase(_:) would fatalError if called,
            // reaching here also proves the store never called into the provider.
        }
    }
}
