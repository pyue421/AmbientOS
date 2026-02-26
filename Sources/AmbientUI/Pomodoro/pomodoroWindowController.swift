import AppKit
import Combine
import SwiftUI

@MainActor
final class PomodoroWindowController {
    private var window: NSWindow?
    private let model = PomodoroModel()
    private var stateCancellable: AnyCancellable?
    private var tickCancellable: AnyCancellable?
    private var screenCancellable: AnyCancellable?
    private var isActive = false

    func start(with state: AtmosphereState) {
        buildWindowIfNeeded()
        tickCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isActive else { return }
                self.model.tick()
            }

        stateCancellable = Publishers.CombineLatest(state.$isEnabled, state.$selectedMode)
            .sink { [weak self] isEnabled, mode in
                self?.updateActivity(isEnabled: isEnabled, mode: mode)
            }

        screenCancellable = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
            }

        updateActivity(isEnabled: state.isEnabled, mode: state.selectedMode)
    }

    private func buildWindowIfNeeded() {
        guard window == nil else { return }
        let frame = targetFrame()
        let newWindow = NSWindow(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        newWindow.level = .statusBar
        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        newWindow.isOpaque = false
        newWindow.backgroundColor = .clear
        newWindow.hasShadow = false
        newWindow.ignoresMouseEvents = false
        newWindow.isMovableByWindowBackground = true

        let host = DraggablePomodoroHostingView(rootView: PomodoroView(model: model))
        host.frame = CGRect(origin: .zero, size: frame.size)
        host.autoresizingMask = [.width, .height]
        newWindow.contentView?.addSubview(host)
        newWindow.orderOut(nil)

        window = newWindow
    }

    private func updateActivity(isEnabled: Bool, mode: AmbientMode) {
        let shouldBeActive = isEnabled && mode == .focused
        isActive = shouldBeActive

        guard let window else { return }
        updateWindowFrame()

        if shouldBeActive {
            window.orderFrontRegardless()
        } else {
            window.orderOut(nil)
        }
    }

    private func updateWindowFrame() {
        guard let window else { return }
        window.setFrame(targetFrame(), display: true)
    }

    private func targetFrame() -> CGRect {
        let size = CGSize(width: 340, height: 58)
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return CGRect(origin: .zero, size: size)
        }

        let visible = screen.visibleFrame
        return CGRect(
            x: visible.midX - size.width / 2,
            y: visible.maxY - size.height - 18,
            width: size.width,
            height: size.height
        )
    }
}

private final class DraggablePomodoroHostingView: NSHostingView<PomodoroView> {
    override var mouseDownCanMoveWindow: Bool { true }
}
