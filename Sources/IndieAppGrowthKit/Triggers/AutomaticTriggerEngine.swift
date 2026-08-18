@preconcurrency import Foundation

/// Generic, reusable engine behind every automatic prompt in the SDK (tip
/// prompt, review prompt, What's New card, ...). Each feature owns its own
/// `AutomaticTriggerEngine` instance under its own `namespace`, so state and
/// conditions are independent per feature even though the mechanism is shared.
///
/// State is persisted on-device only (`UserDefaults`), consistent with the
/// SDK's no-backend design. This engine only knows about launches, sessions,
/// time, dismissals, and developer-reported custom signals — feature-specific
/// suppression (e.g. "never prompt if the user already tipped") is the
/// caller's responsibility, since this engine has no way to know that.
public actor AutomaticTriggerEngine {
    private let namespace: String
    private let userDefaults: UserDefaults
    private let now: @Sendable () -> Date
    private var cachedState: TriggerState

    private var storageKey: String { "com.indieappgrowthkit.trigger.\(namespace)" }

    public init(
        namespace: String,
        userDefaults: UserDefaults = .standard,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.namespace = namespace
        self.userDefaults = userDefaults
        self.now = now
        self.cachedState = Self.load(key: "com.indieappgrowthkit.trigger.\(namespace)", userDefaults: userDefaults)
    }

    public var state: TriggerState { cachedState }

    /// Call once per app launch. Sets the install date on the very first call.
    @discardableResult
    public func recordLaunch() -> TriggerState {
        cachedState.launchCount += 1
        if cachedState.installDate == nil {
            cachedState.installDate = now()
        }
        persist()
        return cachedState
    }

    /// Call on each foreground/session start, as an alternative granularity to launch count.
    public func recordSession() {
        cachedState.sessionCount += 1
        persist()
    }

    /// Reports a developer-defined "positive moment" (e.g. "completedOnboarding").
    public func recordCustomSignal(_ name: String) {
        cachedState.customSignals.insert(name)
        persist()
    }

    /// Call when this namespace's prompt is actually shown to the user, so
    /// `.daysSinceLastPrompt` cooldowns are measured from it.
    public func recordPromptShown() {
        cachedState.lastPromptDate = now()
        persist()
    }

    /// Call when the user dismisses/declines this namespace's prompt.
    public func recordDismiss() {
        cachedState.dismissCount += 1
        persist()
    }

    /// Clears all persisted state for this namespace. Intended for the debug
    /// overlay (M13) and for testing — not something a shipping app calls.
    public func reset() {
        cachedState = .empty
        persist()
    }

    /// Whether every condition is satisfied (AND-combined).
    public func evaluate(_ conditions: [TriggerCondition]) -> Bool {
        conditions.allSatisfy(isSatisfied)
    }

    private func isSatisfied(_ condition: TriggerCondition) -> Bool {
        switch condition {
        case .launchCount(let atLeast):
            return cachedState.launchCount >= atLeast
        case .daysSinceInstall(let atLeast):
            guard let installDate = cachedState.installDate else { return false }
            return daysBetween(installDate, now()) >= atLeast
        case .daysSinceLastPrompt(let atLeast):
            guard let lastPromptDate = cachedState.lastPromptDate else { return true }
            return daysBetween(lastPromptDate, now()) >= atLeast
        case .sessionCount(let atLeast):
            return cachedState.sessionCount >= atLeast
        case .customSignal(let name):
            return cachedState.customSignals.contains(name)
        case .dismissCountBelow(let maximum):
            return cachedState.dismissCount < maximum
        }
    }

    private func daysBetween(_ start: Date, _ end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(cachedState) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private static func load(key: String, userDefaults: UserDefaults) -> TriggerState {
        guard let data = userDefaults.data(forKey: key),
              let state = try? JSONDecoder().decode(TriggerState.self, from: data) else {
            return .empty
        }
        return state
    }
}
