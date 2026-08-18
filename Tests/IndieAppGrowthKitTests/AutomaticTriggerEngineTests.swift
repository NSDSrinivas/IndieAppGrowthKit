import XCTest
@preconcurrency import Foundation
@testable import IndieAppGrowthKit

final class AutomaticTriggerEngineTests: XCTestCase {
    private nonisolated(unsafe) var defaults: UserDefaults!
    private nonisolated(unsafe) var suiteName: String!

    override func setUp() {
        suiteName = "AutomaticTriggerEngineTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func makeEngine(now: @escaping @Sendable () -> Date = { Date() }) -> AutomaticTriggerEngine {
        AutomaticTriggerEngine(namespace: "test", userDefaults: defaults, now: now)
    }

    /// A mutable, Sendable box for tests that need to advance a fake clock
    /// across `await` points.
    private final class MutableDate: @unchecked Sendable {
        var value: Date
        init(_ value: Date) { self.value = value }
    }

    func testLaunchCountCondition() async {
        let engine = makeEngine()
        let result1 = await engine.evaluate([.launchCount(atLeast: 3)])
        XCTAssertFalse(result1)

        await engine.recordLaunch()
        await engine.recordLaunch()
        let result2 = await engine.evaluate([.launchCount(atLeast: 3)])
        XCTAssertFalse(result2)

        await engine.recordLaunch()
        let result3 = await engine.evaluate([.launchCount(atLeast: 3)])
        XCTAssertTrue(result3)
    }

    func testDaysSinceInstallCondition() async {
        let clock = MutableDate(Date(timeIntervalSince1970: 0))
        let engine = makeEngine(now: { clock.value })

        await engine.recordLaunch() // sets installDate = day 0
        let tooSoon = await engine.evaluate([.daysSinceInstall(atLeast: 3)])
        XCTAssertFalse(tooSoon)

        clock.value = clock.value.addingTimeInterval(3 * 86400)
        let readyNow = await engine.evaluate([.daysSinceInstall(atLeast: 3)])
        XCTAssertTrue(readyNow)
    }

    func testDaysSinceInstallWithNoInstallDateNeverFires() async {
        let engine = makeEngine()
        let result = await engine.evaluate([.daysSinceInstall(atLeast: 0)])
        XCTAssertFalse(result)
    }

    func testDaysSinceLastPromptCooldown() async {
        let clock = MutableDate(Date(timeIntervalSince1970: 0))
        let engine = makeEngine(now: { clock.value })

        // No prompt shown yet: cooldown condition is trivially satisfied.
        let beforeAnyPrompt = await engine.evaluate([.daysSinceLastPrompt(atLeast: 7)])
        XCTAssertTrue(beforeAnyPrompt)

        await engine.recordPromptShown()
        let immediatelyAfter = await engine.evaluate([.daysSinceLastPrompt(atLeast: 7)])
        XCTAssertFalse(immediatelyAfter)

        clock.value = clock.value.addingTimeInterval(7 * 86400)
        let afterCooldown = await engine.evaluate([.daysSinceLastPrompt(atLeast: 7)])
        XCTAssertTrue(afterCooldown)
    }

    func testSessionCountCondition() async {
        let engine = makeEngine()
        await engine.recordSession()
        await engine.recordSession()
        let notYet = await engine.evaluate([.sessionCount(atLeast: 3)])
        XCTAssertFalse(notYet)
        await engine.recordSession()
        let now = await engine.evaluate([.sessionCount(atLeast: 3)])
        XCTAssertTrue(now)
    }

    func testCustomSignalCondition() async {
        let engine = makeEngine()
        let before = await engine.evaluate([.customSignal("completedOnboarding")])
        XCTAssertFalse(before)

        await engine.recordCustomSignal("completedOnboarding")
        let after = await engine.evaluate([.customSignal("completedOnboarding")])
        XCTAssertTrue(after)

        let otherSignal = await engine.evaluate([.customSignal("otherSignal")])
        XCTAssertFalse(otherSignal)
    }

    func testDismissCountBelowSuppression() async {
        let engine = makeEngine()
        let before = await engine.evaluate([.dismissCountBelow(maximum: 2)])
        XCTAssertTrue(before)

        await engine.recordDismiss()
        let afterOne = await engine.evaluate([.dismissCountBelow(maximum: 2)])
        XCTAssertTrue(afterOne)

        await engine.recordDismiss()
        let afterTwo = await engine.evaluate([.dismissCountBelow(maximum: 2)])
        XCTAssertFalse(afterTwo)
    }

    func testConditionsAreANDCombined() async {
        let engine = makeEngine()
        await engine.recordLaunch()
        await engine.recordLaunch()
        await engine.recordCustomSignal("didX")

        // launchCount satisfied, sessionCount not.
        let result = await engine.evaluate([.launchCount(atLeast: 2), .sessionCount(atLeast: 1), .customSignal("didX")])
        XCTAssertFalse(result)

        await engine.recordSession()
        let result2 = await engine.evaluate([.launchCount(atLeast: 2), .sessionCount(atLeast: 1), .customSignal("didX")])
        XCTAssertTrue(result2)
    }

    func testStatePersistsAcrossEngineInstances() async {
        let engine1 = makeEngine()
        await engine1.recordLaunch()
        await engine1.recordLaunch()
        await engine1.recordCustomSignal("x")

        let engine2 = makeEngine()
        let state = await engine2.state
        XCTAssertEqual(state.launchCount, 2)
        XCTAssertTrue(state.customSignals.contains("x"))
    }

    func testResetClearsState() async {
        let engine = makeEngine()
        await engine.recordLaunch()
        await engine.recordDismiss()
        await engine.reset()

        let state = await engine.state
        XCTAssertEqual(state, .empty)
    }

    func testDifferentNamespacesAreIndependent() async {
        let tipEngine = AutomaticTriggerEngine(namespace: "tip", userDefaults: defaults)
        let reviewEngine = AutomaticTriggerEngine(namespace: "review", userDefaults: defaults)

        await tipEngine.recordLaunch()
        await tipEngine.recordLaunch()

        let tipState = await tipEngine.state
        let reviewState = await reviewEngine.state
        XCTAssertEqual(tipState.launchCount, 2)
        XCTAssertEqual(reviewState.launchCount, 0)
    }
}
