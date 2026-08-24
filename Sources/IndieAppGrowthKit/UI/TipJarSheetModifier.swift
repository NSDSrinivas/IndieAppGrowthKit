import SwiftUI

private struct TipJarSheetModifier: ViewModifier {
    @Environment(\.tipJarTheme) private var theme
    @Binding var isPresented: Bool
    let store: TipStore
    let onCompletion: (TipJarCompletion) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    TipJarView(store: store) { completion in
                        if case .success = completion { isPresented = false }
                        onCompletion(completion)
                    }
                    .toolbar {
                        ToolbarItem(placement: trailingButtonPlacement) {
                            Button(theme.strings.closeButtonTitle) {
                                isPresented = false
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    /// Presents the bundled Tip Jar in a sheet, for on-demand triggers (a
    /// "Tip the Developer" settings row, a standalone button, etc.) rather
    /// than the SDK's own automatic condition-based prompt. Matches the
    /// presentation style `.automaticTipPrompt(_:)` uses, so the Tip Jar
    /// looks and behaves the same whether shown automatically or manually.
    public func tipJarSheet(
        isPresented: Binding<Bool>,
        store: TipStore,
        onCompletion: @escaping (TipJarCompletion) -> Void = { _ in }
    ) -> some View {
        modifier(TipJarSheetModifier(isPresented: isPresented, store: store, onCompletion: onCompletion))
    }
}
