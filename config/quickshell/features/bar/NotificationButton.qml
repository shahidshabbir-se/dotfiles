import QtQuick
import qs.shared.theme

Item {
    id: root

    property int count: 0
    property bool active: false
    property bool doNotDisturb: false

    signal clicked()

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.active
            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.14)
            : pointer.containsMouse
                ? Colors.surfaceContainerHighest
                : "transparent"
        scale: pointer.pressed ? 0.94 : 1

        ThemeIcon {
            id: bellIcon

            anchors.centerIn: parent
            name: "bell"
            iconSize: Constants.iconSizeLg
            iconColor: root.count > 0 || root.active
                ? Colors.primary
                : Colors.surfaceForeground
            opacity: root.doNotDisturb ? 0.55 : 1

            Behavior on opacity {
                NumberAnimation { duration: Constants.animationFast }
            }
        }

        Rectangle {
            visible: root.doNotDisturb
            anchors.centerIn: parent
            width: Constants.iconSizeLg + 2
            height: 1.5
            radius: 1
            rotation: -45
            color: Colors.primary
            antialiasing: true
        }

        Rectangle {
            visible: root.count > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: root.count === 1 ? 1 : -2
            anchors.rightMargin: root.count === 1 ? 1 : -3
            width: root.count === 1 ? 7 : Math.max(13, countLabel.implicitWidth + 6)
            height: root.count === 1 ? 7 : 13
            radius: height / 2
            color: Colors.primary

            Text {
                id: countLabel

                anchors.centerIn: parent
                visible: root.count > 1
                text: root.count > 9 ? "9+" : root.count
                color: Colors.primaryForeground
                font.family: Constants.fontFamily
                font.pixelSize: 9
                font.weight: Font.DemiBold
                textFormat: Text.PlainText
            }
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
