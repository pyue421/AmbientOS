import AppKit
import Combine
import SwiftUI

@MainActor
final class OverlayWindowController {
    private var windows: [OverlayWindow] = []
    private var cancellables: Set<AnyCancellable> = []

    func start(with state: AtmosphereState) {
        rebuildWindows(state: state)

        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.rebuildWindows(state: state)
            }
            .store(in: &cancellables)
    }

    private func rebuildWindows(state: AtmosphereState) {
        windows.forEach { $0.close() }
        windows.removeAll()

        for screen in NSScreen.screens {
            let window = OverlayWindow(screen: screen)
            let menuBarHeight = max(0, screen.frame.maxY - screen.visibleFrame.maxY)
            let view = OverlayView(
                screenFrame: screen.frame,
                menuBarHeight: menuBarHeight
            )
            .environmentObject(state)
            let hostingView = NSHostingView(rootView: view)
            hostingView.frame = window.contentView?.bounds ?? .zero
            hostingView.autoresizingMask = [.width, .height]
            window.contentView?.addSubview(hostingView)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }
}

final class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = true
        self.isMovableByWindowBackground = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
