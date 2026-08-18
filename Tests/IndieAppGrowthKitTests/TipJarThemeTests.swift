import XCTest
import SwiftUI
@testable import IndieAppGrowthKit

final class TipJarThemeTests: XCTestCase {
    func testDefaultThemeHasNonEmptyCopy() {
        let theme = TipJarTheme.default
        XCTAssertFalse(theme.strings.tipJarTitle.isEmpty)
        XCTAssertFalse(theme.strings.tipJarSubtitle.isEmpty)
        XCTAssertFalse(theme.strings.purchaseButtonTitle.isEmpty)
        XCTAssertFalse(theme.strings.poweredByText.isEmpty)
    }

    func testCustomThemeOverridesEveryField() {
        let custom = TipJarTheme(
            colors: .init(background: .red, surface: .orange, accent: .yellow, primaryText: .green, secondaryText: .blue),
            typography: .init(title: .largeTitle, body: .footnote, price: .caption2, caption: .caption),
            metrics: .init(cornerRadius: 0, spacing: 4, padding: 2),
            strings: .init(
                tipJarTitle: "Buy me a coffee",
                tipJarSubtitle: "Every bit helps!",
                purchaseButtonTitle: "Send",
                poweredByText: "Made with Custom Kit"
            )
        )

        XCTAssertNotEqual(custom, .default)
        XCTAssertEqual(custom.strings.tipJarTitle, "Buy me a coffee")
        XCTAssertEqual(custom.metrics.cornerRadius, 0)
    }

    func testEnvironmentDefaultsToDefaultTheme() {
        let values = EnvironmentValues()
        XCTAssertEqual(values.tipJarTheme, .default)
    }

    func testEnvironmentValuesStoresAssignedTheme() {
        let custom = TipJarTheme(
            colors: TipJarTheme.default.colors,
            typography: TipJarTheme.default.typography,
            metrics: TipJarTheme.default.metrics,
            strings: .init(
                tipJarTitle: "Custom Title",
                tipJarSubtitle: "Custom Subtitle",
                purchaseButtonTitle: "Custom Button",
                poweredByText: "Custom Powered By"
            )
        )

        var values = EnvironmentValues()
        values.tipJarTheme = custom
        XCTAssertEqual(values.tipJarTheme, custom)
        XCTAssertNotEqual(values.tipJarTheme, .default)
    }
}
