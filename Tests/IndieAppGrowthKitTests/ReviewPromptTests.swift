import XCTest
@testable import IndieAppGrowthKit

final class ReviewPromptTests: XCTestCase {
    func testReviewLinkTargetsWriteReviewPage() {
        XCTAssertEqual(
            ReviewPrompt.reviewURL(appStoreID: " 123456789\n")?.absoluteString,
            "https://apps.apple.com/app/id123456789?action=write-review"
        )
    }

    @MainActor
    func testInvalidIDsNeverOpenURL() async {
        for id in ["", " ", "0", "000", "abc", "１２３", "123?other=value", "123/456", "-123"] {
            let result = await ReviewPrompt.openReviewPage(appStoreID: id) { _ in
                XCTFail("Invalid ID must not open a URL: \(id)")
                return true
            }
            XCTAssertFalse(result)
        }
    }

    @MainActor
    func testOpeningResultIsPropagated() async {
        for expected in [true, false] {
            var openedURLs: [URL] = []
            let result = await ReviewPrompt.openReviewPage(appStoreID: "123456789") { url in
                openedURLs.append(url)
                return expected
            }
            XCTAssertEqual(result, expected)
            XCTAssertEqual(openedURLs.map(\.absoluteString), [
                "https://apps.apple.com/app/id123456789?action=write-review"
            ])
        }
    }
}
