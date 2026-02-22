import SwiftUI

struct CursorLayerView: View {
    @ObservedObject var model: CursorLayerModel

    var body: some View {
        GeometryReader { proxy in
            let point = convertedPoint(from: model.cursorPoint, height: proxy.size.height)

            ZStack {
                ForEach(Array(model.trailPoints.enumerated()), id: \.offset) { index, trailPoint in
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 5, height: 5)
                        .position(convertedPoint(from: trailPoint, height: proxy.size.height))
                        .opacity(Double(index + 1) / Double(max(1, model.trailPoints.count)))
                }

                cursorShape(for: model.cursorStyle)
                    .position(point)
                    .animation(.easeInOut(duration: 0.2), value: model.cursorStyle)
            }
            .onAppear { model.canvasSize = proxy.size }
            .onChange(of: proxy.size) { newSize in
                model.canvasSize = newSize
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func cursorShape(for style: CursorStyle) -> some View {
        Group {
            if style.shape == .emoji {
                Text(style.emoji)
                    .font(.system(size: style.size))
            } else {
                Circle()
                    .stroke(Color.white.opacity(0.95), lineWidth: 1.5)
                    .frame(width: style.size, height: style.size)
                    .background(Circle().fill(Color.black.opacity(0.15)))
            }
        }
    }

    private func convertedPoint(from point: CGPoint, height: CGFloat) -> CGPoint {
        CGPoint(x: point.x, y: max(0, height - point.y))
    }
}
