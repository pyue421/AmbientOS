# spec.md — AmbientOS

## TL;DR
AmbientOS is an experimental **macOS menu bar app** that lets users intentionally set a “desktop atmosphere” via **modes** that control:
- **Screen layer** (tint / warmth / subtle display styling)
- **Cursor layer** (shape / emoji cursor)
- **Sound layer** (ambient + subtle action sounds that do not break system notifications)

Design-first, sensory/interaction experimentation (not an accessibility tool).

---

## Product Goals
1. **Fast mode switching**: user can switch modes in **< 3 seconds**.
2. **Reliable layering**: screen + cursor + sound apply correctly per mode.
3. **Low overhead**: no noticeable slowdown (target **<1% CPU**, no perceived lag).
4. **Taste + polish**: minimal, refined, calm UI.

## Non-Goals
- Replacing macOS Accessibility features (we can complement, not replicate).
- Deep system-wide notification interception/rewriting.
- Window manager / tiling.
- Cloud sync, accounts, analytics (for now).

---

## Target Users
- Primary: creative + productivity-focused macOS users who care about sensory environment.
- Secondary: users who want playful/relaxing interactions while working.

---

## Definitions
- **Mode**: a named preset that sets values for Screen/Cursor/Sound.
- **Layers**:
  - **Screen layer**: transparent overlay window(s) applying tint/warmth effects.
  - **Cursor layer**: a custom cursor overlay that visually replaces the system cursor.
  - **Sound layer**: ambient audio + subtle UI action sounds (in-app actions first).

---

## MVP Scope (P1)
### 1) Menu Bar App Shell
- Menu bar icon with:
  - Mode picker (Studio / Focused / Minimal)
  - Quick toggles (Enable Screen / Cursor / Sound)
  - “Open Settings…” window (SwiftUI)
- App runs as **LSUIElement** (agent-like menu bar app).

### 2) Preconfigured Modes (P1)
**Studio**
- Screen: slightly warm (approx 5500–6000K vibe) + soft neutral tint (low alpha).
- Cursor: simple minimal custom shape (e.g., dot/circle).
- Sound: optional ambient background loop (soft).

**Focused**
- Screen: dim/desaturate overlay globally; optionally “focus highlight” is deferred (P2).
- Cursor: minimal; optional in-app Pomodoro indicator is deferred (P2).
- Sound: disable ambient; mute in-app action sounds.

**Minimal**
- Screen: near-default (overlay off or extremely subtle).
- Cursor: emoji replacement cursor (user picks from macOS emoji list).
- Sound: minimal (off by default).

> Note: Focused “highlight selected app/tab” is complex; keep P1 to global overlay dimming only.

### 3) Custom Settings (P1)
Settings UI supports per-mode values:
- **Screen Display**
  - Tint color (picker)
  - Tint intensity (0–100)
  - Warmth slider (implemented as preset matrix / overlay blend approximation)
  - Transition animation (fade duration)
- **Cursor**
  - Cursor style: Default / Dot / Ring / Emoji
  - Size slider
  - Emoji picker (basic set + recent emoji)
- **Sound**
  - Ambient on/off
  - Ambient volume
  - Action sounds on/off (for AmbientOS actions like switching modes)

### 4) Performance / Quality (P1)
- Overlay redraw should be cheap (avoid continuous animation).
- Cursor overlay updates on mouse move only; throttled if needed.
- No runaway timers; use event-driven updates.

---

## P2 Scope (Nice-to-have / Stretch)
- Save custom modes as presets (local JSON).
- Cursor motion effects (glow/particles).
- Screen grain/vignette, more cinematic transitions.
- Allow custom notification sounds from local files.
- Reduced motion toggle + color-blind-friendly overlay variations.
- “Focused highlight active app” (likely via Accessibility APIs + window detection; evaluate feasibility).

---

## User Experience
### Primary Flow
1. User clicks menu bar icon.
2. Chooses a mode (Studio/Focused/Minimal).
3. Layers update immediately with a soft fade.
4. User opens Settings, adjusts sliders, sees instant preview.
5. (P2) User saves as a custom preset.

### UI Principles
- Minimal controls, no clutter.
- Use subtle typography + spacing.
- Animate only when it adds calmness (fade, cross-dissolve).

---

## Technical Architecture
### App Structure
- Swift + SwiftUI
- MVVM-ish: `AppState` + `ModeManager` + per-layer controllers

**Core modules**
- `ModeManager`
  - owns list of `Mode` objects
  - applies a mode to all layers
- `ScreenLayerController`
  - manages overlay windows
  - applies tint/warmth parameters
- `CursorLayerController`
  - hides system cursor (when enabled) and draws replacement
  - tracks mouse movement events
- `SoundLayerController`
  - plays ambient loop + action sounds
  - respects per-mode volume + enable toggles
- `Persistence` (P2)
  - saves/loads modes to JSON in Application Support

### Data Model
```swift
struct Mode: Codable, Identifiable {
  var id: UUID
  var name: String
  var screen: ScreenSettings
  var cursor: CursorSettings
  var sound: SoundSettings
}

struct ScreenSettings: Codable {
  var enabled: Bool
  var tintColor: RGBAColor
  var tintIntensity: Double // 0...1
  var warmth: Double        // 0...1 (conceptual)
  var transitionDuration: Double
}

struct CursorSettings: Codable {
  var enabled: Bool
  var style: CursorStyle // default/dot/ring/emoji
  var size: Double
  var emoji: String?     // for emoji style
}

struct SoundSettings: Codable {
  var enabled: Bool
  var ambientEnabled: Bool
  var ambientVolume: Double
  var actionSoundsEnabled: Bool
}