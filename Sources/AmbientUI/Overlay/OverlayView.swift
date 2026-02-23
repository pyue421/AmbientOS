import SwiftUI

struct OverlayView: View {
    let screenFrame: CGRect
    @EnvironmentObject private var state: AtmosphereState

    var body: some View {
        let style = state.isEnabled ? state.overlayStyle : .neutral
        ZStack {
            if state.selectedMode == .studio && state.isEnabled {
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.93, blue: 0.84).opacity(0.08),
                        Color(red: 0.93, green: 0.88, blue: 1.0).opacity(0.06),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            style.tintColor
                .opacity(style.opacity)

            Rectangle()
                .fill(warmthGradient(amount: style.warmth))
                .opacity(max(0.0, abs(style.warmth) * 0.35))
                .blendMode(style.warmth >= 0 ? .screen : .multiply)

            vignetteOverlay(strength: style.vignette)

            if shouldApplyFocusMask {
                focusMaskLayer
                    .mask(
                        FocusCutoutMask(holeRect: localFocusHoleRect)
                            .fill(Color.white, style: FillStyle(eoFill: true))
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.35), value: style)
        .animation(.easeInOut(duration: 0.2), value: state.focusedWindowFrame)
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

    private var shouldApplyFocusMask: Bool {
        state.isEnabled && state.selectedMode == .focused
    }

    private var localFocusHoleRect: CGRect? {
        guard let globalTarget = state.focusedWindowFrame else { return nil }
        let intersection = screenFrame.intersection(globalTarget)
        guard !intersection.isNull, !intersection.isEmpty else { return nil }

        let localX = intersection.minX - screenFrame.minX
        let localY = screenFrame.maxY - intersection.maxY
        return CGRect(x: localX, y: localY, width: intersection.width, height: intersection.height)
    }

    private var focusMaskLayer: some View {
        ZStack {
            Color.white.opacity(0.20).blendMode(.saturation)
            Color.black.opacity(0.20)
        }
    }
}

private struct FocusCutoutMask: Shape {
    let holeRect: CGRect?

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        if let holeRect {
            path.addRoundedRect(
                in: holeRect.insetBy(dx: -6, dy: -6),
                cornerSize: CGSize(width: 10, height: 10)
            )
        }
        return path
    }
}
