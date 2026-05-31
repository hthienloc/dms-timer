import QtQuick
import qs.Common
import qs.Widgets

Row {
    id: root

    required property string settingKey
    required property string label
    property string description: ""
    required property var options
    property string defaultValue: ""
    property string value: defaultValue

    width: parent.width
    height: 36
    spacing: Theme.spacingM

    readonly property bool isDirty: String(value) !== String(defaultValue)

    function resetToDefault() {
        console.log(`[SelectionSettingPlus] Resetting ${settingKey} to ${defaultValue}`);
        value = defaultValue;
        // Force dropdown update
        dropdown.currentValue = root.valueToLabel[defaultValue] || defaultValue;
    }

    function loadValue() {
        const settings = findSettings()
        if (settings && settings.pluginService) {
            value = settings.loadValue(settingKey, defaultValue)
        }
    }

    Component.onCompleted: {
        loadValue()
    }

    readonly property var optionLabels: {
        const labels = []
        for (let i = 0; i < options.length; i++) {
            labels.push(options[i].label || options[i])
        }
        return labels
    }

    readonly property var valueToLabel: {
        const map = {}
        for (let i = 0; i < options.length; i++) {
            const opt = options[i]
            if (typeof opt === 'object') {
                map[opt.value] = opt.label
            } else {
                map[opt] = opt
            }
        }
        return map
    }

    readonly property var labelToValue: {
        const map = {}
        for (let i = 0; i < options.length; i++) {
            const opt = options[i]
            if (typeof opt === 'object') {
                map[opt.label] = opt.value
            } else {
                map[opt] = opt
            }
        }
        return map
    }

    onValueChanged: {
        const settings = findSettings()
        if (settings) {
            settings.saveValue(settingKey, value)
        }
    }

    function findSettings() {
        let item = parent
        while (item) {
            if (item.saveValue !== undefined && item.loadValue !== undefined) {
                return item
            }
            item = item.parent
        }
        return null
    }

    Column {
        width: parent.width - dropdown.width - parent.spacing
        spacing: Theme.spacingXS
        anchors.verticalCenter: parent.verticalCenter

        Row {
            spacing: Theme.spacingXS
            width: parent.width

            StyledText {
                text: root.label
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Medium
                color: Theme.surfaceText
                elide: Text.ElideRight
                maximumLineCount: 1
                width: Math.min(implicitWidth, parent.width - (infoIcon.visible ? infoIcon.width + parent.spacing : 0))
            }

            DankIcon {
                id: infoIcon
                name: "info"
                size: 16
                color: Theme.primary
                visible: root.description !== ""
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.6

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: sharedTooltip.show(root.description, infoIcon)
                    onExited: sharedTooltip.hide()
                }
            }
        }
    }

    DankTooltipV2 {
        id: sharedTooltip
    }

    DankDropdown {
        id: dropdown
        dropdownWidth: 160
        height: 32 // Nhỏ hơn container 36px một chút
        compactMode: true
        anchors.verticalCenter: parent.verticalCenter
        currentValue: root.valueToLabel[root.value] || root.value
        options: root.optionLabels
        onValueChanged: newValue => {
            root.value = root.labelToValue[newValue] || newValue
        }
    }
}
