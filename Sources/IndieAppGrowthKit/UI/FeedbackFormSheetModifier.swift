import SwiftUI

private struct FeedbackFormSheetModifier: ViewModifier {
    @Environment(\.tipJarTheme) private var theme
    @Binding var isPresented: Bool
    let onSubmit: (String) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    FeedbackFormView(onSubmit: onSubmit)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(theme.strings.closeButtonTitle) { isPresented = false }
                            }
                        }
                }
            }
    }
}

extension View {
    /// Presents the bundled Feedback form in a sheet, for on-demand triggers
    /// (a "Send Feedback" settings row, a standalone button, etc.). Adds a
    /// close button, since ``FeedbackFormView`` only dismisses itself on
    /// submit and otherwise relies on the presenting context to let the user
    /// back out.
    public func feedbackFormSheet(
        isPresented: Binding<Bool>,
        onSubmit: @escaping (String) -> Void
    ) -> some View {
        modifier(FeedbackFormSheetModifier(isPresented: isPresented, onSubmit: onSubmit))
    }
}
