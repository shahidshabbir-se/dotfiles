import QtQuick
import Quickshell.Bluetooth
import qs.shared.theme

Item {
    id: root

    property bool active: false
    signal clicked

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter && adapter.enabled
    readonly property bool hasConnection: {
        const values = Bluetooth.devices ? Bluetooth.devices.values : []
        for (let i = 0; i < values.length; i++) {
            if (values[i] && values[i].connected)
                return true
        }
        return false
    }

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.active
            ? Tokens.withAlpha(Colors.primary, 0.14)
            : pointer.containsMouse
                ? Colors.surfaceContainerHighest
                : "transparent"
        scale: pointer.pressed ? 0.94 : 1
        opacity: root.powered ? 1 : 0.55

        ThemeIcon {
            anchors.centerIn: parent
            name: "bluetooth"
            iconSize: Constants.iconSizeLg + 2
        }

        MouseArea {
            id: pointer

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }
}
