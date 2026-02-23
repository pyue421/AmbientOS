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
                    size: 18,
                    tint: .white
                ),
                sound: .playlist(
                    SoundPlaylist(
                        id: "studio-default",
                        title: "Studio Ambience",
                        tracks: [
                            SoundTrack(
                                title: "Studio Glow",
                                source: .bundled(name: "studio_glow", ext: "wav", subdirectory: "Audio/studio")
                            ),
                            SoundTrack(
                                title: "Studio Night",
                                source: .bundled(name: "studio_night", ext: "wav", subdirectory: "Audio/studio")
                            ),
                        ]
                    )
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
                    size: 14,
                    tint: .white
                ),
                sound: .playlist(
                    SoundPlaylist(
                        id: "minimal-default",
                        title: "Minimal Ambience",
                        tracks: [
                            SoundTrack(
                                title: "Minimal Breeze",
                                source: .bundled(name: "minimal_breeze", ext: "wav", subdirectory: "Audio/minimal")
                            ),
                        ]
                    )
                )
            )
        case .focused:
            return ModePreset(
                overlay: OverlayStyle(
                    tintColor: Color(red: 0.82, green: 0.90, blue: 1.0),
                    warmth: -0.2,
                    opacity: 0,
                    vignette: 0.25
                ),
                cursor: CursorStyle(
                    shape: .minimal,
                    emoji: "",
                    trailingEnabled: false,
                    size: 18,
                    tint: .white
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

//pkill AmbientOS cd app swift run