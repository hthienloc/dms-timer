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
            spacing: root.displayFormat === "icon" ? 0 : Theme.spacingS

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
                visible: root.displayFormat !== "icon"
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: root.displayFormat === "icon" ? 0 : Theme.spacingS

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
                visible: root.displayFormat !== "icon"
            }
        }
    }

    property var manualInputInput: null

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
                        if (root.manualInputInput) root.manualInputInput.forceActiveFocus();
                    } else {
                        contentFocusScope.forceActiveFocus();
                    }
                }
            }

            PopoutComponent {
                id: mainContent
                width: parent.width
                headerText: "Timer"
                showCloseButton: true

                Column {
                    width: parent.width
                    spacing: Theme.spacingL
                    focus: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (!root.isReady && !customInput.getActiveFocus()) {
                                root.resetTimer();
                                event.accepted = true;
                            }
                        }
                    }

                    // --- 1. Dynamic Status Card ---
                    StyledRect {
                        width: parent.width
                        height: 140
                        radius: Theme.cornerRadius
                        color: {
                            if (globalIsRunning.value) return Theme.primaryContainer
                            if (root.isPaused) return Theme.warningContainer || Theme.surfaceContainerHigh
                            if (root.isFinished) return Theme.errorContainer || Theme.surfaceContainerHigh
                            return Theme.surfaceContainerLow
                        }
                        clip: true

                        // Gradient overlay for depth
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0,0,0, 0.05) }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            StyledText {
                                text: {
                                    if (globalIsRunning.value) return "RUNNING"
                                    if (root.isPaused) return "PAUSED"
                                    if (root.isFinished) return "FINISHED"
                                    return "READY"
                                }
                                font.pixelSize: 12
                                font.bold: true
                                color: {
                                    if (globalIsRunning.value) return Theme.primary
                                    if (root.isPaused) return Theme.warning
                                    if (root.isFinished) return Theme.error
                                    return Theme.surfaceText
                                }
                                opacity: 0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            StyledText {
                                text: formatTime(globalRemainingSeconds.value)
                                font.pixelSize: 64
                                isMonospace: true
                                font.weight: Font.Bold
                                color: Theme.surfaceText
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // --- 2. Setup Section (Presets & Input) ---
                    Column {
                        width: parent.width
                        spacing: Theme.spacingM
                        visible: root.isReady

                        StyledText {
                            text: "Select a preset or enter minutes"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Grid {
                            columns: 3
                            spacing: Theme.spacingS
                            horizontalItemAlignment: Grid.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter

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
                            spacing: Theme.spacingS
                            anchors.horizontalCenter: parent.horizontalCenter

                            DankTextField {
                                id: customInput
                                width: 120
                                placeholderText: "Manual mins..."
                                showClearButton: true
                                Component.onCompleted: {
                                    root.manualInputInput = customInput;
                                    if (root.isReady) {
                                        Qt.callLater(() => customInput.forceActiveFocus());
                                    }
                                }
                                onAccepted: {
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
                    }

                    // --- 3. Control Section ---
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

                    // --- 4. Footer Tip ---
                    StyledRect {
                        width: parent.width
                        height: 40
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerLow
                        visible: root.showHints && !root.isReady
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingS
                            DankIcon { name: "info"; size: 16; color: Theme.surfaceText; opacity: 0.6 }
                            StyledText {
                                text: "Right-click bar icon to pause. [Enter] to reset."
                                font.pixelSize: 10
                                color: Theme.surfaceText
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 360
    popoutHeight: root.showHints ? 380 : 340
}
