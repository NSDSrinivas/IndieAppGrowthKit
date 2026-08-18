import SwiftUI

private struct MilestoneCelebrationModifier: ViewModifier {
    @Binding var trigger: Bool
    let signalName: String?
    let tipPromptController: AutomaticTipPromptController?
    let reviewPromptController: AutomaticReviewPromptController?

    @State private var showConfetti = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if showConfetti {
                    ConfettiView()
                }
            }
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                celebrate()
                trigger = false
            }
    }

    private func celebrate() {
        SuccessHaptic.play()
        showConfetti = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            showConfetti = false
        }
        if let signalName {
            Task {
                await tipPromptController?.recordCustomSignal(signalName)
                await reviewPromptController?.recordCustomSignal(signalName)
            }
        }
    }
}

extension View {
    /// Celebrates an arbitrary developer-defined in-app milestone or streak
    /// (not tied to tipping) with the same success feedback (haptics +
    /// confetti) a successful tip gets. Set `trigger` to `true` to fire it;
    /// it resets to `false` automatically.
    ///
    /// To bundle an optional tip or review nudge alongside the celebration,
    /// pass `signalName` plus the relevant controller(s) — the celebration
    /// reports it as a custom signal, which those controllers' conditions
    /// can already key off via `.customSignal(_:)` (see M6/M8). This keeps
    /// celebration, tipping, and reviewing as separately-configurable pieces
    /// that compose, rather than one hardcoded combined flow.
    public func milestoneCelebration(
        trigger: Binding<Bool>,
        reportingSignal signalName: String? = nil,
        tipPromptController: AutomaticTipPromptController? = nil,
        reviewPromptController: AutomaticReviewPromptController? = nil
    ) -> some View {
        modifier(MilestoneCelebrationModifier(
            trigger: trigger,
            signalName: signalName,
            tipPromptController: tipPromptController,
            reviewPromptController: reviewPromptController
        ))
    }
}
