import XCTest
@testable import IndieAppGrowthKit

final class TipJarViewSupportTests: XCTestCase {
    func testTipJarCompletionEquality() {
        XCTAssertEqual(TipJarCompletion.success(productIdentifier: "a"), .success(productIdentifier: "a"))
        XCTAssertNotEqual(TipJarCompletion.success(productIdentifier: "a"), .success(productIdentifier: "b"))
        XCTAssertEqual(TipJarCompletion.cancelled, .cancelled)
        XCTAssertEqual(TipJarCompletion.pending, .pending)
        XCTAssertNotEqual(TipJarCompletion.failed("x"), .failed("y"))
    }

    func testRepositoryLinkIsAGitHubURL() {
        XCTAssertEqual(IndieAppGrowthKitLinks.repository.host, "github.com")
    }
}
