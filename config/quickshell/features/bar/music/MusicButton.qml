import QtQuick
import qs.shared.theme

Item {
    id: root

    signal clicked

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: mouseArea.containsMouse
            ? Colors.surfaceContainerHighest
            : "transparent"

        ThemeIcon {
            anchors.centerIn: parent
            name: "music"
            iconSize: Constants.iconSizeLg
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }
    }
}
