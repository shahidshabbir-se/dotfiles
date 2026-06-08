import QtQuick
import Qt5Compat.GraphicalEffects
import qs.configuration

Item {
    signal togglePopup()

    property int unreadCount: 0

    width: 16
    height: 16

    Image {
        id: bellIcon
        anchors.fill: parent
        source: "../assets/svg/bell.svg"
        sourceSize: Qt.size(32, 32)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: bellIcon
        source: bellIcon
        color: Colors.textSecondary
        opacity: hoverHandler.hovered ? 1 : 0.75
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -4
        anchors.rightMargin: -5
        width: Math.max(countLabel.implicitWidth + 6, 14)
        height: 14
        radius: 7
        visible: unreadCount > 0
        color: Colors.notificationBadgeBg

        Text {
            id: countLabel
            anchors.centerIn: parent
            text: unreadCount > 9 ? "9+" : unreadCount
            font.family: "Cartograph CF"
            font.pixelSize: 8
            font.weight: Font.Bold
            color: Colors.notificationBadgeText
        }
    }

    HoverHandler { id: hoverHandler }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: togglePopup()
    }
}
