import QtQuick
import Quickshell
import qs.configuration

Item {
    id: root

    signal togglePopup()

    implicitWidth: timeLabel.implicitWidth
    implicitHeight: timeLabel.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: timeLabel
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        font.family: "Cartograph CF"
        font.pixelSize: 14
        color: Colors.textPrimary
        opacity: hoverHandler.hovered ? 1 : 0.85
    }

    HoverHandler { id: hoverHandler }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        cursorShape: Qt.PointingHandCursor
        onClicked: root.togglePopup()
    }
}
