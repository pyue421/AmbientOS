import Combine
import CoreGraphics
import Foundation

@MainActor
final class FocusWindowController {
    private var tickCancellable: AnyCancellable?
    private var stateCancellable: AnyCancellable?

    func start(with state: AtmosphereState) {
        refresh(state: state)

        tickCancellable = Timer.publish(every: 0.75, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh(state: state)
            }

        stateCancellable = Publishers.CombineLatest(state.$selectedMode, state.$selectedFocusWindowID)
            .sink { [weak self] _, _ in
                self?.refresh(state: state)
            }
    }

    private func refresh(state: AtmosphereState) {
        let windows = fetchOnScreenWindows()
        state.setAvailableFocusWindows(windows)

        guard state.isEnabled, state.selectedMode == .focused, let selectedID = state.selectedFocusWindowID else {
            state.setFocusedWindowFrame(nil)
            return
        }

        let selectedBounds = windows.first(where: { $0.id == selectedID })?.bounds
        state.setFocusedWindowFrame(selectedBounds)
    }

    private func fetchOnScreenWindows() -> [FocusTargetWindow] {
        guard let windowInfoList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return []
        }

        var seenIDs: Set<Int> = []
        var results: [FocusTargetWindow] = []
        let processName = ProcessInfo.processInfo.processName

        for info in windowInfoList {
            guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
            guard let alpha = info[kCGWindowAlpha as String] as? Double, alpha > 0.01 else { continue }
            guard let ownerName = info[kCGWindowOwnerName as String] as? String, !ownerName.isEmpty else { continue }
            guard !ownerName.localizedCaseInsensitiveContains(processName) else { continue }

            guard let number = info[kCGWindowNumber as String] as? Int else { continue }
            guard !seenIDs.contains(number) else { continue }

            guard let boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
                  let bounds = CGRect(dictionaryRepresentation: boundsDict),
                  bounds.width > 120,
                  bounds.height > 80 else {
                continue
            }

            seenIDs.insert(number)
            let title = info[kCGWindowName as String] as? String ?? ""
            results.append(
                FocusTargetWindow(
                    id: number,
                    ownerName: ownerName,
                    title: title,
                    bounds: bounds
                )
            )
        }

        return results.sorted { lhs, rhs in
            if lhs.ownerName != rhs.ownerName {
                return lhs.ownerName.localizedCaseInsensitiveCompare(rhs.ownerName) == .orderedAscending
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }
}
