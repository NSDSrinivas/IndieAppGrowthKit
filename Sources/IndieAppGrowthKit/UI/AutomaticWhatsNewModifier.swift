import SwiftUI

private struct AutomaticWhatsNewModifier<CardContent: View>: ViewModifier {
    let controller: WhatsNewController
    let title: String
    let cardContent: () -> CardContent

    @State private var isPresented = false

    func body(content: Content) -> some View {
        content
            .task {
                if await controller.shouldShowWhatsNew() {
                    await controller.markShown()
                    isPresented = true
                }
            }
            .sheet(isPresented: $isPresented) {
                WhatsNewView(title: title, content: cardContent)
            }
    }
}

extension View {
    /// Automatically presents a themed "What's New" card at most once per
    /// app version, checked once when this view appears.
    public func automaticWhatsNew<CardContent: View>(
        controller: WhatsNewController,
        title: String,
        @ViewBuilder content: @escaping () -> CardContent
    ) -> some View {
        modifier(AutomaticWhatsNewModifier(controller: controller, title: title, cardContent: content))
    }
}
