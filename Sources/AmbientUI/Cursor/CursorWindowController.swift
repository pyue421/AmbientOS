import AppKit
import Combine
import SwiftUI

@MainActor
final class CursorWindowController {
    private var window: NSWindow?
    private let model = CursorLayerModel()
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var screenCancellable: AnyCancellable?
    private var stateCancellable: AnyCancellable?
    private var enabledCancellable: AnyCancellable?
    private var terminationCancellable: AnyCancellable?
    private var didHideSystemCursor = false

    func start(with state: AtmosphereState) {
        buildWindowIfNeeded()
        stateCancellable = state.$cursorStyle.sink { [weak self] style in
            self?.model.cursorStyle = style
        }
        model.cursorStyle = state.cursorStyle
        enabledCancellable = state.$isEnabled.sink { [weak self] isEnabled in
            self?.model.isEnabled = isEnabled
            self?.updateSystemCursorVisibility(enabled: isEnabled)
        }
        model.isEnabled = state.isEnabled

        installMouseMonitors()
        updateMousePosition(NSEvent.mouseLocation)
        updateSystemCursorVisibility(enabled: state.isEnabled)

        screenCancellable = NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateWindowFrame()
            }

        terminationCancellable = NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.cleanup()
            }
    }

    private func buildWindowIfNeeded() {
        guard window == nil else { return }

        let frame = combinedScreenFrame()
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
        newWindow.ignoresMouseEvents = true

        let host = NSHostingView(rootView: CursorLayerView(model: model))
        host.frame = CGRect(origin: .zero, size: frame.size)
        host.autoresizingMask = [.width, .height]
        newWindow.contentView?.addSubview(host)
        newWindow.orderFrontRegardless()

        window = newWindow
    }

    private func installMouseMonitors() {
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { [weak self] event in
            self?.updateMousePosition(NSEvent.mouseLocation)
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            _ = event
            self?.updateMousePosition(NSEvent.mouseLocation)
        }
    }

    private func combinedScreenFrame() -> CGRect {
        NSScreen.screens.reduce(into: CGRect.null) { result, screen in
            result = result.union(screen.frame)
        }
    }

    private func updateWindowFrame() {
        guard let window else { return }
        let frame = combinedScreenFrame()
        window.setFrame(frame, display: true)
    }

    private func updateMousePosition(_ globalPoint: CGPoint) {
        let union = combinedScreenFrame()
        let adjusted = CGPoint(x: globalPoint.x - union.origin.x, y: globalPoint.y - union.origin.y)
        model.set(point: adjusted)

        // Future extension point:
        // Particle cursor FX can be sourced from the same motion stream here.
    }

    private func cleanup() {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        if didHideSystemCursor {
            NSCursor.unhide()
            didHideSystemCursor = false
        }
    }

    private func updateSystemCursorVisibility(enabled: Bool) {
        if enabled {
            if !didHideSystemCursor {
                NSCursor.hide()
                didHideSystemCursor = true
            }
            return
        }

        if didHideSystemCursor {
            NSCursor.unhide()
            didHideSystemCursor = false
        }
    }

}
