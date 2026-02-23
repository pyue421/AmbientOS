import Foundation
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
    @Published var isCustomCursorEnabled: Bool = false
    @Published var focusedCursorTint: CursorTint = .white
    @Published var customPlaylistURL: String = ""
    @Published var selectedFocusWindowID: Int?
    @Published private(set) var availableFocusWindows: [FocusTargetWindow] = []
    @Published private(set) var focusedWindowFrame: CGRect?

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

        if mode == .focused, selectedFocusWindowID == nil {
            selectedFocusWindowID = availableFocusWindows.first?.id
        }
        if mode != .focused {
            focusedWindowFrame = nil
        } else {
            cursorStyle.tint = focusedCursorTint
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

    func updateFocusedCursorTint(_ tint: CursorTint) {
        focusedCursorTint = tint
        if selectedMode == .focused {
            cursorStyle.tint = tint
        }
    }

    var activeSoundSource: SoundSource {
        guard isEnabled && soundEnabled else { return .none }
        switch selectedMode {
        case .custom:
            return .none
        default:
            return ModePresets.preset(for: selectedMode).sound
        }
    }

    func setAvailableFocusWindows(_ windows: [FocusTargetWindow]) {
        availableFocusWindows = windows

        if let current = selectedFocusWindowID,
           !windows.contains(where: { $0.id == current }) {
            selectedFocusWindowID = nil
            focusedWindowFrame = nil
        }

        if selectedMode == .focused, selectedFocusWindowID == nil {
            selectedFocusWindowID = windows.first?.id
        }
    }

    func setFocusedWindowFrame(_ frame: CGRect?) {
        focusedWindowFrame = frame
    }

}
