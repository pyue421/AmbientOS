import CoreGraphics
import Foundation

struct FocusTargetWindow: Identifiable, Equatable {
    let id: Int
    let ownerName: String
    let title: String
    let bounds: CGRect

    var displayName: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? ownerName : "\(ownerName) - \(trimmed)"
    }
}
