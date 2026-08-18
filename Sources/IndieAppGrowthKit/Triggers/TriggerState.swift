import Foundation

/// A snapshot of an ``AutomaticTriggerEngine``'s persisted state, exposed for
/// the debug overlay (M13) and for testing.
public struct TriggerState: Equatable, Sendable, Codable {
    public var launchCount: Int
    public var sessionCount: Int
    public var installDate: Date?
    public var lastPromptDate: Date?
    public var dismissCount: Int
    public var customSignals: Set<String>

    public static let empty = TriggerState(
        launchCount: 0,
        sessionCount: 0,
        installDate: nil,
        lastPromptDate: nil,
        dismissCount: 0,
        customSignals: []
    )
}
