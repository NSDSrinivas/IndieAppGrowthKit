import SwiftUI

private struct AutomaticTipPromptModifier: ViewModifier {
    let controller: AutomaticTipPromptController
    let tipStore: TipStore
    let onCompletion: (TipJarCompletion) -> Void

    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .task {
                if await controller.shouldShowPrompt() {
                    await controller.recordPromptShown()
                    isPresented = true
                }
            }
            .sheet(isPresented: $isPresented, onDismiss: {
                Task { await controller.recordDismiss() }
            }) {
                TipJarView(store: tipStore) { completion in
                    if case .success = completion {
                        isPresented = false
                    }
                    onCompletion(completion)
                }
            }
    }
}

extension View {
    /// Automatically presents the bundled Tip Jar when `controller`'s
    /// configured conditions are met (checked once when this view appears).
    public func automaticTipPrompt(
        controller: AutomaticTipPromptController,
        tipStore: TipStore,
        onCompletion: @escaping (TipJarCompletion) -> Void = { _ in }
    ) -> some View {
        modifier(AutomaticTipPromptModifier(controller: controller, tipStore: tipStore, onCompletion: onCompletion))
    }
}
