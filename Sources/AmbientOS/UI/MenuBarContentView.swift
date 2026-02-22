import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var state: AtmosphereState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("AmbientOS")
                .font(.headline)

            modePicker

            Divider()
            overlayControls

            Divider()
            cursorControls

            Divider()
            footerActions
        }
        .padding(14)
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mode")
                .font(.subheadline.weight(.semibold))

            Picker("Mode", selection: selectedModeBinding) {
                ForEach(AmbientMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var overlayControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Overlay")
                .font(.subheadline.weight(.semibold))

            ColorPicker("Tint", selection: customOverlayTintBinding, supportsOpacity: false)

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
        }
    }

    private var cursorControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cursor")
                .font(.subheadline.weight(.semibold))

            Picker("Shape", selection: customCursorShapeBinding) {
                ForEach(CursorShape.allCases) { shape in
                    Text(shape.rawValue).tag(shape)
                }
            }

            TextField("Emoji", text: customCursorEmojiBinding)
                .textFieldStyle(.roundedBorder)

            Toggle("Trailing Effect", isOn: customTrailingBinding)
        }
    }

    private var footerActions: some View {
        HStack {
            Button("Reset Custom") {
                state.customOverlayStyle = OverlayStyle(
                    tintColor: Color(red: 0.95, green: 0.95, blue: 0.95),
                    warmth: 0.0,
                    opacity: 0.08,
                    vignette: 0.08
                )
                state.customCursorStyle = .default
                if state.selectedMode == .custom {
                    state.apply(mode: .custom)
                }
            }

            Spacer()

            Text("P2 hooks ready")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        // Future extension point:
        // Expose sound profile, Focus Mode controls, and particle toggles in this section.
    }

    private var selectedModeBinding: Binding<AmbientMode> {
        Binding(
            get: { state.selectedMode },
            set: { state.apply(mode: $0) }
        )
    }

    private var customOverlayTintBinding: Binding<Color> {
        Binding(
            get: { state.customOverlayStyle.tintColor },
            set: { newValue in
                state.updateCustomOverlay { $0.tintColor = newValue }
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

    private var customCursorEmojiBinding: Binding<String> {
        Binding(
            get: { state.customCursorStyle.emoji },
            set: { newValue in
                state.updateCustomCursor { $0.emoji = String(newValue.prefix(2)) }
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
}

