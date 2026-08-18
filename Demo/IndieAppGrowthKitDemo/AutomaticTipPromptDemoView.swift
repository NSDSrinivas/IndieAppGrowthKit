import SwiftUI
import IndieAppGrowthKit

/// M6 acceptance check: an intentionally trivial condition (`launchCount(atLeast: 1)`)
/// so the automatic prompt fires the moment this screen appears, without
/// waiting on real launch counts across app restarts.
struct AutomaticTipPromptDemoView: View {
    private let controller = AutomaticTipPromptController(
        conditions: [.launchCount(atLeast: 1)],
        tipStore: IndieAppGrowthKit.tipStore
    )
    @State private var lastCompletion: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("This screen requests the automatic Tip Jar prompt on appear (condition: launch count ≥ 1, always true here).")
                .font(.caption)
                .multilineTextAlignment(.center)
            if let lastCompletion {
                Text("Last completion: \(lastCompletion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Automatic Tip Prompt")
        .task {
            await controller.recordLaunch()
        }
        .automaticTipPrompt(controller: controller, tipStore: IndieAppGrowthKit.tipStore) { completion in
            lastCompletion = String(describing: completion)
        }
    }
}

#Preview {
    AutomaticTipPromptDemoView()
}
