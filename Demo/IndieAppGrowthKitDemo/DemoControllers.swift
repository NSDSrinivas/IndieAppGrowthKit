import IndieAppGrowthKit

/// Shared controller instances so the debug overlay reflects the same state
/// the feature demo screens are actually mutating (each screen previously
/// created its own private controller, which the overlay couldn't see).
enum DemoControllers {
    static let tipPrompt = AutomaticTipPromptController(
        conditions: [.launchCount(atLeast: 1)],
        tipStore: IndieAppGrowthKit.tipStore
    )
    static let reviewPrompt = AutomaticReviewPromptController(conditions: [.launchCount(atLeast: 1)])
    static let whatsNew = WhatsNewController(currentVersion: { "1.0" })
}
