import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    pluginId: "timer"

    StyledText {
        width: parent.width
        text: "Presets"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "presets"
        label: "Quick Presets (minutes)"
        description: "Comma-separated list of minutes for quick start buttons."
        placeholder: "5, 10, 15, 20, 25, 30, 45, 60, 120"
        defaultValue: "5, 10, 15, 20, 25, 30, 45, 60, 120"
    }

    StyledText {
        width: parent.width
        text: "Notifications"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    ToggleSetting {
        settingKey: "showNotification"
        label: "Show Desktop Notification"
        description: "Display a notification when the timer finishes."
        defaultValue: true
    }

    StringSetting {
        settingKey: "notificationTitle"
        label: "Notification Title"
        description: "Title of the desktop notification."
        placeholder: "Timer"
        defaultValue: "Timer"
        visible: pluginData.showNotification ?? true
    }

    StringSetting {
        settingKey: "notificationBody"
        label: "Notification Body"
        description: "Message of the desktop notification."
        placeholder: "Timeout!"
        defaultValue: "Timeout!"
        visible: pluginData.showNotification ?? true
    }

    StyledText {
        width: parent.width
        text: "Behavior & Display"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    SelectionSetting {
        settingKey: "timeoutBehavior"
        label: "When Finished"
        description: "What to do when the timer reaches zero."
        options: [
            { label: "Stay at Finished", value: "stay" },
            { label: "Reset to Ready", value: "reset" }
        ]
        defaultValue: "stay"
    }

    SelectionSetting {
        settingKey: "displayFormat"
        label: "Display Format"
        description: "How the time is shown on the bar."
        options: [
            { label: "Full (00:00:00)", value: "full" },
            { label: "Compact (1h 5m 10s)", value: "compact" },
            { label: "Minimal (5m)", value: "minimal" }
        ]
        defaultValue: "full"
    }

    StyledText {
        width: parent.width
        text: "Sound"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    StringSetting {
        settingKey: "soundPath"
        label: "Custom Sound Path"
        description: "Full path to a sound file to play when the timer finishes. Leave empty for system default."
        placeholder: "/usr/share/sounds/freedesktop/stereo/complete.oga"
        defaultValue: ""
    }
    
    ToggleSetting {
        settingKey: "useSystemNotificationSound"
        label: "Use System Notification Sound"
        description: "If enabled and custom path is empty, use the system's critical notification sound."
        defaultValue: true
    }
}
