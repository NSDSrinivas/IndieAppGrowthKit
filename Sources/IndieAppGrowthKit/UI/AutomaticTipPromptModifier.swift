import SwiftUI

private struct AutomaticTipPromptModifier: ViewModifier {
    @Environment(\.tipJarTheme) private var theme
    let controller: AutomaticTipPromptController
    let tipStore: TipStore
    let onCompletion: (TipJarCompletion) -> Void

    @State private var isAlertPresented = false
    @State private var isSheetPresented = false
    @State private var completedSuccessfully = false

    func body(content: Content) -> some View {
        content
            .task {
                if await controller.shouldShowPrompt() {
                    await controller.recordPromptShown()
                    isAlertPresented = true
                }
            }
            .alert(theme.strings.automaticTipPromptTitle, isPresented: $isAlertPresented) {
                Button(theme.strings.automaticTipPromptSupportButtonTitle) {
                    isSheetPresented = true
                }
                Button(theme.strings.automaticTipPromptDeclineButtonTitle, role: .cancel) {
                    Task { await controller.recordDismiss() }
                }
            } message: {
                Text(theme.strings.automaticTipPromptMessage)
            }
            .sheet(isPresented: $isSheetPresented, onDismiss: {
                guard !completedSuccessfully else { return }
                Task { await controller.recordDismiss() }
            }) {
                TipJarSheetContent(isPresented: $isSheetPresented, store: tipStore) { completion in
                    if case .success = completion {
                        completedSuccessfully = true
                        isSheetPresented = false
                    }
                    onCompletion(completion)
                }
            }
    }
}

extension View {
    /// Offers the bundled Tip Jar in a themed confirmation alert when
    /// `controller`'s configured conditions are met (checked once when this
    /// view appears). Choosing to support opens the Tip Jar sheet.
    public func automaticTipPrompt(
        controller: AutomaticTipPromptController,
        tipStore: TipStore,
        onCompletion: @escaping (TipJarCompletion) -> Void = { _ in }
    ) -> some View {
        modifier(AutomaticTipPromptModifier(controller: controller, tipStore: tipStore, onCompletion: onCompletion))
    }
}
