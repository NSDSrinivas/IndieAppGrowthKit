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

    func testMissingOrInvalidRecipientDoesNotProduceURL() {
        for email: String? in [nil, "", "  ", "invalid", "@example.com", "support@", "a@example.com?bcc=other@example.com"] {
            XCTAssertNil(FeedbackMail.composeURL(to: email, subject: "", body: ""))
        }
    }

    func testMailContentRoundTripsWithoutAddingHeaders() {
        let subject = "Help #1 & details? 100%"
        let body = "Line one\nMore + = & # details"
        let url = FeedbackMail.composeURL(to: " support@example.com ", subject: subject, body: body)!
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(components.path, "support@example.com")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: body)])
    }

    @MainActor
    func testMissingExplicitEmailDoesNotOpenClient() {
        XCTAssertFalse(FeedbackMail.openComposer(to: nil))
        XCTAssertFalse(FeedbackMail.openComposer(to: " "))
    }

    func testDiagnosticsBodyIncludesExtraTextAndDiagnostics() {
        let body = FeedbackMail.diagnosticsBody(extra: "The button does nothing")
        XCTAssertTrue(body.contains("The button does nothing"))
        XCTAssertTrue(body.contains("App version:"))
        XCTAssertTrue(body.contains("OS:"))
    }
}
