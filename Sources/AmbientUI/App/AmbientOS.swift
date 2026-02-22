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
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        let circleRect = CGRect(x: 2, y: 2, width: 14, height: 14)
        let colors = [
            NSColor(red: 0.98, green: 0.76, blue: 0.26, alpha: 1.0).cgColor,
            NSColor(red: 0.98, green: 0.49, blue: 0.33, alpha: 1.0).cgColor,
            NSColor(red: 0.80, green: 0.35, blue: 0.95, alpha: 1.0).cgColor,
        ] as CFArray

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: [0.0, 0.55, 1.0]
        )

        context.saveGState()
        context.addEllipse(in: circleRect)
        context.clip()
        if let gradient {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: circleRect.minX, y: circleRect.maxY),
                end: CGPoint(x: circleRect.maxX, y: circleRect.minY),
                options: []
            )
        }
        context.restoreGState()

        context.setStrokeColor(NSColor.white.withAlphaComponent(0.35).cgColor)
        context.setLineWidth(0.8)
        context.strokeEllipse(in: circleRect.insetBy(dx: 0.4, dy: 0.4))

        image.unlockFocus()
        image.isTemplate = false
        return image
    }()
}
