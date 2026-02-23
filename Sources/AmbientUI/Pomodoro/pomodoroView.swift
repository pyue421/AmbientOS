import SwiftUI

struct PomodoroView: View {
    @ObservedObject var model: PomodoroModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(model.titleText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: model.togglePaused) {
                    Image(systemName: model.pauseButtonSymbol)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.28))
                        )
                }
                .buttonStyle(.plain)

                Text(model.remainingText)
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.primary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.18))

                    Capsule(style: .continuous)
                        .fill(progressColor)
                        .frame(width: max(6, proxy.size.width * model.progress))
                }
            }
            .frame(height: 9)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 340, height: 58)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.62))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    private var progressColor: Color {
        switch model.phase {
        case .work:
            return Color(red: 0.28, green: 0.62, blue: 1.0)
        case .break:
            return Color(red: 0.46, green: 0.86, blue: 0.56)
        }
    }
}
