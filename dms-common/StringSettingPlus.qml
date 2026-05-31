import QtQuick
import qs.Common
import qs.Widgets

Column {
    id: root

    required property string settingKey
    required property string label
    property string description: ""
    property string placeholder: ""
    property string defaultValue: ""
    property string value: defaultValue

    width: parent.width
    spacing: Theme.spacingS

    property bool isInitialized: false
    readonly property bool isDirty: value !== defaultValue

    function resetToDefault() {
        value = defaultValue;
        textField.text = defaultValue;
    }

    function loadValue() {
        const settings = findSettings();
        if (settings && settings.pluginService) {
            const loadedValue = settings.loadValue(settingKey, defaultValue);
            if (textField.activeFocus && isInitialized)
                return;
            value = loadedValue;
            textField.text = loadedValue;
            isInitialized = true;
        }
    }

    Component.onCompleted: {
        Qt.callLater(loadValue);
    }

    function commit() {
        if (!isInitialized)
            return;
        if (textField.text === value)
            return;
        value = textField.text;
        const settings = findSettings();
        if (settings)
            settings.saveValue(settingKey, value);
    }

    function findSettings() {
        let item = parent;
        while (item) {
            if (item.saveValue !== undefined && item.loadValue !== undefined) {
                return item;
            }
            item = item.parent;
        }
        return null;
    }

    Column {
        width: parent.width
        spacing: Theme.spacingXS

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

    DankTextField {
        id: textField
        width: parent.width
        placeholderText: root.placeholder
        onEditingFinished: root.commit()
        onActiveFocusChanged: {
            if (!activeFocus)
                root.commit();
        }
    }
}
