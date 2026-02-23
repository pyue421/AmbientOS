import Foundation

@MainActor
final class PomodoroModel: ObservableObject {
    enum Phase {
        case work
        case `break`
    }

    @Published private(set) var phase: Phase = .work
    @Published private(set) var secondsRemaining: Int = 25 * 60
    @Published private(set) var isPaused: Bool = false

    private let workSeconds = 25 * 60
    private let breakSeconds = 5 * 60

    var titleText: String {
        switch phase {
        case .work:
            return "Focus Session"
        case .break:
            return "Break Time"
        }
    }

    var pauseButtonSymbol: String {
        isPaused ? "play.fill" : "pause.fill"
    }

    var progress: Double {
        let total = phase == .work ? workSeconds : breakSeconds
        guard total > 0 else { return 0 }
        let elapsed = total - secondsRemaining
        return max(0, min(1, Double(elapsed) / Double(total)))
    }

    var remainingText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func tick() {
        guard !isPaused else { return }

        if secondsRemaining > 0 {
            secondsRemaining -= 1
            return
        }

        switch phase {
        case .work:
            phase = .break
            secondsRemaining = breakSeconds
        case .break:
            phase = .work
            secondsRemaining = workSeconds
        }
    }

    func togglePaused() {
        isPaused.toggle()
    }
}
