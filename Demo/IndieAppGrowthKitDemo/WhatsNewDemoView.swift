import SwiftUI
import IndieAppGrowthKit

/// M12 acceptance check. `Bundle.main` has no `CFBundleShortVersionString`
/// when running as a bare `swift run` executable (no Info.plist), so this
/// screen injects a fixed version string to make the once-per-version
/// behavior demonstrable: it shows the first time, then never again for
/// version "1.0" until you tap "Reset" (simulating a version bump).
struct WhatsNewDemoView: View {
    private let controller = WhatsNewController(currentVersion: { "1.0" })

    var body: some View {
        VStack(spacing: 16) {
            Text("Shows the What's New card once for version 1.0. Navigate away and back — it won't show again until reset.")
                .font(.caption)
                .multilineTextAlignment(.center)
            Button("Reset (simulate version bump)") {
                Task { await controller.reset() }
            }
        }
        .padding()
        .navigationTitle("What's New")
        .automaticWhatsNew(controller: controller, title: "What's New in 1.0") {
            VStack(alignment: .leading, spacing: 8) {
                Label("Tip jars with preset amounts", systemImage: "heart.fill")
                Label("Automatic review prompts", systemImage: "star.fill")
                Label("Cross-promotion for your other apps", systemImage: "square.grid.2x2")
            }
        }
    }
}

#Preview {
    WhatsNewDemoView()
}
