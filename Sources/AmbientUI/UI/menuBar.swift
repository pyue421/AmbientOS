import SwiftUI

#Preview {
    MenuBarContentView()
        .environmentObject(AtmosphereState())
}

struct MenuBarContentView: View {
    @EnvironmentObject private var state: AtmosphereState
    @State private var selectedTab: SettingsTab = .modes

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            tabPicker

            if selectedTab == .modes {
                modeCards
            } else {
                customControls
            }

            soundControls
        }
        .padding(16)
        .onAppear {
            syncSelectedTab()
        }
        .onChange(of: state.selectedMode) { _ in
            syncSelectedTab()
        }
        .onChange(of: selectedTab) { newTab in
            guard state.isEnabled else { return }
            switch newTab {
            case .modes:
                if state.selectedMode == .custom {
                    state.apply(mode: .studio)
                }
            case .custom:
                if state.selectedMode != .custom {
                    state.apply(mode: .custom)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("AmbientOS")
                .font(.custom("Snell Roundhand", size: 21))
            Spacer()
            Toggle("", isOn: appEnabledBinding)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }

    private var tabPicker: some View {
        Picker("", selection: $selectedTab) {
            ForEach(SettingsTab.allCases) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .disabled(!state.isEnabled)
        .opacity(state.isEnabled ? 1.0 : 0.55)
    }

    private var modeCards: some View {
        HStack(spacing: 12) {
            modeCard(for: .studio)
            modeCard(for: .focused)
            modeCard(for: .minimal)
        }
        .disabled(!state.isEnabled)
        .opacity(state.isEnabled ? 1.0 : 0.55)
    }

    private func modeCard(for mode: AmbientMode) -> some View {
        let isSelected = state.isEnabled && state.selectedMode == mode
        return Button {
            guard state.isEnabled else { return }
            state.apply(mode: mode)
        } label: {
            VStack(spacing: 8) {
                AppearanceModeCardGraphic(mode: mode, isSelected: isSelected)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.4, contentMode: .fit)

                Text(mode.rawValue)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .disabled(!state.isEnabled)
        .buttonStyle(.plain)
    }

    private var customControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overlay")
                .font(.subheadline.weight(.semibold))

            LabeledSlider(
                title: "Warmth",
                value: customWarmthBinding,
                range: -1.0 ... 1.0
            )

            LabeledSlider(
                title: "Opacity",
                value: customOpacityBinding,
                range: 0.0 ... 0.4
            )

            LabeledSlider(
                title: "Vignette",
                value: customVignetteBinding,
                range: 0.0 ... 0.5
            )
            
            Divider()

            Text("Cursor")
                .font(.subheadline.weight(.semibold))

            Picker("", selection: cursorCustomizationBinding) {
                Text("Default").tag(CursorCustomization.default)
                Text("Custom").tag(CursorCustomization.custom)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if cursorCustomizationBinding.wrappedValue == .custom {
                Picker("Shape", selection: customCursorShapeBinding) {
                    ForEach(CursorShape.allCases) { shape in
                        Text(shape.rawValue).tag(shape)
                    }
                }

                Menu {
                    ForEach(emojiChoices, id: \.self) { emoji in
                        Button(emoji) {
                            state.updateCustomCursor { $0.emoji = emoji }
                        }
                    }
                } label: {
                    HStack {
                        Text("Choose emoji")
                        Spacer()
                        Text(state.customCursorStyle.emoji)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
                .buttonStyle(.plain)

                Toggle("Trailing Effect", isOn: customTrailingBinding)
            }
        }
        .disabled(!state.isEnabled)
        .opacity(state.isEnabled ? 1.0 : 0.55)
    }

    private var soundControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            HStack {
                Text("Sound")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Toggle("", isOn: soundEnabledBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }

            if state.soundEnabled {
                Text(soundModeLabel(for: state.selectedMode))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(state.nowPlayingText)
                    .font(.caption)
                    .lineLimit(2)
                    .textSelection(.enabled)

                if state.selectedMode == .custom {
                    TextField("Spotify playlist URL", text: customPlaylistURLBinding)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .disabled(!state.isEnabled)
        .opacity(state.isEnabled ? 1.0 : 0.55)
    }

    private var appEnabledBinding: Binding<Bool> {
        Binding(
            get: { state.isEnabled },
            set: { state.isEnabled = $0 }
        )
    }

    private var soundEnabledBinding: Binding<Bool> {
        Binding(
            get: { state.soundEnabled },
            set: { state.soundEnabled = $0 }
        )
    }

    private var customPlaylistURLBinding: Binding<String> {
        Binding(
            get: { state.customPlaylistURL },
            set: { state.customPlaylistURL = $0 }
        )
    }

    private var cursorCustomizationBinding: Binding<CursorCustomization> {
        Binding(
            get: { state.customCursorStyle == .default ? .default : .custom },
            set: { newValue in
                switch newValue {
                case .default:
                    state.updateCustomCursor { $0 = .default }
                case .custom:
                    if state.customCursorStyle == .default {
                        state.updateCustomCursor {
                            $0.shape = .emoji
                            $0.emoji = "🎯"
                            $0.trailingEnabled = true
                        }
                    }
                }
            }
        )
    }

    private var customWarmthBinding: Binding<Double> {
        Binding(
            get: { state.customOverlayStyle.warmth },
            set: { newValue in
                state.updateCustomOverlay { $0.warmth = newValue }
            }
        )
    }

    private var customOpacityBinding: Binding<Double> {
        Binding(
            get: { state.customOverlayStyle.opacity },
            set: { newValue in
                state.updateCustomOverlay { $0.opacity = newValue }
            }
        )
    }

    private var customVignetteBinding: Binding<Double> {
        Binding(
            get: { state.customOverlayStyle.vignette },
            set: { newValue in
                state.updateCustomOverlay { $0.vignette = newValue }
            }
        )
    }

    private var customCursorShapeBinding: Binding<CursorShape> {
        Binding(
            get: { state.customCursorStyle.shape },
            set: { newValue in
                state.updateCustomCursor { $0.shape = newValue }
            }
        )
    }

    private var customTrailingBinding: Binding<Bool> {
        Binding(
            get: { state.customCursorStyle.trailingEnabled },
            set: { newValue in
                state.updateCustomCursor { $0.trailingEnabled = newValue }
            }
        )
    }

    private func syncSelectedTab() {
        let nextTab: SettingsTab = state.selectedMode == .custom ? .custom : .modes
        if selectedTab != nextTab {
            selectedTab = nextTab
        }
    }

    private var emojiChoices: [String] {
        ["✨", "🎯", "🫧", "🌙", "🔥", "💡", "🧠"]
    }

    private func soundModeLabel(for mode: AmbientMode) -> String {
        switch mode {
        case .studio:
            return "Studio playlist"
        case .focused:
            return "No music in Focused mode"
        case .minimal:
            return "Ambient playlist"
        case .custom:
            return "Custom playlist"
        }
    }
}

private enum SettingsTab: String, CaseIterable, Identifiable, Hashable {
    case modes = "Modes"
    case custom = "Custom"

    var id: String { rawValue }
}

private enum CursorCustomization: Hashable {
    case `default`
    case custom
}

private struct AppearanceModeCardGraphic: View {
    let mode: AmbientMode
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))

            modeBackground
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

            HStack(alignment: .top, spacing: 0) {
                miniWindow(light: true)
                miniWindow(light: false)
            }
            .padding(8)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: isSelected ? 3 : 1)
        )
    }

    @ViewBuilder
    private var modeBackground: some View {
        switch mode {
        case .studio:
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.44, blue: 0.84), Color(red: 0.37, green: 0.14, blue: 0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .focused:
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.15, blue: 0.45), Color(red: 0.03, green: 0.06, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            LinearGradient(
                colors: [Color(red: 0.29, green: 0.74, blue: 0.96), Color(red: 0.06, green: 0.44, blue: 0.90)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .custom:
            Color.clear
        }
    }

    private func miniWindow(light: Bool) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(light ? Color.white.opacity(0.88) : Color(red: 0.06, green: 0.08, blue: 0.16).opacity(0.92))
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(light ? Color(red: 0.38, green: 0.79, blue: 1.0) : Color(red: 0.11, green: 0.35, blue: 0.84))
                    .frame(width: 28, height: 8)
                    .padding(4)
            }
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 3) {
                    Circle().fill(Color.red.opacity(0.9))
                    Circle().fill(Color.orange.opacity(0.9))
                    Circle().fill(Color.green.opacity(0.9))
                }
                .frame(width: 20, height: 5)
                .padding(4)
            }
    }
}
