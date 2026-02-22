import Foundation

@MainActor
final class AtmosphereRuntime: ObservableObject {
    private let overlayController = OverlayWindowController()
    private let cursorController = CursorWindowController()
    private let soundController = SoundController()
    private var didStart = false

    func start(with state: AtmosphereState) {
        guard !didStart else { return }
        didStart = true

        overlayController.start(with: state)
        cursorController.start(with: state)
        soundController.start(with: state)
    }
}
