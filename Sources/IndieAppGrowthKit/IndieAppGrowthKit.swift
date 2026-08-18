import Foundation

/// Entry point for Indie App Growth Kit.
///
/// Configure once at app launch, then use the individual feature APIs
/// (tipping, review prompts, sharing, feedback, etc.) as needed.
public enum IndieAppGrowthKit {
    private static let state = State()

    /// Configures the SDK. Call once, typically at app launch.
    public static func configure(_ configuration: Configuration) {
        state.configuration = configuration
        state.tipStore = TipStore(productIdentifiers: configuration.tipProductIdentifiers)
    }

    /// The tip purchase engine, available once ``configure(_:)`` has been called.
    public static var tipStore: TipStore {
        guard let tipStore = state.tipStore else {
            fatalError("IndieAppGrowthKit.configure(_:) must be called before accessing tipStore.")
        }
        return tipStore
    }

    /// The configuration passed to ``configure(_:)``.
    public static var configuration: Configuration {
        guard let configuration = state.configuration else {
            fatalError("IndieAppGrowthKit.configure(_:) must be called before accessing configuration.")
        }
        return configuration
    }

    private final class State: @unchecked Sendable {
        var configuration: Configuration?
        var tipStore: TipStore?
    }
}
