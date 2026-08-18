import SwiftUI
import IndieAppGrowthKit

/// Entry point exercising every SDK feature, one row per milestone.
///
/// Each row currently shows its build status (see MILESTONES.md) rather than
/// a real action, since most features haven't landed yet. As each milestone
/// ships, its row should be wired to the real API instead of the placeholder.
struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Tipping") {
                    FeatureRow(title: "Show Tip Jar", milestone: "M3", status: .planned)
                    FeatureRow(title: "Tip History", milestone: "M4", status: .planned)
                    FeatureRow(title: "Automatic Tip Prompt", milestone: "M6", status: .planned)
                }
                Section("Growth") {
                    FeatureRow(title: "Share App", milestone: "M7", status: .planned)
                    FeatureRow(title: "Request Review", milestone: "M8", status: .planned)
                    FeatureRow(title: "Send Feedback", milestone: "M9", status: .planned)
                    FeatureRow(title: "Cross-Promotion", milestone: "M10", status: .planned)
                    FeatureRow(title: "Simulate Milestone", milestone: "M11", status: .planned)
                    FeatureRow(title: "What's New", milestone: "M12", status: .planned)
                }
                Section("Dev Tools") {
                    FeatureRow(title: "Theme Switcher", milestone: "M2", status: .planned)
                    FeatureRow(title: "Debug Overlay", milestone: "M13", status: .planned)
                }
            }
            .navigationTitle("IndieAppGrowthKit Demo")
        }
    }
}

private enum FeatureStatus {
    case planned, implemented

    var label: String {
        switch self {
        case .planned: "Not yet implemented"
        case .implemented: "Ready"
        }
    }
}

private struct FeatureRow: View {
    let title: String
    let milestone: String
    let status: FeatureStatus

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text("\(milestone) — \(status.label)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
