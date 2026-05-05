# Timer Plugin

A countdown timer plugin for [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell).

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

- Quick preset buttons: 5, 10, 15, 20, 25, 30, 45, 60, 120 minutes
- Custom input for any duration (1-999 minutes)
- Visual warnings: yellow at ≤60s, red when finished
- Smart button states: Start → Resume (when paused) → Pause/Stop
- Left click: Open detailed popout with controls
- Right click: Quick start/pause from the bar
- Uses DMS theme tokens and monospace font

## Structure

```
dms-timer/
├── TimerWidget.qml      # Main logic and UI
├── plugin.json          # Plugin manifest
├── LICENSE
└── README.md
```

## Development

Built with QML using the DMS plugin API. Uses `PluginGlobalVar` for persistent state across bar instances.

## License

GPLv3 - See [LICENSE](LICENSE)
