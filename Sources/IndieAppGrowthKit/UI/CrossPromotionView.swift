import SwiftUI

/// Bundled "check out my other apps" list. Fully themed via `\.tipJarTheme`;
/// tapping an entry opens its App Store listing in the system browser.
public struct CrossPromotionView: View {
    @Environment(\.tipJarTheme) private var theme
    @Environment(\.openURL) private var openURL
    private let apps: [PromotedApp]
    private let onTap: ((PromotedApp) -> Void)?

    public init(apps: [PromotedApp], onTap: ((PromotedApp) -> Void)? = nil) {
        self.apps = apps
        self.onTap = onTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing) {
            ForEach(apps) { app in
                Button {
                    onTap?(app)
                    openURL(app.appStoreURL)
                } label: {
                    HStack(spacing: theme.metrics.spacing) {
                        Image(systemName: app.systemImage)
                            .font(theme.typography.title)
                            .foregroundStyle(theme.colors.accent)
                        VStack(alignment: .leading) {
                            Text(app.name)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.primaryText)
                            Text(app.tagline)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.secondaryText)
                        }
                        Spacer()
                    }
                    .padding(theme.metrics.padding)
                    .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.metrics.cornerRadius))
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text(app.name))
                .accessibilityValue(Text(app.tagline))
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.background)
    }
}
