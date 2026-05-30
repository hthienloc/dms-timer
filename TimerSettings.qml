import "./dms-common"
import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginSettings {
    id: root

    pluginId: "timer"

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Presets"); icon: "timer"
        }

        StringSetting {
            settingKey: "presets"
            label: I18n.tr("Quick Presets (minutes)")
            description: I18n.tr("Comma-separated list of minutes for quick start buttons.")
            placeholder: "1, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120"
            defaultValue: "1, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120"
        }

        StringSetting {
            settingKey: "quickStartMinutes"
            label: I18n.tr("Right-Click Quick Start (minutes)")
            description: I18n.tr("The duration in minutes to start when right-clicking the icon in Ready state.")
            placeholder: "25"
            defaultValue: "25"
        }

    }

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Display"); icon: "display_settings"
        }

        ToggleSetting {
            settingKey: "showPillIcon"
            label: I18n.tr("Show Icon")
            description: I18n.tr("Display the status icon alongside the content. Has no effect in Icon Only or Pulse Dot modes.")
            defaultValue: true
        }

        ToggleSetting {
            settingKey: "showReadyPlaceholder"
            label: I18n.tr("Show Ready Placeholder")
            description: I18n.tr("Show placeholder digits/text when the timer is in the ready state.")
            defaultValue: true
        }

        SelectionSetting {
            settingKey: "displayFormat"
            label: I18n.tr("Display Content")
            description: I18n.tr("Choose what content is displayed on the bar.")
            options: [{
                "label": "00:00:00",
                "value": "full"
            }, {
                "label": I18n.tr("1h 5m 10s"),
                "value": "compact"
            }, {
                "label": I18n.tr("5m 10s"),
                "value": "minimal"
            }, {
                "label": I18n.tr("Progress Bar"),
                "value": "progress"
            }, {
                "label": I18n.tr("Icon Only"),
                "value": "icon"
            }, {
                "label": I18n.tr("Pulse Dot ✦"),
                "value": "pulse"
            }]
            defaultValue: "full"
        }

    }

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Notifications"); icon: "notifications"
        }

        SelectionSetting {
            settingKey: "timeoutBehavior"
            label: I18n.tr("When Finished")
            description: I18n.tr("What to do when the timer reaches zero.")
            options: [{
                "label": I18n.tr("Stay at Finished"),
                "value": "stay"
            }, {
                "label": I18n.tr("Reset to Ready"),
                "value": "reset"
            }]
            defaultValue: "reset"
        }

        ToggleSetting {
            settingKey: "showNotification"
            label: I18n.tr("Show Desktop Notification")
            description: I18n.tr("Display a notification when the timer finishes.")
            defaultValue: true
        }

        StringSetting {
            settingKey: "notificationTitle"
            label: I18n.tr("Notification Title")
            placeholder: I18n.tr("Timer")
            defaultValue: I18n.tr("Timer")
            visible: pluginData.showNotification ?? true
        }

        StringSetting {
            settingKey: "notificationBody"
            label: I18n.tr("Notification Body")
            placeholder: I18n.tr("Timeout!")
            defaultValue: I18n.tr("Timeout!")
            visible: pluginData.showNotification ?? true
        }

        ToggleSetting {
            settingKey: "autoDND"
            label: I18n.tr("Automatically Do Not Disturb")
            description: I18n.tr("Toggle Do Not Disturb mode when the timer is active.")
            defaultValue: false
        }

    }

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Custom Actions"); icon: "bolt"
        }

        SelectionSetting {
            settingKey: "systemActionOnTimeout"
            label: I18n.tr("Trigger System Action")
            description: I18n.tr("Automatically perform a system action when the timer finishes.")
            options: [{
                "label": I18n.tr("None"),
                "value": "none"
            }, {
                "label": I18n.tr("Lock Screen"),
                "value": "lock"
            }, {
                "label": I18n.tr("Suspend"),
                "value": "suspend"
            }, {
                "label": I18n.tr("Hibernate"),
                "value": "hibernate"
            }, {
                "label": I18n.tr("Power Off"),
                "value": "poweroff"
            }]
            defaultValue: "none"
        }

        StringSetting {
            settingKey: "customCommandOnTimeout"
            label: I18n.tr("Run Custom Shell Command")
            description: I18n.tr("Execute a shell command when the timer finishes.")
            placeholder: "e.g., systemctl suspend"
            defaultValue: ""
        }

    }

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Sound"); icon: "volume_up"
        }

        StringSetting {
            settingKey: "soundPath"
            label: I18n.tr("Custom Sound Path")
            description: I18n.tr("Full path to sound file. Leave empty for default.")
            placeholder: "/usr/share/sounds/freedesktop/stereo/complete.oga"
            defaultValue: ""
        }

        ToggleSetting {
            settingKey: "useSystemNotificationSound"
            label: I18n.tr("Use System Notification Sound")
            description: I18n.tr("Use system's critical notification sound if no path is set.")
            defaultValue: true
        }

    }

    SettingsCard {
        SectionTitle {
            text: I18n.tr("Behavior"); icon: "settings"
        }

        ToggleSetting {
            settingKey: "showTimeoutActions"
            label: I18n.tr("Show 'When Done' Section")
            description: I18n.tr("Display custom timeout and system actions in the popout.")
            defaultValue: true
        }

        ToggleSetting {
            settingKey: "showHints"
            label: I18n.tr("Show Hints")
            description: I18n.tr("Display helpful usage tips and shortcuts at the bottom of the popout.")
            defaultValue: true
        }

    }

    PluginAbout {
        repoUrl: "https://github.com/hthienloc/dms-timer"
    }

}
