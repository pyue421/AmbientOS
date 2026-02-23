import AppKit
import SwiftUI

public struct AmbientOSScene: Scene {
    @StateObject private var atmosphereState = AtmosphereState()
    @StateObject private var runtime = AtmosphereRuntime()

    public init() {}

    public var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(atmosphereState)
                .frame(minWidth: 320) // Set a minimum width for the menu bar
                .onAppear {
                    runtime.start(with: atmosphereState)
                }
        } label: {
            Image(nsImage: AmbientMenuBarIconImage.shared)
                .renderingMode(.original)
                .accessibilityLabel("AmbientOS")
        }
        .menuBarExtraStyle(.window)
    }
}

private enum AmbientMenuBarIconImage {
    static let shared: NSImage = {
        let size = NSSize(width: 20, height: 20)
        let image = NSImage(size: size)
        image.lockFocus()

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        let outerRect = CGRect(x: 1.5, y: 1.5, width: 17, height: 17)
        let innerCircleRect = CGRect(x: 5.9, y: 5.9, width: 8.2, height: 8.2)

        context.setFillColor(NSColor(calibratedWhite: 0.16, alpha: 1.0).cgColor)
        let roundedPath = CGPath(
            roundedRect: outerRect,
            cornerWidth: 4.8,
            cornerHeight: 4.8,
            transform: nil
        )
        context.addPath(roundedPath)
        context.fillPath()

        context.setFillColor(NSColor(calibratedWhite: 0.96, alpha: 1.0).cgColor)
        context.fillEllipse(in: innerCircleRect)

        image.unlockFocus()
        image.isTemplate = false
        return image
    }()
}
