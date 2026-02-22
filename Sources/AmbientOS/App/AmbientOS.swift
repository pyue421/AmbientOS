import SwiftUI

@main
struct AmbientOS: App {
    @StateObject private var atmosphereState = AtmosphereState()
    @StateObject private var runtime = AtmosphereRuntime()

    var body: some Scene {
        MenuBarExtra("AmbientOS", systemImage: "sun.horizon.circle") {
            MenuBarContentView()
                .environmentObject(atmosphereState)
                .frame(minWidth: 320) // Set a minimum width for the menu bar
                .onAppear {
                    runtime.start(with: atmosphereState)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
