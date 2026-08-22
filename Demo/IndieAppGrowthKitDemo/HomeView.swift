import SwiftUI
import Observation
import IndieAppGrowthKit

/// Entry point exercising every SDK feature, one row per milestone.
///
/// Each row is wired to the real API for its milestone (see MILESTONES.md).
/// As new milestones land, add a row here wired to the real API rather than
/// a placeholder.
struct HomeView: View {
    @State private var purchaseState = PurchaseSectionState()
    @State private var showTipJarSheet = false
    @State private var showFeedbackFormSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("Tipping") {
                    PurchaseEngineRow(state: purchaseState)
                    // On-demand trigger (e.g. a "Tip the Developer" settings
                    // row): presented as a sheet to match how
                    // `.automaticTipPrompt(_:)` shows the same view, so it
                    // looks and behaves identically whether triggered
                    // automatically or manually.
                    Button("Bundled Tip Jar UI") {
                        showTipJarSheet = true
                    }
                    TipHistoryRow()
                    NavigationLink("Automatic Tip Prompt") {
                        AutomaticTipPromptDemoView()
                    }
                }
                Section("Growth") {
                    ShareAppButton(message: "Check out this app!")
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
                    // On-demand trigger: sheet, since `FeedbackFormView`
                    // dismisses itself on submit — a modal compose form is
                    // the idiomatic presentation for that (like Mail compose).
                    Button("Send Feedback (bundled form)") {
                        showFeedbackFormSheet = true
                    }
                    // On-demand trigger: pushed, since this is a static,
                    // non-modal list of other apps — the common "More Apps"
                    // settings-row pattern, with no dismiss action of its own.
                    NavigationLink("Cross-Promotion") {
                        CrossPromotionView(apps: [
                            PromotedApp(appStoreID: "1111111111", name: "Weight Tracker", tagline: "Simple daily weight logging", systemImage: "scalemass"),
                            PromotedApp(appStoreID: "2222222222", name: "Number Cruncher", tagline: "A handy calculator", systemImage: "function"),
                        ])
                        .navigationTitle("More Apps")
                    }
                    MilestoneCelebrationRow()
                    NavigationLink("What's New") {
                        WhatsNewDemoView()
                    }
                }
                Section("Dev Tools") {
                    NavigationLink("Theme Switcher") {
                        ThemePreviewView()
                    }
                    NavigationLink("Debug Overlay") {
                        AutomaticTriggerDebugOverlay(
                            tipController: DemoControllers.tipPrompt,
                            reviewController: DemoControllers.reviewPrompt,
                            whatsNewController: DemoControllers.whatsNew
                        )
                        .navigationTitle("Debug Overlay")
                    }
                }
            }
            .navigationTitle("IndieAppGrowthKit Demo")
            .task {
                await purchaseState.start()
            }
            .tipJarSheet(isPresented: $showTipJarSheet, store: IndieAppGrowthKit.tipStore) { completion in
                print("Tip Jar completion: \(completion)")
            }
            .feedbackFormSheet(isPresented: $showFeedbackFormSheet) { text in
                print("Feedback submitted: \(text)")
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

/// M11 (Milestone Celebration) is real and wired up here.
private struct MilestoneCelebrationRow: View {
    @State private var celebrating = false

    var body: some View {
        Button("Simulate Milestone (confetti + haptic, real)") {
            celebrating = true
        }
        .milestoneCelebration(trigger: $celebrating)
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
