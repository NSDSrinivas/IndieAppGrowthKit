import Foundation

/// Drives the automatic App Store review prompt, mirroring
/// ``AutomaticTipPromptController`` but under its own `"review"` namespace
/// and independent conditions/state — a host app can configure completely
/// different thresholds for reviews vs. tips.
public actor AutomaticReviewPromptController {
    private let engine: AutomaticTriggerEngine
    private let conditions: [TriggerCondition]

    public init(
        conditions: [TriggerCondition],
        engine: AutomaticTriggerEngine = AutomaticTriggerEngine(namespace: "review")
    ) {
        self.engine = engine
        self.conditions = conditions
    }

    public func recordLaunch() async {
        await engine.recordLaunch()
    }

    public func recordSession() async {
        await engine.recordSession()
    }

    /// Reports a developer-defined signal, e.g. "successfulTip", so review
    /// prompts can be conditioned on tipping via `.customSignal("successfulTip")`.
    public func recordCustomSignal(_ name: String) async {
        await engine.recordCustomSignal(name)
    }

    public func shouldShowPrompt() async -> Bool {
        await engine.evaluate(conditions)
    }

    public func recordPromptShown() async {
        await engine.recordPromptShown()
    }

    public func recordDismiss() async {
        await engine.recordDismiss()
    }

    /// Live trigger-engine state, for the debug overlay (M13).
    public func debugState() async -> TriggerState {
        await engine.state
    }

    public func reset() async {
        await engine.reset()
    }
}
