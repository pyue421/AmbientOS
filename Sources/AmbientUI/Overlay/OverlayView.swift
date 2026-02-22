import SwiftUI

struct OverlayView: View {
    @EnvironmentObject private var state: AtmosphereState

    var body: some View {
        let style = state.isEnabled ? state.overlayStyle : .neutral
        ZStack {
            style.tintColor
                .opacity(style.opacity)

            Rectangle()
                .fill(warmthGradient(amount: style.warmth))
                .opacity(max(0.0, abs(style.warmth) * 0.35))
                .blendMode(style.warmth >= 0 ? .screen : .multiply)

            vignetteOverlay(strength: style.vignette)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.35), value: style)
    }

    private func warmthGradient(amount: Double) -> RadialGradient {
        if amount >= 0 {
            return RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.78, blue: 0.45).opacity(0.25),
                    .clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 900
            )
        }

        return RadialGradient(
            colors: [
                Color(red: 0.62, green: 0.83, blue: 1.0).opacity(0.22),
                .clear,
            ],
            center: .center,
            startRadius: 0,
            endRadius: 900
        )
    }

    private func vignetteOverlay(strength: Double) -> some View {
        RadialGradient(
            colors: [
                .clear,
                .clear,
                Color.black.opacity(max(0.0, min(1.0, strength))),
            ],
            center: .center,
            startRadius: 200,
            endRadius: 1400
        )
        .blendMode(.multiply)
    }
}
