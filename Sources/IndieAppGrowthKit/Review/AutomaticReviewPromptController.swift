import Foundation

/// Drives the automatic App Store review prompt, mirroring
/// ``AutomaticTipPromptController`` but under its own `"review"` namespace
/// and independent conditions/state — a host app can configure completely
/// different thresholds for reviews vs. tips.
public actor AutomaticReviewPromptController {
    private let engine: AutomaticTriggerEngine
    private let conditions: [TriggerCondition]

    private let resetOnAppVersionChange: Bool
    private let currentVersion: @Sendable () -> String?

    /// Opt in to resetting review activity and cooldowns when the host app's
    /// public version changes. The install date is preserved. The first known
    /// version is a baseline and does not reset existing state.
    public init(
        conditions: [TriggerCondition],
        engine: AutomaticTriggerEngine = AutomaticTriggerEngine(namespace: "review"),
        resetOnAppVersionChange: Bool = false,
        currentVersion: @escaping @Sendable () -> String? = {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
    ) {
        self.engine = engine
        self.conditions = conditions
        self.resetOnAppVersionChange = resetOnAppVersionChange
        self.currentVersion = currentVersion
    }

    public func recordLaunch() async {
        await prepareForCurrentVersion()
        await engine.recordLaunch()
    }

    public func recordSession() async {
        await prepareForCurrentVersion()
        await engine.recordSession()
    }

    /// Reports a developer-defined signal, e.g. "successfulTip", so review
    /// prompts can be conditioned on tipping via `.customSignal("successfulTip")`.
    public func recordCustomSignal(_ name: String) async {
        await prepareForCurrentVersion()
        await engine.recordCustomSignal(name)
    }

    public func shouldShowPrompt() async -> Bool {
        await prepareForCurrentVersion()
        return await engine.evaluate(conditions)
    }

    public func recordPromptShown() async {
        await prepareForCurrentVersion()
        await engine.recordPromptShown()
    }

    public func recordDismiss() async {
        await prepareForCurrentVersion()
        await engine.recordDismiss()
    }

    /// Live trigger-engine state, for the debug overlay (M13).
    public func debugState() async -> TriggerState {
        await prepareForCurrentVersion()
        return await engine.state
    }

    public func reset() async {
        await prepareForCurrentVersion()
        await engine.reset()
    }

    private func prepareForCurrentVersion() async {
        await engine.prepareForAppVersion(currentVersion(), resetOnChange: resetOnAppVersionChange)
    }

}
