import SwiftUI
import IndieAppGrowthKit

/// M8 acceptance check: an intentionally trivial condition so the automatic
/// review pre-prompt fires
/// the moment this screen appears.
struct AutomaticReviewPromptDemoView: View {
    private let controller = DemoControllers.reviewPrompt

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Rate App to request the system review dialog, or Maybe Later to dismiss the alert.")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Automatic Review Prompt")
        .task {
            await controller.recordLaunch()
        }
        .automaticReviewPrompt(
            controller: controller,
            prePromptTitle: "Enjoying the app?",
            prePromptMessage: "We hope you’re enjoying using IndieAppGrowthKit Demo. Would you like to take a moment to rate it?"
        )
    }
}

#Preview {
    AutomaticReviewPromptDemoView()
}
