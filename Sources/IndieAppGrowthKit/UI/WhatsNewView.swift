import SwiftUI

/// Bundled "What's New" card. Content (title + highlights) is entirely
/// developer-supplied per version via the view builder, since it's
/// inherently version-specific rather than static themeable copy; layout
/// chrome (colors, fonts, spacing, dismiss button) still comes from the theme.
public struct WhatsNewView<Content: View>: View {
    @Environment(\.tipJarTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    private let title: String
    private let dismissButtonTitle: String
    private let content: () -> Content

    public init(
        title: String,
        dismissButtonTitle: String = "Got it",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.dismissButtonTitle = dismissButtonTitle
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing) {
            Text(title)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.primaryText)
                .accessibilityAddTraits(.isHeader)

            content()

            Button(dismissButtonTitle) { dismiss() }
                .tint(theme.colors.accent)
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.background)
    }
}
