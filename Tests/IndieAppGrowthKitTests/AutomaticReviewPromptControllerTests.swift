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

    private func controller(version: String?, reset: Bool = false) -> AutomaticReviewPromptController {
        AutomaticReviewPromptController(
            conditions: [.launchCount(atLeast: 2), .daysSinceLastPrompt(atLeast: 30)],
            engine: AutomaticTriggerEngine(namespace: "review", userDefaults: defaults),
            resetOnAppVersionChange: reset,
            currentVersion: { version }
        )
    }

    func testVersionChangeResetsActivityBeforeRecordingNewLaunch() async {
        let old = controller(version: "1.0", reset: true)
        await old.recordLaunch()
        await old.recordSession()
        await old.recordCustomSignal("completedGoal")
        await old.recordPromptShown()
        await old.recordDismiss()
        let original = await old.debugState()

        let updated = controller(version: "2.0", reset: true)
        await updated.recordLaunch()
        let state = await updated.debugState()
        XCTAssertEqual(state.launchCount, 1)
        XCTAssertEqual(state.sessionCount, 0)
        XCTAssertEqual(state.dismissCount, 0)
        XCTAssertTrue(state.customSignals.isEmpty)
        XCTAssertNil(state.lastPromptDate)
        XCTAssertEqual(state.installDate, original.installDate)
        let beforeThreshold = await updated.shouldShowPrompt()
        XCTAssertFalse(beforeThreshold)
        await updated.recordLaunch()
        let afterThreshold = await updated.shouldShowPrompt()
        XCTAssertTrue(afterThreshold)

        let relaunched = controller(version: "2.0", reset: true)
        let persisted = await relaunched.debugState()
        XCTAssertEqual(persisted.launchCount, 2)
    }

    func testDefaultPreservesStateAcrossVersions() async {
        let old = controller(version: "1.0")
        await old.recordLaunch()
        await old.recordPromptShown()
        await old.recordDismiss()
        let original = await old.debugState()
        let updated = controller(version: "2.0")
        let state = await updated.debugState()
        XCTAssertEqual(state, original)
    }

    func testLegacyStateAndUnknownVersionsArePreserved() async {
        let engine = AutomaticTriggerEngine(namespace: "review", userDefaults: defaults)
        await engine.recordLaunch()
        await engine.recordPromptShown()
        let original = await engine.state
        for version: String? in [nil, "", "  ", "2.0", "2.0"] {
            let current = controller(version: version, reset: true)
            let state = await current.debugState()
            XCTAssertEqual(state, original)
        }
    }

    func testVersionResetBeforeSignalDoesNotAffectTips() async {
        let tip = AutomaticTriggerEngine(namespace: "tip", userDefaults: defaults)
        await tip.recordLaunch()
        let old = controller(version: "1.0", reset: true)
        await old.recordCustomSignal("old")
        let updated = controller(version: "2.0", reset: true)
        await updated.recordCustomSignal("new")
        let state = await updated.debugState()
        XCTAssertEqual(state.customSignals, ["new"])
        let tipState = await tip.state
        XCTAssertEqual(tipState.launchCount, 1)
    }

}
