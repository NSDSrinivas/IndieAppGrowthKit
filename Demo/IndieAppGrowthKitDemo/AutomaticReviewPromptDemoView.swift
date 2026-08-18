import SwiftUI
import IndieAppGrowthKit

/// M8 acceptance check: an intentionally trivial condition so the automatic
/// review prompt (with its review -> feedback pre-prompt fallback) fires the
/// moment this screen appears.
struct AutomaticReviewPromptDemoView: View {
    private let controller = AutomaticReviewPromptController(conditions: [.launchCount(atLeast: 1)])
    @State private var routedToFeedback = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Requests the automatic review prompt on appear, via the 'Enjoying the app?' pre-prompt fallback. Answering 'Not really' routes here to a feedback placeholder instead of the system review prompt.")
                .font(.caption)
                .multilineTextAlignment(.center)
            if routedToFeedback {
                Text("Routed to feedback (M9 will wire this to a real feedback flow).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Automatic Review Prompt")
        .task {
            await controller.recordLaunch()
        }
        .automaticReviewPrompt(
            controller: controller,
            prePromptTitle: "Enjoying the app?",
            prePromptMessage: "We'd love a rating if so!"
        ) {
            routedToFeedback = true
        }
    }
}

#Preview {
    AutomaticReviewPromptDemoView()
}
