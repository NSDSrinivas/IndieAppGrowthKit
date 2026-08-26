import SwiftUI

/// A lightweight bundled alternative to ``FeedbackMail`` for collecting
/// feedback in-app instead of handing off to the Mail app. The SDK makes no
/// network calls of its own — `onSubmit` is the host app's responsibility to
/// wire up to wherever feedback should actually go.
public struct FeedbackFormView: View {
    @Environment(\.tipJarTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

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
                .frame(minHeight: 140)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.primaryText)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
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
                .background(entryBackground)
                .overlay(entryBorder)
                .animation(.easeOut(duration: 0.2), value: isFocused)
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

    private var entryShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.metrics.cornerRadius + 8, style: .continuous)
    }

    // Not `.glassEffect(...)`: that API only exists in the iOS/macOS 26 SDK,
    // and this SDK is distributed as source via SPM, so any consumer
    // building with an older Xcode would fail to compile it at all — a
    // runtime `#available` check can't paper over a missing compile-time
    // symbol. `.regularMaterial` renders a comparable glass look everywhere.
    private var entryBackground: some View {
        entryShape.fill(.regularMaterial)
    }

    private var entryBorder: some View {
        entryShape
            .strokeBorder(
                isFocused ? theme.colors.accent : theme.colors.secondaryText.opacity(0.2),
                lineWidth: isFocused ? 1.5 : 1
            )
    }
}
