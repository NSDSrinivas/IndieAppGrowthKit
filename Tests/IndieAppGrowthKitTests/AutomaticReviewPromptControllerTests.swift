import XCTest
@preconcurrency import Foundation
@testable import IndieAppGrowthKit

final class AutomaticReviewPromptControllerTests: XCTestCase {
    private nonisolated(unsafe) var defaults: UserDefaults!
    private nonisolated(unsafe) var suiteName: String!

    override func setUp() {
        suiteName = "AutomaticReviewPromptControllerTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testIndependentFromTipNamespace() async {
        let reviewEngine = AutomaticTriggerEngine(namespace: "review", userDefaults: defaults)
        let tipEngine = AutomaticTriggerEngine(namespace: "tip", userDefaults: defaults)
        let reviewController = AutomaticReviewPromptController(conditions: [.launchCount(atLeast: 5)], engine: reviewEngine)

        await tipEngine.recordLaunch()
        await tipEngine.recordLaunch()
        await tipEngine.recordLaunch()
        await tipEngine.recordLaunch()
        await tipEngine.recordLaunch()

        // Review engine's own launch count is still 0, unaffected by the tip engine.
        let shouldShow = await reviewController.shouldShowPrompt()
        XCTAssertFalse(shouldShow)
    }

    func testCustomSignalConditionForReviewAfterTip() async {
        let engine = AutomaticTriggerEngine(namespace: "review", userDefaults: defaults)
        let controller = AutomaticReviewPromptController(conditions: [.customSignal("successfulTip")], engine: engine)

        let before = await controller.shouldShowPrompt()
        XCTAssertFalse(before)

        await controller.recordCustomSignal("successfulTip")
        let after = await controller.shouldShowPrompt()
        XCTAssertTrue(after)
    }

    func testRecordDismissIncrementsDismissCount() async {
        let engine = AutomaticTriggerEngine(namespace: "review", userDefaults: defaults)
        let controller = AutomaticReviewPromptController(conditions: [], engine: engine)

        await controller.recordDismiss()
        let state = await controller.debugState()
        XCTAssertEqual(state.dismissCount, 1)
    }
}
