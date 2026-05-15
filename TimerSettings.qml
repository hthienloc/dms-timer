import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "timer"

    StyledText {
        width: parent.width
        text: "Timer Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledRect {
        width: parent.width
        height: presetsColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: presetsColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
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

            StringSetting {
                settingKey: "quickStartMinutes"
                label: "Right-Click Quick Start (minutes)"
                description: "The duration in minutes to start when right-clicking the icon in Ready state."
                placeholder: "25"
                defaultValue: "25"
            }
        }
    }

    StyledRect {
        width: parent.width
        height: behaviorColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: behaviorColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
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
                defaultValue: "reset"
            }

            SelectionSetting {
                settingKey: "displayFormat"
                label: "Display Format"
                description: "Choose how the time is formatted on the bar."
                options: [
                    { label: "00:00:00", value: "full" },
                    { label: "1h 5m 10s", value: "compact" },
                    { label: "5m 10s", value: "minimal" },
                    { label: "Icon Only", value: "icon" }
                ]
                defaultValue: "full"
            }

            ToggleSetting {
                settingKey: "showHints"
                label: "Show Hints"
                description: "Display helpful usage tips and shortcuts at the bottom of the popout."
                defaultValue: true
            }
        }
    }

    StyledRect {
        width: parent.width
        height: notificationColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: notificationColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
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
    }

    StyledRect {
        width: parent.width
        height: soundColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: soundColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Sound"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
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
    }
}
