import SwiftUI

struct ModePreset {
    let overlay: OverlayStyle
    let cursor: CursorStyle
}

enum ModePresets {
    static func preset(for mode: AmbientMode) -> ModePreset {
        switch mode {
        case .studio:
            return ModePreset(
                overlay: OverlayStyle(
                    tintColor: Color(red: 0.98, green: 0.90, blue: 0.80),
                    warmth: 0.45,
                    opacity: 0.16,
                    vignette: 0.10
                ),
                cursor: CursorStyle(
                    shape: .minimal,
                    emoji: "✍️",
                    trailingEnabled: true,
                    size: 18
                )
            )
        case .minimal:
            return ModePreset(
                overlay: OverlayStyle(
                    tintColor: Color.white,
                    warmth: 0.10,
                    opacity: 0.05,
                    vignette: 0.02
                ),
                cursor: CursorStyle(
                    shape: .minimal,
                    emoji: "•",
                    trailingEnabled: false,
                    size: 14
                )
            )
        case .focused:
            return ModePreset(
                overlay: OverlayStyle(
                    tintColor: Color(red: 0.82, green: 0.90, blue: 1.0),
                    warmth: -0.25,
                    opacity: 0.18,
                    vignette: 0.25
                ),
                cursor: CursorStyle(
                    shape: .emoji,
                    emoji: "🎯",
                    trailingEnabled: true,
                    size: 24
                )
            )
        case .custom:
            return ModePreset(overlay: .neutral, cursor: .default)
        }
    }
}


#Preview {
    Text("ModePreset Preview")
}

