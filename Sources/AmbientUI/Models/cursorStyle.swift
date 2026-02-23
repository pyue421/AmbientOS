import Foundation
import SwiftUI

enum CursorShape: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case emoji = "Emoji"

    var id: String { rawValue }
}

struct CursorTint: Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    var color: Color {
        Color(red: red, green: green, blue: blue).opacity(alpha)
    }

    static let white = CursorTint(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95)
}

struct CursorStyle: Equatable {
    var shape: CursorShape
    var emoji: String
    var trailingEnabled: Bool
    var size: Double
    var tint: CursorTint

    static let `default` = CursorStyle(
        shape: .minimal,
        emoji: "✨",
        trailingEnabled: false,
        size: 18,
        tint: .white
    )
}
