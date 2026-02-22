import SwiftUI

@main
struct AmbientOSApp: App {
    @StateObject private var atmosphereState = AtmosphereState()
    @StateObject private var runtime = AtmosphereRuntime()

    var body: some Scene {
        MenuBarExtra("AmbientOS", systemImage: "sun.horizon.circle") {
            MenuBarContentView()
                .environmentObject(atmosphereState)
                .frame(minWidth: 320)
                .onAppear {
                    runtime.start(with: atmosphereState)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
