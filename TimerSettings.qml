import "../dms-common"
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginSettings {
    id: root

    pluginId: "timer"

    PluginHeader {
        title: "Timer Settings"
    }

    SettingsCard {
        SectionTitle {
            text: "Presets"
        }

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
        SectionTitle {
            text: "Display"
        }

        ToggleSetting {
            settingKey: "showPillIcon"
            label: "Show Icon"
            description: "Display the status icon alongside the content. Has no effect in Icon Only or Pulse Dot modes."
            defaultValue: true
        }

        ToggleSetting {
            settingKey: "showReadyPlaceholder"
            label: "Show Ready Placeholder"
            description: "Show placeholder digits/text when the timer is in the ready state."
            defaultValue: true
        }

        SelectionSetting {
            settingKey: "displayFormat"
            label: "Display Content"
            description: "Choose what content is displayed on the bar."
            options: [{
                "label": "00:00:00",
                "value": "full"
            }, {
                "label": "1h 5m 10s",
                "value": "compact"
            }, {
                "label": "5m 10s",
                "value": "minimal"
            }, {
                "label": "Progress Bar",
                "value": "progress"
            }, {
                "label": "Icon Only",
                "value": "icon"
            }, {
                "label": "Pulse Dot ✦",
                "value": "pulse"
            }]
            defaultValue: "full"
        }

    }

    SettingsCard {
        SectionTitle {
            text: "Notifications"
        }

        SelectionSetting {
            settingKey: "timeoutBehavior"
            label: "When Finished"
            description: "What to do when the timer reaches zero."
            options: [{
                "label": "Stay at Finished",
                "value": "stay"
            }, {
                "label": "Reset to Ready",
                "value": "reset"
            }]
            defaultValue: "reset"
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
        SectionTitle {
            text: "Custom Actions"
        }

        SelectionSetting {
            settingKey: "systemActionOnTimeout"
            label: "Trigger System Action"
            description: "Automatically perform a system action when the timer finishes."
            options: [{
                "label": "None",
                "value": "none"
            }, {
                "label": "Lock Screen",
                "value": "lock"
            }, {
                "label": "Suspend",
                "value": "suspend"
            }, {
                "label": "Hibernate",
                "value": "hibernate"
            }, {
                "label": "Power Off",
                "value": "poweroff"
            }]
            defaultValue: "none"
        }

        StringSetting {
            settingKey: "customCommandOnTimeout"
            label: "Run Custom Shell Command"
            description: "Execute a shell command when the timer finishes."
            placeholder: "e.g., systemctl suspend"
            defaultValue: ""
        }

    }

    SettingsCard {
        SectionTitle {
            text: "Sound"
        }

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

    SettingsCard {
        SectionTitle {
            text: "Behavior"
        }

        ToggleSetting {
            settingKey: "showHints"
            label: "Show Hints"
            description: "Display helpful usage tips and shortcuts at the bottom of the popout."
            defaultValue: true
        }

    }

}
