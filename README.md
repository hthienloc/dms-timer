# Timer

Countdown timer with presets and notifications.

<img src="screenshot.png" width="300" alt="Screenshot">

## Install


**Required:** This plugin requires [dms-common](https://github.com/hthienloc/dms-common) to be installed.

```bash
# 1. Install shared components
git clone https://github.com/hthienloc/dms-common ~/.config/DankMaterialShell/plugins/dms-common

# 2. Install this plugin
dms://plugin/install/timer
```

Or manually:
```bash
git clone https://github.com/hthienloc/dms-timer ~/.config/DankMaterialShell/plugins/timer
```

## Features

- **Quick presets** - Customizable minute buttons
- **Desktop notification** - Alerts when timer finishes
- **Custom sound** - Use system sound or set your own
- **Auto-reset** - Option to reset after completion

## Usage

| Action | Result |
|--------|--------|
| Left click | Open timer |
| Right click | Quick start / pause |
| Enter key | Reset |

## License

GPL-3.0

## Roadmap / TODO

- [ ] **Pomodoro Support**: Dedicated mode with automated work/break cycles and session tracking.
- [ ] **Extended Precise Input**: Support for `HH:MM:SS` format in manual input for long-running tasks.
- [ ] **Custom "When Done" Actions**: Execute shell commands or trigger system actions (Lock, Suspend) on timeout.
- [ ] **Multi-Timer Manager**: Support for labeling and tracking multiple concurrent countdowns.
- [ ] **External Control (IPC)**: API to start, pause, or reset timers via command line or external scripts.
- [ ] **Improved Persistence**: Save active timer state to disk to survive session restarts.

