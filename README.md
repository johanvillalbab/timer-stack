# TimerStack ⏱

> A tiny floating countdown timer that lives on top of everything. Set it, drag it anywhere, get back to work.

TimerStack is a minimal, native macOS timer widget. It floats above all your windows — fullscreen apps included — with the translucent, rounded look of a real macOS widget. No Dock icon, no app window, no clutter. Just a timer, exactly where you want it.

Built with SwiftUI + AppKit. No Electron, no dependencies, no subscriptions.

---

## Why TimerStack

Every timer app wants to be a productivity suite. TimerStack wants to be a timer:

- **Always on top** — floats above every window, every Space, even fullscreen apps
- **Liquid Glass, the real thing** — built on the native `glassEffect` API from macOS 26, not a blur imitation; it could ship with the OS
- **Grab it anywhere** — drag the widget from any point; it remembers where you left it
- **Truly native** — a single small binary; idles at ~0% CPU when no timer is running
- **Never loses time** — countdowns are anchored to a target date, so they survive app restarts and Mac sleep without drifting a single second

## Features

- **One-tap presets** — 1, 5, 10, 15 and 25 minutes (hello, Pomodoro 🍅)
- **Custom times** — type any `min : sec` and hit Start
- **Three-button control** — pause/resume, reset, dismiss; nothing more
- **Alarm you'll notice** — system sound plus a red flashing display until you acknowledge it
- **Menu bar companion** — show/hide the widget or quit from a discreet ⏱ icon
- **Persistent** — running timer and widget position are restored on relaunch

## Install

```bash
git clone https://github.com/johanvillalbab/timer-stack.git
cd timer-stack
./build.sh install   # builds and copies TimerStack.app to /Applications
```

Or just build locally:

```bash
./build.sh           # produces dist/TimerStack.app
open dist/TimerStack.app
```

Requires macOS 26 (Tahoe) or later and Xcode 26 command line tools.

## Usage

| Action | How |
|---|---|
| Set a timer | Click a preset, or type `min : sec` → **Start** |
| Pause / resume | ⏸ / ▶ button |
| Restart | ↺ button |
| Dismiss timer | ✕ button — back to the time picker |
| Move the widget | Drag it from anywhere |
| Show / hide | ⏱ menu bar icon → *Show / hide widget* |

When the countdown hits zero the display flashes red and the alarm sounds until you press **OK**.

## How it works

TimerStack follows a deliberately simple architecture:

```
Sources/TimerStack/
├── TimerStackApp.swift    # @main — MenuBarExtra entry point (LSUIElement, no Dock)
├── FloatingPanel.swift    # Borderless, non-activating NSPanel at .floating level
├── WidgetView.swift       # SwiftUI widget UI (countdown + time picker)
├── AppModel.swift         # State, tick engine, UserDefaults persistence
└── TimerItem.swift        # Codable timer model
```

A few details worth stealing:

- **The window is an `NSPanel`**, not an `NSWindow` — `[.borderless, .nonactivatingPanel]` with `level = .floating` and `canJoinAllSpaces`, so it stays on top everywhere without ever stealing focus from the app you're working in.
- **Native Liquid Glass** — the widget body is a single `.glassEffect(.regular, in: .rect)` that tints red while the alarm fires; controls are interactive glass circles inside a `GlassEffectContainer`, so neighboring shapes merge fluidly.
- **Date-anchored countdowns** — a running timer stores its `endDate`; remaining time is always computed against `Date()`. No accumulated tick drift, immune to sleep.
- **A UI tick that knows when to stop** — a single 0.25 s timer refreshes the display only while a countdown is running; otherwise the app is completely idle.
- **No Xcode project** — plain Swift Package Manager plus a 20-line `build.sh` that assembles and ad-hoc signs the `.app` bundle.

## License

[MIT](LICENSE) — do whatever you want with it.
