import XCTest
@testable import IndieAppGrowthKit

final class ShareAppButtonTests: XCTestCase {
    func testAppStoreURLIsConstructedFromID() {
        let url = AppStoreLink.url(forAppStoreID: "123456789")
        XCTAssertEqual(url.absoluteString, "https://apps.apple.com/app/id123456789")
    }
}
