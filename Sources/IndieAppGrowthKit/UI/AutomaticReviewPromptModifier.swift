import SwiftUI

private struct AutomaticReviewPromptModifier: ViewModifier {
    let controller: AutomaticReviewPromptController
    /// If provided, asks the user whether they would like to rate the app.
    let prePromptTitle: String?
    let prePromptMessage: String?

    @State private var showingPrePrompt = false

    func body(content: Content) -> some View {
        content
            .task {
                if await controller.shouldShowPrompt() {
                    await controller.recordPromptShown()
                    if prePromptTitle != nil {
                        showingPrePrompt = true
                    } else {
                        ReviewPrompt.request()
                    }
                }
            }
            .alert(prePromptTitle ?? "", isPresented: $showingPrePrompt) {
                Button("Rate App") { ReviewPrompt.request() }
                Button("Maybe Later", role: .cancel) {
                    Task { await controller.recordDismiss() }
                }
            } message: {
                if let prePromptMessage {
                    Text(prePromptMessage)
                }
            }
    }
}

extension View {
    /// Automatically requests an App Store review when `controller`'s
    /// configured conditions are met (checked once when this view appears).
    /// Pass `prePromptTitle` to offer “Rate App” and “Maybe Later” first.
    /// Deferring only dismisses the alert; the configured cooldown still applies.
    public func automaticReviewPrompt(
        controller: AutomaticReviewPromptController,
        prePromptTitle: String? = nil,
        prePromptMessage: String? = "We hope you’re enjoying using the app. Would you like to take a moment to rate it?"
    ) -> some View {
        modifier(AutomaticReviewPromptModifier(
            controller: controller,
            prePromptTitle: prePromptTitle,
            prePromptMessage: prePromptMessage
        ))
    }
}
