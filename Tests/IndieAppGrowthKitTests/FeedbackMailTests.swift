import XCTest
@testable import IndieAppGrowthKit

final class FeedbackMailTests: XCTestCase {
    func testComposeURLPercentEncodesSubjectAndBody() {
        let url = FeedbackMail.composeURL(to: "support@example.com", subject: "Bug: crash & freeze", body: "It broke on launch")
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "mailto")
        let string = url!.absoluteString
        XCTAssertTrue(string.hasPrefix("mailto:support@example.com?"))
        XCTAssertTrue(string.contains("subject=Bug%3A%20crash%20%26%20freeze") || string.contains("subject=Bug:%20crash%20%26%20freeze"))
        XCTAssertTrue(string.contains("body=It%20broke%20on%20launch"))
    }

    func testDiagnosticsBodyIncludesExtraTextAndDiagnostics() {
        let body = FeedbackMail.diagnosticsBody(extra: "The button does nothing")
        XCTAssertTrue(body.contains("The button does nothing"))
        XCTAssertTrue(body.contains("App version:"))
        XCTAssertTrue(body.contains("OS:"))
    }
}
