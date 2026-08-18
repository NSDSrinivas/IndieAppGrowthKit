@preconcurrency import Foundation

/// Drives the automatic (developer-configured) Tip Jar prompt: wraps an
/// ``AutomaticTriggerEngine`` under the `"tip"` namespace with feature-specific
/// suppression the generic engine can't know about — never prompt again once
/// the user has already tipped.
public actor AutomaticTipPromptController {
    private let engine: AutomaticTriggerEngine
    private let conditions: [TriggerCondition]
    private let tipStore: TipStore

    /// - Parameters:
    ///   - conditions: AND-combined trigger conditions, e.g.
    ///     `[.launchCount(atLeast: 3), .daysSinceLastPrompt(atLeast: 7), .dismissCountBelow(maximum: 3)]`.
    ///   - tipStore: Used to suppress the prompt once the user has already tipped.
    public init(
        conditions: [TriggerCondition],
        tipStore: TipStore,
        engine: AutomaticTriggerEngine = AutomaticTriggerEngine(namespace: "tip")
    ) {
        self.engine = engine
        self.conditions = conditions
        self.tipStore = tipStore
    }

    /// Call once per app launch.
    public func recordLaunch() async {
        await engine.recordLaunch()
    }

    /// Call on each foreground/session start.
    public func recordSession() async {
        await engine.recordSession()
    }

    /// Reports a developer-defined positive-moment signal this controller's conditions may depend on.
    public func recordCustomSignal(_ name: String) async {
        await engine.recordCustomSignal(name)
    }

    /// Whether the automatic Tip Jar prompt should be shown right now.
    public func shouldShowPrompt() async -> Bool {
        let history = await tipStore.tipHistory()
        guard !history.hasTipped else { return false }
        return await engine.evaluate(conditions)
    }

    /// Call when the prompt is actually presented to the user.
    public func recordPromptShown() async {
        await engine.recordPromptShown()
    }

    /// Call when the user dismisses the prompt without tipping.
    public func recordDismiss() async {
        await engine.recordDismiss()
    }

    /// Live trigger-engine state, for the debug overlay (M13).
    public func debugState() async -> TriggerState {
        await engine.state
    }

    /// Clears persisted trigger state. Debug/testing only.
    public func reset() async {
        await engine.reset()
    }
}
