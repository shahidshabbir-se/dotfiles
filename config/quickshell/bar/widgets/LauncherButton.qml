import QtQuick
import qs.configuration

Item {
    signal togglePopup()

    width: 18
    height: 18

    Image {
        id: nixIcon
        anchors.fill: parent
        source: "../assets/svg/nix-snowflake-colours.svg"
        sourceSize: Qt.size(36, 36)
        fillMode: Image.PreserveAspectFit
        opacity: hoverHandler.hovered ? 1 : 0.88

        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
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
