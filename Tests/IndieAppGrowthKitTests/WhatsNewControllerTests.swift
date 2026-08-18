import XCTest
@preconcurrency import Foundation
@testable import IndieAppGrowthKit

final class WhatsNewControllerTests: XCTestCase {
    private nonisolated(unsafe) var defaults: UserDefaults!
    private nonisolated(unsafe) var suiteName: String!

    override func setUp() {
        suiteName = "WhatsNewControllerTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testShowsOnFirstLaunchOfAKnownVersion() async {
        let controller = WhatsNewController(userDefaults: defaults, currentVersion: { "1.0" })
        let shouldShow = await controller.shouldShowWhatsNew()
        XCTAssertTrue(shouldShow)
    }

    func testDoesNotShowAgainAfterMarkedShown() async {
        let controller = WhatsNewController(userDefaults: defaults, currentVersion: { "1.0" })
        await controller.markShown()
        let shouldShow = await controller.shouldShowWhatsNew()
        XCTAssertFalse(shouldShow)
    }

    private final class MutableVersion: @unchecked Sendable {
        var value: String
        init(_ value: String) { self.value = value }
    }

    func testShowsAgainAfterVersionBump() async {
        let version = MutableVersion("1.0")
        let controller = WhatsNewController(userDefaults: defaults, currentVersion: { version.value })
        await controller.markShown()
        let shouldShowSameVersion = await controller.shouldShowWhatsNew()
        XCTAssertFalse(shouldShowSameVersion)

        version.value = "1.1"
        let shouldShowNewVersion = await controller.shouldShowWhatsNew()
        XCTAssertTrue(shouldShowNewVersion)
    }

    func testUnknownVersionNeverShows() async {
        let controller = WhatsNewController(userDefaults: defaults, currentVersion: { nil })
        let shouldShow = await controller.shouldShowWhatsNew()
        XCTAssertFalse(shouldShow)
    }

    func testResetClearsState() async {
        let controller = WhatsNewController(userDefaults: defaults, currentVersion: { "1.0" })
        await controller.markShown()
        await controller.reset()
        let shouldShow = await controller.shouldShowWhatsNew()
        XCTAssertTrue(shouldShow)
    }
}
