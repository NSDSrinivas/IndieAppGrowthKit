import SwiftUI

/// The shared sheet contents used by both automatic and on-demand entry points.
struct TipJarSheetContent: View {
    @Environment(\.tipJarTheme) private var theme
    @Binding var isPresented: Bool
    let store: TipStore
    let onCompletion: (TipJarCompletion) -> Void

    var body: some View {
        #if os(macOS)
        // AppKit sheets do not reliably display a navigation toolbar.
        VStack(spacing: 0) {
            HStack {
                Spacer()
                cancelButton
                    .keyboardShortcut(.cancelAction)
            }
            .padding(theme.metrics.padding)

            TipJarView(store: store, onCompletion: onCompletion)
        }
        .background(theme.colors.background)
        .frame(minWidth: 400, idealWidth: 480, minHeight: 360, idealHeight: 560)
        #else
        NavigationStack {
            TipJarView(store: store, onCompletion: onCompletion)
                .toolbar {
                    ToolbarItem(placement: trailingButtonPlacement) {
                        cancelButton
                    }
                }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
        #endif
    }

    private var cancelButton: some View {
        Button(theme.strings.closeButtonTitle) {
            isPresented = false
        }
    }
}

private struct TipJarSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let store: TipStore
    let onCompletion: (TipJarCompletion) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                TipJarSheetContent(isPresented: $isPresented, store: store) { completion in
                    if case .success = completion { isPresented = false }
                    onCompletion(completion)
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
