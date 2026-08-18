import SwiftUI

private struct AutomaticReviewPromptModifier: ViewModifier {
    let controller: AutomaticReviewPromptController
    /// If non-nil, a lightweight "Enjoying the app?" pre-prompt is shown
    /// first; a negative response routes to `onNegativeResponse` (typically
    /// the Feedback hook, M9) instead of the system review prompt, so
    /// unhappy users are funneled to private feedback rather than a public
    /// bad review.
    let prePromptTitle: String?
    let prePromptMessage: String?
    let onNegativeResponse: (() -> Void)?

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
                Button("Yes") { ReviewPrompt.request() }
                Button("Not really") {
                    Task { await controller.recordDismiss() }
                    onNegativeResponse?()
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
    /// Pass `prePromptTitle` to ask "Enjoying the app?" first and route
    /// negative responses to `onNegativeResponse` instead of the system prompt.
    public func automaticReviewPrompt(
        controller: AutomaticReviewPromptController,
        prePromptTitle: String? = nil,
        prePromptMessage: String? = nil,
        onNegativeResponse: (() -> Void)? = nil
    ) -> some View {
        modifier(AutomaticReviewPromptModifier(
            controller: controller,
            prePromptTitle: prePromptTitle,
            prePromptMessage: prePromptMessage,
            onNegativeResponse: onNegativeResponse
        ))
    }
}
