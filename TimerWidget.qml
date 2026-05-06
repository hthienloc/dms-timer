import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    PluginGlobalVar {
        id: globalRemainingSeconds
        varName: "remainingSeconds"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalIsRunning
        varName: "isRunning"
        defaultValue: false
    }

    PluginGlobalVar {
        id: globalTotalSeconds
        varName: "totalSeconds"
        defaultValue: 0
    }

    readonly property var presets: {
        const raw = pluginData.presets || "5, 10, 15, 20, 25, 30, 45, 60, 120"
        return raw.split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n))
    }

    readonly property string soundPath: pluginData.soundPath || ""
    readonly property bool useSystemNotificationSound: pluginData.useSystemNotificationSound ?? true
    readonly property bool showNotification: pluginData.showNotification ?? true
    readonly property string notificationTitle: pluginData.notificationTitle || "Timer"
    readonly property string notificationBody: pluginData.notificationBody || "Timeout!"
    readonly property string timeoutBehavior: pluginData.timeoutBehavior || "stay"
    readonly property string displayFormat: pluginData.displayFormat || "full"
    readonly property bool showHints: pluginData.showHints ?? true

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: globalIsRunning.value && globalRemainingSeconds.value > 0
        onTriggered: {
            const newVal = globalRemainingSeconds.value - 1
            globalRemainingSeconds.set(newVal)
            if (newVal === 0) {
                globalIsRunning.set(false)
                
                if (root.showNotification) {
                    Proc.runCommand(
                        "timer-notify",
                        ["notify-send", "-i", "appointment-soon", "-u", "normal", root.notificationTitle, root.notificationBody],
                        null,
                        0
                    )
                }

                if (root.soundPath !== "") {
                    Proc.runCommand(
                        "timer-sound",
                        ["paplay", "--property=media.role=event", root.soundPath],
                        null,
                        0
                    )
                } else if (root.useSystemNotificationSound && AudioService.soundsAvailable) {
                    AudioService.playCriticalNotificationSound()
                } else {
                    Proc.runCommand(
                        "timer-sound",
                        ["paplay", "--property=media.role=event",
                         "/usr/share/sounds/freedesktop/stereo/complete.oga"],
                        null,
                        0
                    )
                }

                if (root.timeoutBehavior === "reset") {
                    root.resetTimer()
                }
            }
        }
    }

    function formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600)
        const minutes = Math.floor((totalSeconds % 3600) / 60)
        const seconds = totalSeconds % 60

        if (root.displayFormat === "minimal") {
            if (hours > 0) return hours + "h " + minutes + "m"
            if (minutes > 0) return minutes + "m " + seconds + "s"
            return seconds + "s"
        }

        if (root.displayFormat === "compact") {
            let res = ""
            if (hours > 0) res += hours + "h "
            if (minutes > 0 || hours > 0) res += minutes + "m "
            res += seconds + "s"
            return res.trim()
        }

        // Default: Full format (00:00:00)
        let result = ""
        if (hours > 0)
            result += hours.toString().padStart(2, '0') + ":"
        result += minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0')
        return result
    }

    function setTimer(minutes) {
        const seconds = minutes * 60
        globalTotalSeconds.set(seconds)
        globalRemainingSeconds.set(seconds)
        globalIsRunning.set(true)
    }

    function toggleTimer() {
        if (globalRemainingSeconds.value <= 0) return
        globalIsRunning.set(!globalIsRunning.value)
    }

    function resetTimer() {
        globalIsRunning.set(false)
        globalRemainingSeconds.set(0)
        globalTotalSeconds.set(0)
    }

    function isValidInput(text) {
        if (text === "") return false
        if (!/^\d+$/.test(text)) return false
        const num = parseInt(text, 10)
        return num >= 1 && num <= 999
    }

    readonly property bool isFinished: globalRemainingSeconds.value === 0 && globalTotalSeconds.value > 0
    readonly property bool isPaused: !globalIsRunning.value && globalRemainingSeconds.value > 0 && globalRemainingSeconds.value < globalTotalSeconds.value
    readonly property bool isReady: globalRemainingSeconds.value === 0 && globalTotalSeconds.value === 0

    readonly property color pillColor: {
        if (globalIsRunning.value) return Theme.primary
        if (isPaused || isFinished) return Theme.warning
        return Theme.surfaceText
    }

    pillRightClickAction: () => { toggleTimer() }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: globalIsRunning.value ? "pause" : (root.isReady ? "timer" : "play_arrow")
                size: Theme.iconSizeSmall
                color: root.pillColor
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                color: root.pillColor
                font.pixelSize: Theme.fontSizeMedium
                isMonospace: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingS

            DankIcon {
                name: globalIsRunning.value ? "pause" : (root.isReady ? "timer" : "play_arrow")
                size: Theme.iconSizeSmall
                color: root.pillColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                color: root.pillColor
                font.pixelSize: Theme.fontSizeSmall
                isMonospace: true
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: 90
            }
        }
    }

    popoutContent: Component {
        FocusScope {
            id: contentFocusScope
            width: parent ? parent.width : 0
            implicitHeight: mainContent.implicitHeight
            focus: true

            property var parentPopout: null

            Connections {
                target: parentPopout
                function onOpened() {
                    if (root.isReady) {
                        Qt.callLater(() => customInput.forceActiveFocus());
                    } else {
                        contentFocusScope.forceActiveFocus();
                    }
                }
            }

            PopoutComponent {
                id: mainContent
                width: parent.width
                headerText: "Timer"
                detailsText: {
                    if (globalIsRunning.value) return "Running..."
                    if (root.isPaused) return "Paused"
                    if (root.isFinished) return "Finished!"
                    return "Ready"
                }
                showCloseButton: true

                Column {
                    width: parent.width
                    spacing: Theme.spacingL

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (!root.isReady) {
                                root.toggleTimer();
                            } else if (isValidInput(customInput.text)) {
                                setTimer(parseInt(customInput.text));
                                customInput.text = "";
                            }
                            event.accepted = true;
                        }
                    }

                    StyledText {
                        text: formatTime(globalRemainingSeconds.value)
                        font.pixelSize: 48
                        isMonospace: true
                        font.weight: Font.Bold
                        color: {
                            if (globalIsRunning.value) return Theme.primary
                            if (root.isPaused) return Theme.warning
                            if (root.isFinished) return Theme.error
                            return Theme.surfaceText
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Grid {
                        columns: 3
                        spacing: Theme.spacingS
                        horizontalItemAlignment: Grid.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.isReady

                        Repeater {
                            model: root.presets
                            delegate: DankButton {
                                text: modelData >= 60 ? (modelData / 60) + "h" : modelData + "m"
                                backgroundColor: Theme.primary
                                textColor: Theme.onPrimary
                                onClicked: setTimer(modelData)
                            }
                        }
                    }

                    Row {
                        spacing: Theme.spacingM
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !root.isReady

                        DankButton {
                            text: globalIsRunning.value ? "Pause" : (root.isPaused ? "Resume" : "Start")
                            iconName: globalIsRunning.value ? "pause" : "play_arrow"
                            backgroundColor: globalIsRunning.value ? Theme.error : (root.isPaused ? Theme.warning : Theme.primary)
                            textColor: globalIsRunning.value ? Theme.onError : (root.isPaused ? Theme.onSurface : Theme.onPrimary)
                            visible: !root.isFinished
                            onClicked: toggleTimer()
                        }

                        DankButton {
                            text: "Reset"
                            iconName: "refresh"
                            backgroundColor: Theme.surfaceContainerHigh
                            textColor: Theme.surfaceText
                            onClicked: resetTimer()
                        }
                    }

                    Row {
                        spacing: Theme.spacingS
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.isReady

                        StyledText {
                            text: "Custom (minutes):"
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextField {
                            id: customInput
                            width: 80
                            color: Theme.surfaceText
                            focus: true
                            background: Rectangle {
                                radius: Theme.cornerRadiusSmall
                                color: Theme.surfaceContainer
                                border.color: Theme.outline
                            }
                            onEditingFinished: {
                                if (isValidInput(text)) {
                                    setTimer(parseInt(text))
                                    text = ""
                                }
                            }
                        }

                        DankButton {
                            text: "Set"
                            backgroundColor: Theme.primary
                            textColor: Theme.onPrimary
                            enabled: isValidInput(customInput.text)
                            onClicked: {
                                setTimer(parseInt(customInput.text))
                                customInput.text = ""
                            }
                        }
                    }

                    StyledText {
                        text: "Hint: Right-click the bar icon to pause/resume."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        visible: root.showHints
                    }
                }
            }
        }
    }

    popoutWidth: 400
    popoutHeight: root.showHints ? 380 : 340
}