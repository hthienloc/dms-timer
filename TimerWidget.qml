import QtQuick
import QtQuick.Controls
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
                // Reset immediately and show popout
                globalRemainingSeconds.set(0)
                globalTotalSeconds.set(0)
                pluginPopout.open()
            }
        }
    }

    function formatTime(totalSeconds) {
        const hours = Math.floor(totalSeconds / 3600)
        const minutes = Math.floor((totalSeconds % 3600) / 60)
        const seconds = totalSeconds % 60

        let result = ""

        if (hours > 0) {
            result += hours.toString().padStart(2, '0') + ":"
        }

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

    function isValidInput(text) {
        if (text === "") return false
        if (!/^\d+$/.test(text)) return false
        const num = parseInt(text, 10)
        return num >= 1 && num <= 999
    }

    pillRightClickAction: () => {
        toggleTimer()
    }

    horizontalBarPill: Component {
        Row {
            id: content
            spacing: Theme.spacingS

            DankIcon {
                name: globalIsRunning.value ? "pause" : (globalRemainingSeconds.value > 0 ? "play_arrow" : "timer")
                size: Theme.iconSizeSmall
                color: globalIsRunning.value ? Theme.primary : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : Theme.surfaceText)
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                color: globalIsRunning.value ? Theme.primary : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : Theme.surfaceText)
                font.pixelSize: Theme.fontSizeMedium
                isMonospace: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            id: content
            spacing: Theme.spacingS

            DankIcon {
                name: globalIsRunning.value ? "pause" : (globalRemainingSeconds.value > 0 ? "play_arrow" : "timer")
                size: Theme.iconSizeSmall
                color: globalIsRunning.value ? Theme.primary : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : Theme.surfaceText)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                color: globalIsRunning.value ? Theme.primary : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : Theme.surfaceText)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                color: globalIsRunning.value ? Theme.primary : Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
                isMonospace: true
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: 90
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Timer"
            detailsText: globalIsRunning.value ? "Running..." :
                        globalRemainingSeconds.value === 0 && globalTotalSeconds.value > 0 ? "Finished!" : "Ready"
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingL

            StyledText {
                text: formatTime(globalRemainingSeconds.value)
                font.pixelSize: 48
                isMonospace: true
                font.weight: Font.Bold
                color: globalIsRunning.value ? Theme.primary : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : (globalRemainingSeconds.value === 0 && globalTotalSeconds.value > 0 ? Theme.error : Theme.surfaceText))
                anchors.horizontalCenter: parent.horizontalCenter
            }

                Grid {
                    columns: 3
                    spacing: Theme.spacingS
                    horizontalItemAlignment: Grid.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: !globalIsRunning.value && globalRemainingSeconds.value === 0

                    Repeater {
                        model: [5, 10, 15, 20, 25, 30, 45, 60, 120]
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
                    anchors.horizontalCenter: parent.horizontalCenter;

                    DankButton {
                        text: globalIsRunning.value ? "Pause" : (globalRemainingSeconds.value < globalTotalSeconds.value ? "Resume" : "Start")
                        iconName: globalIsRunning.value ? "pause" : "play_arrow"
                        backgroundColor: globalIsRunning.value ? Theme.error : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.warning : Theme.primary)
                        textColor: globalIsRunning.value ? Theme.onError : (globalRemainingSeconds.value < globalTotalSeconds.value ? Theme.onSurface : Theme.onPrimary)
                        enabled: globalRemainingSeconds.value > 0
                        onClicked: toggleTimer()
                    }

                    DankButton {
                        text: "Test Popout"
                        onClicked: pluginPopout.open()
                    }

                    DankButton {
                        text: "Reset"
                        iconName: "refresh"
                        backgroundColor: Theme.surfaceContainerHigh
                        textColor: Theme.surfaceText
                        onClicked: {
                            globalIsRunning.set(false)
                            globalRemainingSeconds.set(0)
                            globalTotalSeconds.set(0)
                        }
                    }
                }

                    DankButton {
                        text: "Reset"
                        iconName: "refresh"
                        backgroundColor: Theme.surfaceContainerHigh
                        textColor: Theme.surfaceText
                        onClicked: {
                            globalIsRunning.set(false)
                            globalRemainingSeconds.set(0)
                            globalTotalSeconds.set(0)
                        }
                    }
                }

                Row {
                    spacing: Theme.spacingS
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: !globalIsRunning.value && globalRemainingSeconds.value === 0

                    StyledText {
                        text: "Custom (minutes):"
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: customInput
                        width: 80
                        color: Theme.surfaceText
                        background: Rectangle {
                            radius: Theme.cornerRadiusSmall
                            color: Theme.surfaceContainer
                            border.color: Theme.outline
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
        }
    }
    popoutWidth: 400
    popoutHeight: 350
}
