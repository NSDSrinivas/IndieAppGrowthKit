import Foundation

/// A single condition an ``AutomaticTriggerEngine`` can require before firing.
/// All conditions passed to `evaluate(conditions:)` are AND-combined.
public enum TriggerCondition: Equatable, Sendable {
    /// Fires once the app has been launched at least `count` times.
    case launchCount(atLeast: Int)
    /// Fires once at least `days` have passed since first launch.
    case daysSinceInstall(atLeast: Int)
    /// Cooldown: fires only if at least `days` have passed since this
    /// engine's namespace last recorded a prompt being shown (or always, if
    /// no prompt has been shown yet).
    case daysSinceLastPrompt(atLeast: Int)
    /// Fires once at least `count` foreground sessions have been recorded.
    case sessionCount(atLeast: Int)
    /// Fires only after the host app has reported this named custom signal
    /// (e.g. "completedOnboarding") at least once.
    case customSignal(String)
    /// Suppresses firing once the user has dismissed this namespace's prompt
    /// `maximum` times or more, so a repeatedly-declined prompt eventually
    /// stops asking.
    case dismissCountBelow(maximum: Int)
}
