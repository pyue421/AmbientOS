import AppKit 
import SwiftUI

@MainActor
final class CursorLayerModel: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var cursorStyle: CursorStyle = .default
    @Published var cursorPoint: CGPoint = .zero
    @Published var trailPoints: [CGPoint] = []
    @Published var canvasSize: CGSize = .zero //stores the current cursor position

    func set(point: CGPoint) {
        cursorPoint = point
        guard isEnabled else {
            trailPoints.removeAll(keepingCapacity: true)
            return
        }
        guard cursorStyle.trailingEnabled else {
            trailPoints.removeAll(keepingCapacity: true) 
            return
        }

        trailPoints.append(point)
        if trailPoints.count > 10 {
            trailPoints.removeFirst(trailPoints.count - 10)
        }
    }
}
