import XCTest
@testable import IndieAppGrowthKit

final class PromotedAppTests: XCTestCase {
    func testIDMatchesAppStoreID() {
        let app = PromotedApp(appStoreID: "111222333", name: "Other App", tagline: "Also by us")
        XCTAssertEqual(app.id, "111222333")
    }

    func testAppStoreURLIsConstructedFromID() {
        let app = PromotedApp(appStoreID: "111222333", name: "Other App", tagline: "Also by us")
        XCTAssertEqual(app.appStoreURL.absoluteString, "https://apps.apple.com/app/id111222333")
    }
}
