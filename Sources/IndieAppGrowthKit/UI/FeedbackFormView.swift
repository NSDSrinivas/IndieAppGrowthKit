import SwiftUI

/// A lightweight bundled alternative to ``FeedbackMail`` for collecting
/// feedback in-app instead of handing off to the Mail app. The SDK makes no
/// network calls of its own — `onSubmit` is the host app's responsibility to
/// wire up to wherever feedback should actually go.
public struct FeedbackFormView: View {
    @Environment(\.tipJarTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    private let onSubmit: (String) -> Void

    public init(onSubmit: @escaping (String) -> Void) {
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing) {
            Text(theme.strings.feedbackFormTitle)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.primaryText)
                .accessibilityAddTraits(.isHeader)

            TextEditor(text: $text)
                .frame(minHeight: 120)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.primaryText)
                .accessibilityLabel(Text(theme.strings.feedbackFormTitle))
                .accessibilityHint(Text(theme.strings.feedbackFormPlaceholder))
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(theme.strings.feedbackFormPlaceholder)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.secondaryText)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                .padding(theme.metrics.padding / 2)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.metrics.cornerRadius))
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.background)
        .toolbar {
            ToolbarItem(placement: trailingButtonPlacement) {
                Button(theme.strings.feedbackFormSubmitButtonTitle) {
                    onSubmit(text)
                    dismiss()
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .tint(theme.colors.accent)
            }
        }
    }
}
