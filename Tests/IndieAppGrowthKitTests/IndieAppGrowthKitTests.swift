import XCTest
@testable import IndieAppGrowthKit

final class IndieAppGrowthKitTests: XCTestCase {
    func testConfigurationInit() {
        let config = IndieAppGrowthKit.Configuration(
            tipProductIdentifiers: ["com.example.tip.small"],
            appStoreID: "123456789"
        )
        XCTAssertEqual(config.tipProductIdentifiers, ["com.example.tip.small"])
        XCTAssertEqual(config.appStoreID, "123456789")
    }

    func testConfigureExposesConfigurationAndTipStore() {
        IndieAppGrowthKit.configure(
            .init(tipProductIdentifiers: ["com.example.tip.small"], appStoreID: "987654321")
        )
        XCTAssertEqual(IndieAppGrowthKit.configuration.appStoreID, "987654321")
        // Accessing tipStore shouldn't trap once configure(_:) has been called.
        _ = IndieAppGrowthKit.tipStore
    }
}
