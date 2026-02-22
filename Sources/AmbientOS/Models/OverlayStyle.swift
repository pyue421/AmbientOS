import SwiftUI

struct OverlayStyle: Equatable {
    var tintColor: Color
    var warmth: Double
    var opacity: Double
    var vignette: Double

    static let neutral = OverlayStyle(
        tintColor: .clear,
        warmth: 0.0,
        opacity: 0.0,
        vignette: 0.0
    )
}

