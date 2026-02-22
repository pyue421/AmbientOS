import Foundation

enum AmbientMode: String, CaseIterable, Identifiable {
    case studio = "Studio"
    case minimal = "Minimal"
    case focused = "Focused"
    case custom = "Custom"

    var id: String { rawValue }
}

