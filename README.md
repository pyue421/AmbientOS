# AmbientOS (Frontend Prototype)

AmbientOS is a SwiftUI macOS menu bar prototype for a design-first atmosphere layer.

## What is implemented
- Menu bar app with modes: Studio, Minimal, Focused, Custom
- Full-screen click-through overlay (all screens)
- Dynamic cursor layer with minimal shape or emoji mode
- Optional cursor trail
- Smooth mode transitions and centralized state management

## Run
```bash
swift run
```

The app appears as a menu bar extra named **AmbientOS**.

## Architecture
- `App/`: app entry + runtime boot
- `Models/`: mode and style domain models + mode presets
- `State/`: shared observable state and mode application logic
- `Overlay/`: transparent overlay windows and visual rendering
- `Cursor/`: cursor windows, pointer tracking, and custom cursor rendering
- `UI/`: menu bar controls and customization panel

## P2 extension hooks
- Sound transitions and ambience orchestration hook:
  - `Sources/AmbientOS/State/AtmosphereState.swift`
- Focus Mode and advanced menu controls hook:
  - `Sources/AmbientOS/UI/MenuBarContentView.swift`
- Particle effects hook from cursor motion stream:
  - `Sources/AmbientOS/Cursor/CursorWindowController.swift`
