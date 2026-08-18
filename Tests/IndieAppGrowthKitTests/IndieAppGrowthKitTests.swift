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
}
