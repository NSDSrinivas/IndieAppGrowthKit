import SwiftUI
import Observation
import IndieAppGrowthKit

/// Entry point exercising every SDK feature, one row per milestone.
///
/// Each row currently shows its build status (see MILESTONES.md) rather than
/// a real action, since most features haven't landed yet. As each milestone
/// ships, its row should be wired to the real API instead of the placeholder.
struct HomeView: View {
    @State private var purchaseState = PurchaseSectionState()

    var body: some View {
        NavigationStack {
            List {
                Section("Tipping") {
                    PurchaseEngineRow(state: purchaseState)
                    NavigationLink("Bundled Tip Jar UI") {
                        TipJarView(store: IndieAppGrowthKit.tipStore) { completion in
                            print("Tip Jar completion: \(completion)")
                        }
                        .navigationTitle("Tip Jar")
                    }
                    TipHistoryRow()
                    NavigationLink("Automatic Tip Prompt") {
                        AutomaticTipPromptDemoView()
                    }
                }
                Section("Growth") {
                    ShareAppButton(appStoreID: "0000000000", message: "Check out this app!")
                    Button("Request Review (manual, real)") {
                        ReviewPrompt.request()
                    }
                    NavigationLink("Automatic Review Prompt") {
                        AutomaticReviewPromptDemoView()
                    }
                    Button("Send Feedback (mail composer, real)") {
                        FeedbackMail.openComposer(
                            to: "support@example.com",
                            subject: "Feedback",
                            body: FeedbackMail.diagnosticsBody()
                        )
                    }
                    NavigationLink("Send Feedback (bundled form)") {
                        FeedbackFormView { text in
                            print("Feedback submitted: \(text)")
                        }
                    }
                    NavigationLink("Cross-Promotion") {
                        CrossPromotionView(apps: [
                            PromotedApp(appStoreID: "1111111111", name: "Weight Tracker", tagline: "Simple daily weight logging", systemImage: "scalemass"),
                            PromotedApp(appStoreID: "2222222222", name: "Number Cruncher", tagline: "A handy calculator", systemImage: "function"),
                        ])
                        .navigationTitle("More Apps")
                    }
                    FeatureRow(title: "Simulate Milestone", milestone: "M11", status: .planned)
                    FeatureRow(title: "What's New", milestone: "M12", status: .planned)
                }
                Section("Dev Tools") {
                    NavigationLink("Theme Switcher") {
                        ThemePreviewView()
                    }
                    FeatureRow(title: "Debug Overlay", milestone: "M13", status: .planned)
                }
            }
            .navigationTitle("IndieAppGrowthKit Demo")
            .task {
                await purchaseState.start()
            }
        }
    }
}

/// M1 (Purchase Engine Core) is real and wired up here — this row loads
/// products via `IndieAppGrowthKit.tipStore` and lets you buy one, so the
/// purchase engine can be manually verified against `Demo.storekit` in
/// Xcode (see Demo/README.md) even though there's no themed Tip Jar UI yet.
private struct PurchaseEngineRow: View {
    let state: PurchaseSectionState

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Purchase Engine (real)")
                Spacer()
                Text("M1 — Ready").font(.caption).foregroundStyle(.secondary)
            }
            switch state.status {
            case .loading:
                Text("Loading products…").font(.caption).foregroundStyle(.secondary)
            case .failed(let message):
                Text("Failed to load products: \(message)").font(.caption).foregroundStyle(.red)
            case .loaded(let products):
                if products.isEmpty {
                    Text("No products loaded. Attach Demo.storekit in the Xcode scheme (see Demo/README.md).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(products, id: \.self) { identifier in
                        Button("Tip: \(identifier)") {
                            Task { await state.purchase(identifier: identifier) }
                        }
                    }
                }
                if let outcome = state.lastOutcome {
                    Text("Last outcome: \(outcome)").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// M4 (Tip History) is real and wired up here.
private struct TipHistoryRow: View {
    @State private var history: TipHistory?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Tip History (real)")
                Spacer()
                Text("M4 — Ready").font(.caption).foregroundStyle(.secondary)
            }
            if let history {
                let totalsText = history.totalsByCurrency
                    .map { "\($1) \($0)" }
                    .joined(separator: ", ")
                Text(history.hasTipped ? "You've tipped \(history.tipCount) time(s). Totals: \(totalsText)" : "No tips yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Refresh") {
                Task { history = await IndieAppGrowthKit.tipStore.tipHistory() }
            }
        }
        .task { history = await IndieAppGrowthKit.tipStore.tipHistory() }
    }
}

@MainActor
@Observable
private final class PurchaseSectionState {
    enum Status {
        case loading
        case loaded([String])
        case failed(String)
    }

    var status: Status = .loading
    var lastOutcome: String?

    func start() async {
        do {
            try await IndieAppGrowthKit.tipStore.start()
            let identifiers = await IndieAppGrowthKit.tipStore.products.map(\.id)
            status = .loaded(identifiers)
        } catch {
            status = .failed(error.localizedDescription)
        }
    }

    func purchase(identifier: String) async {
        do {
            let outcome = try await IndieAppGrowthKit.tipStore.purchase(identifier: identifier)
            lastOutcome = String(describing: outcome)
        } catch {
            lastOutcome = "error: \(error.localizedDescription)"
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
