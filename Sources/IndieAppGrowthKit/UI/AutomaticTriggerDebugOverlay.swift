import SwiftUI

/// Debug-only view showing the live state of every automatic-trigger
/// controller in use, with a reset button per controller so a developer can
/// verify trigger conditions without waiting out real cooldown periods.
/// Renders nothing in release builds (`#if DEBUG`), so it's safe to leave
/// wired into a shipping app's debug menu.
public struct AutomaticTriggerDebugOverlay: View {
    let tipController: AutomaticTipPromptController?
    let reviewController: AutomaticReviewPromptController?
    let whatsNewController: WhatsNewController?

    @State private var tipState: TriggerState?
    @State private var reviewState: TriggerState?
    @State private var whatsNewInfo: WhatsNewDebugInfo?

    public init(
        tipController: AutomaticTipPromptController? = nil,
        reviewController: AutomaticReviewPromptController? = nil,
        whatsNewController: WhatsNewController? = nil
    ) {
        self.tipController = tipController
        self.reviewController = reviewController
        self.whatsNewController = whatsNewController
    }

    public var body: some View {
        #if DEBUG
        List {
            if let tipController {
                Section("Tip Prompt") {
                    stateRows(tipState)
                    Button("Reset") {
                        Task {
                            await tipController.reset()
                            await refresh()
                        }
                    }
                }
            }
            if let reviewController {
                Section("Review Prompt") {
                    stateRows(reviewState)
                    Button("Reset") {
                        Task {
                            await reviewController.reset()
                            await refresh()
                        }
                    }
                }
            }
            if let whatsNewController {
                Section("What's New") {
                    Text("Last seen version: \(whatsNewInfo?.lastSeenVersion ?? "none")")
                    Text("Current version: \(whatsNewInfo?.currentVersion ?? "unknown")")
                    Button("Reset") {
                        Task {
                            await whatsNewController.reset()
                            await refresh()
                        }
                    }
                }
            }
        }
        .task { await refresh() }
        #else
        EmptyView()
        #endif
    }

    #if DEBUG
    @ViewBuilder
    private func stateRows(_ state: TriggerState?) -> some View {
        if let state {
            Text("Launch count: \(state.launchCount)")
            Text("Session count: \(state.sessionCount)")
            Text("Install date: \(state.installDate.map(String.init(describing:)) ?? "none")")
            Text("Last prompt date: \(state.lastPromptDate.map(String.init(describing:)) ?? "none")")
            Text("Dismiss count: \(state.dismissCount)")
            Text("Custom signals: \(state.customSignals.sorted().joined(separator: ", "))")
        }
    }

    private func refresh() async {
        tipState = await tipController?.debugState()
        reviewState = await reviewController?.debugState()
        whatsNewInfo = await whatsNewController?.debugInfo()
    }
    #endif
}
