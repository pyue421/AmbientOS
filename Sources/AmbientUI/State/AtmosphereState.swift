import SwiftUI

@MainActor
final class AtmosphereState: ObservableObject {
    @Published var isEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published private(set) var selectedMode: AmbientMode = .studio
    @Published var overlayStyle: OverlayStyle
    @Published var cursorStyle: CursorStyle
    @Published var customOverlayStyle: OverlayStyle
    @Published var customCursorStyle: CursorStyle
    @Published var customPlaylistURL: String = ""
    @Published private(set) var nowPlayingText: String = "Not Playing"

    init() {
        let initial = ModePresets.preset(for: .studio)
        self.overlayStyle = initial.overlay
        self.cursorStyle = initial.cursor
        self.customOverlayStyle = OverlayStyle(
            tintColor: Color(red: 0.95, green: 0.95, blue: 0.95),
            warmth: 0.0,
            opacity: 0.08,
            vignette: 0.08
        )
        self.customCursorStyle = .default
    }

    func apply(mode: AmbientMode, animated: Bool = true) {
        selectedMode = mode

        let applyChanges = {
            switch mode {
            case .custom:
                self.overlayStyle = self.customOverlayStyle
                self.cursorStyle = self.customCursorStyle
            default:
                let preset = ModePresets.preset(for: mode)
                self.overlayStyle = preset.overlay
                self.cursorStyle = preset.cursor
            }
        }

        if animated {
            withAnimation(.easeInOut(duration: 0.35), applyChanges)
        } else {
            applyChanges()
        }

        // Future extension point:
        // Trigger sound scene transitions / Focus Mode orchestration here.
    }

    func updateCustomOverlay(_ update: (inout OverlayStyle) -> Void) {
        update(&customOverlayStyle)
        if selectedMode == .custom {
            apply(mode: .custom)
        }
    }

    func updateCustomCursor(_ update: (inout CursorStyle) -> Void) {
        update(&customCursorStyle)
        if selectedMode == .custom {
            apply(mode: .custom)
        }
    }

    var activeSoundSource: SoundSource {
        guard isEnabled && soundEnabled else { return .none }
        switch selectedMode {
        case .custom:
            guard !customPlaylistURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .none
            }
            return .playlist(url: customPlaylistURL)
        default:
            return ModePresets.preset(for: selectedMode).sound
        }
    }

    func setNowPlayingText(_ value: String) {
        nowPlayingText = value
    }
}
