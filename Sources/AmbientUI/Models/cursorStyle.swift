import Foundation

enum CursorShape: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case emoji = "Emoji"

    var id: String { rawValue }
}

struct CursorStyle: Equatable {
    var shape: CursorShape
    var emoji: String
    var trailingEnabled: Bool
    var size: Double

    static let `default` = CursorStyle(
        shape: .minimal,
        emoji: "✨",
        trailingEnabled: false,
        size: 18
    )
}

