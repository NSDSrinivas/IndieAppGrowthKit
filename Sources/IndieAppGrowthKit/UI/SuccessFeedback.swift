import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Fires the platform's success haptic, if one is available. A no-op on
/// platforms without haptics (e.g. macOS).
enum SuccessHaptic {
    static func play() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}

/// A lightweight, dependency-free confetti burst shown over a successful tip.
/// Overridable/replaceable per REQUIREMENTS.md by simply not using this view
/// and supplying a custom `onCompletion` handler instead.
struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let color: Color
        let xOffset: CGFloat
        let delay: Double
        let rotation: Double
    }

    @State private var animate = false

    private let pieces: [Piece] = (0..<24).map { index in
        Piece(
            color: [.red, .orange, .yellow, .green, .blue, .purple].randomElement()!,
            xOffset: CGFloat.random(in: -150...150),
            delay: Double(index) * 0.01,
            rotation: Double.random(in: 0...360)
        )
    }

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: 8, height: 14)
                    .rotationEffect(.degrees(animate ? piece.rotation : 0))
                    .offset(x: piece.xOffset, y: animate ? 300 : -20)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeIn(duration: 1.2).delay(piece.delay), value: animate)
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
