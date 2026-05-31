import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Row {
    id: root

    required property string settingKey
    required property string label
    property string description: ""
    property color defaultValue: Theme.primary
    property color value: defaultValue

    width: parent.width
    height: 36
    spacing: Theme.spacingM

    property bool isInitialized: false
    readonly property bool isDirty: value.toString() !== defaultValue.toString()

    function resetToDefault() {
        value = defaultValue;
    }

    function loadValue() {
        const settings = findSettings();
        if (settings && settings.pluginService) {
            const loadedValue = settings.loadValue(settingKey, defaultValue);
            value = loadedValue;
            isInitialized = true;
        }
    }

    Component.onCompleted: {
        Qt.callLater(loadValue);
    }

    onValueChanged: {
        if (!isInitialized)
            return;
        const settings = findSettings();
        if (settings) {
            settings.saveValue(settingKey, value);
        }
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
        width: parent.width - colorPreview.width - parent.spacing
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

    Rectangle {
        id: colorPreview
        width: 80
        height: 28 // Giảm một chút cho cân đối
        radius: Theme.cornerRadius
        color: root.value
        border.color: Theme.outlineStrong
        border.width: 2
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (PopoutService && PopoutService.colorPickerModal) {
                    PopoutService.colorPickerModal.selectedColor = root.value;
                    PopoutService.colorPickerModal.pickerTitle = root.label;
                    PopoutService.colorPickerModal.onColorSelectedCallback = function (selectedColor) {
                        root.value = selectedColor;
                    };
                    PopoutService.colorPickerModal.show();
                }
            }
        }
    }
}
