import "../dms-common"
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

PluginComponent {
    id: root

    readonly property var presets: {
        const raw = pluginData.presets || "1, 2, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120";
        return raw.split(',').map((s) => {
            return parseInt(s.trim());
        }).filter((n) => {
            return !isNaN(n);
        });
    }
    readonly property string soundPath: pluginData.soundPath || ""
    readonly property bool useSystemNotificationSound: pluginData.useSystemNotificationSound ?? true
    readonly property bool showNotification: pluginData.showNotification ?? true
    readonly property string notificationTitle: pluginData.notificationTitle || "Timer"
    readonly property int buttonHeight: Theme.iconSizeLarge + Theme.spacingS
    readonly property int padding: Theme.spacingS
    readonly property int spacing: Theme.spacingS
    readonly property int fontSize: Theme.fontSizeMedium
    readonly property string notificationBody: pluginData.notificationBody || "Timeout!"
    readonly property string timeoutBehavior: pluginData.timeoutBehavior || "stay"
    readonly property string displayFormat: pluginData.displayFormat || "full"
    readonly property bool showHints: pluginData.showHints ?? true
    readonly property bool isFinished: globalRemainingSeconds.value === 0 && globalTotalSeconds.value > 0
    readonly property bool isPaused: !globalIsRunning.value && globalRemainingSeconds.value > 0 && globalRemainingSeconds.value < globalTotalSeconds.value
    readonly property bool isReady: globalRemainingSeconds.value === 0 && globalTotalSeconds.value === 0
    readonly property color pillColor: {
        if (globalIsRunning.value)
            return Theme.primary;

        if (isPaused || isFinished)
            return Theme.warning;

        return Theme.surfaceText;
    }
    readonly property int quickStartMinutes: {
        const val = parseInt(pluginData.quickStartMinutes);
        return (!isNaN(val) && val > 0) ? val : 25;
    }
    property var activePopoutReference: null
    property var manualInputInput: null

    function formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600);
        const minutes = Math.floor((totalSeconds % 3600) / 60);
        const seconds = totalSeconds % 60;
        if (root.displayFormat === "minimal") {
            if (hours > 0)
                return hours + "h " + minutes + "m";

            if (minutes > 0)
                return minutes + "m " + seconds + "s";

            return seconds + "s";
        }
        if (root.displayFormat === "compact") {
            let res = "";
            if (hours > 0)
                res += hours + "h ";

            if (minutes > 0 || hours > 0)
                res += minutes + "m ";

            res += seconds + "s";
            return res.trim();
        }
        // Default: Full format (00:00:00)
        let result = "";
        if (hours > 0)
            result += hours.toString().padStart(2, '0') + ":";

        result += minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0');
        return result;
    }

    function setTimer(minutes) {
        const seconds = minutes * 60;
        globalTotalSeconds.set(seconds);
        globalRemainingSeconds.set(seconds);
        globalIsRunning.set(true);
        root.closePopout();
    }

    function toggleTimer() {
        if (globalRemainingSeconds.value <= 0)
            return ;

        globalIsRunning.set(!globalIsRunning.value);
    }

    function resetTimer() {
        globalIsRunning.set(false);
        globalRemainingSeconds.set(0);
        globalTotalSeconds.set(0);
    }

    function isValidInput(text) {
        if (text === "")
            return false;

        if (!/^\d+$/.test(text))
            return false;

        const num = parseInt(text, 10);
        return num >= 1 && num <= 999;
    }

    pillClickAction: root.isReady ? null : () => {
        root.toggleTimer();
    }
    pillRightClickAction: () => {
        if (root.isReady)
            root.setTimer(root.quickStartMinutes);
        else
            root.resetTimer();
    }
    popoutWidth: 360
    popoutHeight: {
        const baseHeight = root.showHints ? 240 : 200;
        const presetRows = Math.ceil(root.presets.length / 4);
        const extraRows = Math.max(0, presetRows - 3);
        return baseHeight + (extraRows * 42);
    }

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

    Timer {
        id: timer

        interval: 1000
        repeat: true
        running: globalIsRunning.value && globalRemainingSeconds.value > 0
        onTriggered: {
            const newVal = globalRemainingSeconds.value - 1;
            globalRemainingSeconds.set(newVal);
            if (newVal === 0) {
                globalIsRunning.set(false);
                if (root.showNotification)
                    Proc.runCommand("timer-notify", ["notify-send", "-i", "appointment-soon", "-u", "normal", root.notificationTitle, root.notificationBody], null, 0);

                if (root.soundPath !== "")
                    Proc.runCommand("timer-sound", ["paplay", "--property=media.role=event", root.soundPath], null, 0);
                else if (root.useSystemNotificationSound && AudioService.soundsAvailable)
                    AudioService.playCriticalNotificationSound();
                else
                    Proc.runCommand("timer-sound", ["paplay", "--property=media.role=event", "/usr/share/sounds/freedesktop/stereo/complete.oga"], null, 0);
                if (root.timeoutBehavior === "reset")
                    root.resetTimer();

            }
        }
    }

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

    popoutContent: Component {
        PopoutComponent {
            id: mainContent

            property var parentPopout: null

            width: parent ? parent.width : 0
            headerText: "Timer"
            showCloseButton: true
            focus: true
            onParentPopoutChanged: root.activePopoutReference = parentPopout

            PluginShortcut {
                parentPopout: mainContent.parentPopout
                onOpened: () => {
                    if (root.isReady && root.manualInputInput)
                        root.manualInputInput.forceActiveFocus();
                    else
                        mainColumn.forceActiveFocus();
                }
            }

            Column {
                id: mainColumn

                width: parent.width
                spacing: Theme.spacingL

                Column {
                    width: parent.width
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Select a preset or enter minutes"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Flow {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: root.presets

                            delegate: Rectangle {
                                width: (parent.width - 18) / 4
                                height: 36
                                radius: Theme.cornerRadius
                                color: Theme.primary

                                StyledText {
                                    text: modelData >= 60 ? (modelData / 60) + "h" : modelData + "m"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: Theme.onPrimary
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: setTimer(modelData)
                                    onPressed: parent.opacity = 0.7
                                    onReleased: parent.opacity = 1
                                }

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
                                if (root.isReady)
                                    Qt.callLater(() => {
                                    return customInput.forceActiveFocus();
                                });

                            }
                            onAccepted: {
                                if (isValidInput(text)) {
                                    setTimer(parseInt(text));
                                    text = "";
                                }
                            }
                        }

                        DankButton {
                            text: "Set"
                            backgroundColor: Theme.primary
                            textColor: Theme.onPrimary
                            enabled: isValidInput(customInput.text)
                            onClicked: {
                                setTimer(parseInt(customInput.text));
                                customInput.text = "";
                            }
                        }

                    }

                }

                HintSection {
                    width: parent.width
                    showHints: root.showHints

                    HintItem {
                        icon: "info"
                        text: "Left-click to Pause/Resume, Right-click to Reset (Quick Start when ready)."
                    }

                }

            }

        }

    }

}
