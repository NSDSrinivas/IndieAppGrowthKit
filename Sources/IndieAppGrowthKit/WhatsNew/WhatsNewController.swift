@preconcurrency import Foundation

/// Tracks whether the "What's New" card has been shown for the app's
/// current version, so it fires at most once per version. Deliberately a
/// standalone controller rather than reusing ``AutomaticTriggerEngine`` — it
/// tracks a version string, not counts/dates/signals, so the generic
/// engine's state shape doesn't fit.
public actor WhatsNewController {
    private let userDefaults: UserDefaults
    private let currentVersionProvider: @Sendable () -> String?
    private static let storageKey = "com.indieappgrowthkit.whatsnew.lastSeenVersion"

    /// - Parameter currentVersion: Defaults to the app's `CFBundleShortVersionString`.
    ///   Injectable for testing.
    public init(
        userDefaults: UserDefaults = .standard,
        currentVersion: @escaping @Sendable () -> String? = {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        }
    ) {
        self.userDefaults = userDefaults
        self.currentVersionProvider = currentVersion
    }

    /// Whether the What's New card should be shown: the current version is
    /// known and differs from the last version it was shown for.
    public func shouldShowWhatsNew() -> Bool {
        guard let current = currentVersionProvider() else { return false }
        return userDefaults.string(forKey: Self.storageKey) != current
    }

    /// Call once the card has actually been shown to the user.
    public func markShown() {
        guard let current = currentVersionProvider() else { return }
        userDefaults.set(current, forKey: Self.storageKey)
    }

    /// Clears persisted state. Debug/testing only.
    public func reset() {
        userDefaults.removeObject(forKey: Self.storageKey)
    }

    /// Live state, for the debug overlay (M13).
    public func debugInfo() -> WhatsNewDebugInfo {
        WhatsNewDebugInfo(
            lastSeenVersion: userDefaults.string(forKey: Self.storageKey),
            currentVersion: currentVersionProvider()
        )
    }
}

public struct WhatsNewDebugInfo: Equatable, Sendable {
    public let lastSeenVersion: String?
    public let currentVersion: String?
}
