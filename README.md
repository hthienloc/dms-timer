# Timer Plugin

A feature-rich countdown timer plugin for [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell).

![Screenshot](screenshot.png)

## Installation

```bash
mkdir -p ~/.config/DankMaterialShell/plugins
git clone https://github.com/hthienloc/dms-timer ~/.config/DankMaterialShell/plugins/timer
```

Then in DMS: **Settings (Meta+,)** → **Plugins** → **Scan for Plugins** → Enable **Timer**.

To update:
```bash
git -C ~/.config/DankMaterialShell/plugins/timer pull
```

## Features

- **Quick Presets**: Customizable minute buttons (default: 5, 10, 15, 20, 25, 30, 45, 60, 120).
- **Custom Duration**: Input any specific time manually.
- **Customizable Notifications**:
    - Toggle desktop notifications.
    - Custom title and message content.
- **Advanced Sound Support**:
    - Use system critical notification sound.
    - Set a custom sound file path (`.oga`, `.mp3`, etc.).
- **Flexible Display**:
    - Multiple bar formats: `00:00:00`, `1h 5m 10s`, or `5m 10s`.
    - Accessibility hints for bar interactions (configurable).
- **Timeout Behavior**: Choose to stay at zero or auto-reset to ready state.
- **Visual Feedback**: Bar pill changes color during warnings (≤60s) and timeout.
- **Interactive Controls**:
    - **Left click**: Open detailed popout.
    - **Right click**: Quick pause/resume from the bar.

## Structure

```
dms-timer/
├── TimerWidget.qml      # Main logic and UI
├── TimerSettings.qml    # Settings interface
├── plugin.json          # Plugin manifest
├── LICENSE
└── README.md
```

## Development

Built with QML using the DMS plugin API. Uses `PluginGlobalVar` for persistent state across bar instances.

## License

GPLv3 - See [LICENSE](LICENSE)
