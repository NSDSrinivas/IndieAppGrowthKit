import XCTest
@testable import IndieAppGrowthKit

final class TipHistoryTests: XCTestCase {
    private let productIdentifiers = ["com.indieappgrowthkit.test.tip.small"]

    func testNoTransactionsMeansNoHistory() async {
        let mock = MockStoreProvider()
        let store = TipStore(productIdentifiers: productIdentifiers, storeProvider: mock)

        let history = await store.tipHistory()

        XCTAssertEqual(history, .none)
        XCTAssertFalse(history.hasTipped)
        XCTAssertEqual(history.tipCount, 0)
        XCTAssertTrue(history.totalsByCurrency.isEmpty)
    }
}
