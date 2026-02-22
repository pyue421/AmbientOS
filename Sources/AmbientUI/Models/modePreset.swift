import SwiftUI

struct ModePreset {
    let overlay: OverlayStyle
    let cursor: CursorStyle
    let sound: SoundSource
}

enum ModePresets {
    static func preset(for mode: AmbientMode) -> ModePreset {
        switch mode {
        case .studio:
            return ModePreset(
                overlay: OverlayStyle(
                    tintColor: Color(red: 0.98, green: 0.90, blue: 0.80),
                    warmth: 0.45,
                    opacity: 0.12,
                    vignette: 0.10
                ),
                cursor: CursorStyle(
                    shape: .minimal,
                    emoji: "✍️",
                    trailingEnabled: true,
                    size: 18
                ),
                sound: .playlist(url: "https://open.spotify.com/playlist/5m7f5oUSJ3iT0Sfnw8Sw9k?si=c6df4c49b7764639")
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
                ),
                sound: .playlist(url: "https://open.spotify.com/playlist/37i9dQZF1DX4PP3DA4J0N8")
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
                ),
                sound: .none
            )
        case .custom:
            return ModePreset(overlay: .neutral, cursor: .default, sound: .none)
        }
    }
}


#Preview {
    Text("ModePreset Preview")
}
