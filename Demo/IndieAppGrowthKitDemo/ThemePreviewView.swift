import SwiftUI
import IndieAppGrowthKit

/// M2 acceptance check: proves a throwaway view can be fully re-themed
/// (colors, fonts, all copy) via `.tipJarTheme(_:)`, with zero default
/// styling left showing through when a custom theme is applied.
struct ThemePreviewView: View {
    @State private var useCustomTheme = false

    private let wildTheme = TipJarTheme(
        colors: .init(
            background: .black,
            surface: .purple.opacity(0.3),
            accent: .yellow,
            primaryText: .yellow,
            secondaryText: .orange
        ),
        typography: .init(
            title: .system(.largeTitle, design: .serif).italic(),
            body: .system(.body, design: .monospaced),
            price: .system(.title, design: .rounded).bold(),
            caption: .system(.caption2, design: .monospaced)
        ),
        metrics: .init(cornerRadius: 24, spacing: 20, padding: 24),
        strings: .init(
            tipJarTitle: "☕️ Fuel the Robot",
            tipJarSubtitle: "Every credit keeps the servers humming.",
            purchaseButtonTitle: "Zap!",
            poweredByText: "⚡ via Indie App Growth Kit"
        )
    )

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Use custom theme", isOn: $useCustomTheme)
            ThrowawayThemedPreview()
                .tipJarTheme(useCustomTheme ? wildTheme : .default)
        }
        .padding()
        .navigationTitle("Theme Switcher")
    }
}

/// A minimal stand-in for a real bundled view (the Tip Jar view itself lands
/// in M3) that reads every themeable property, to prove the theming system
/// leaves nothing hardcoded.
private struct ThrowawayThemedPreview: View {
    @Environment(\.tipJarTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing) {
            Text(theme.strings.tipJarTitle)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.primaryText)
            Text(theme.strings.tipJarSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.secondaryText)
            Text("$4.99")
                .font(theme.typography.price)
                .foregroundStyle(theme.colors.accent)
            Button(theme.strings.purchaseButtonTitle) {}
                .tint(theme.colors.accent)
            Text(theme.strings.poweredByText)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondaryText)
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.metrics.cornerRadius))
        .background(theme.colors.background)
    }
}

#Preview {
    ThemePreviewView()
}
