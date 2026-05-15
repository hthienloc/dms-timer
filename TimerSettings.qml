import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "../dms-common"

PluginSettings {
    id: root
    pluginId: "timer"

    PluginHeader {
        title: "Timer Settings"
    }

    SettingsCard {
        SectionTitle { text: "Presets" }

        StringSetting {
            settingKey: "presets"
            label: "Quick Presets (minutes)"
            description: "Comma-separated list of minutes for quick start buttons."
            placeholder: "1, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120"
            defaultValue: "1, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120"
        }

        StringSetting {
            settingKey: "quickStartMinutes"
            label: "Right-Click Quick Start (minutes)"
            description: "The duration in minutes to start when right-clicking the icon in Ready state."
            placeholder: "25"
            defaultValue: "25"
        }
    }

    SettingsCard {
        SectionTitle { text: "Behavior & Display" }

        SelectionSetting {
            settingKey: "timeoutBehavior"
            label: "When Finished"
            description: "What to do when the timer reaches zero."
            options: [
                { label: "Stay at Finished", value: "stay" },
                { label: "Reset to Ready", value: "reset" }
            ]
            defaultValue: "reset"
        }

        SelectionSetting {
            settingKey: "displayFormat"
            label: "Display Format"
            description: "Choose how the time is formatted on the bar."
            options: [
                { label: "00:00:00", value: "full" },
                { label: "1h 5m 10s", value: "compact" },
                { label: "5m 10s", value: "minimal" }
            ]
            defaultValue: "full"
        }

        ToggleSetting {
            settingKey: "showHints"
            label: "Show Hints"
            description: "Display helpful usage tips and shortcuts at the bottom of the popout."
            defaultValue: true
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
            placeholder: "Timer"
            defaultValue: "Timer"
            visible: pluginData.showNotification ?? true
        }

        StringSetting {
            settingKey: "notificationBody"
            label: "Notification Body"
            placeholder: "Timeout!"
            defaultValue: "Timeout!"
            visible: pluginData.showNotification ?? true
        }
    }

    SettingsCard {
        SectionTitle { text: "Sound" }

        StringSetting {
            settingKey: "soundPath"
            label: "Custom Sound Path"
            description: "Full path to sound file. Leave empty for default."
            placeholder: "/usr/share/sounds/freedesktop/stereo/complete.oga"
            defaultValue: ""
        }
        
        ToggleSetting {
            settingKey: "useSystemNotificationSound"
            label: "Use System Notification Sound"
            description: "Use system's critical notification sound if no path is set."
            defaultValue: true
        }
    }
}
