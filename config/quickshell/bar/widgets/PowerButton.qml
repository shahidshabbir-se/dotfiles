import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import qs.configuration

Item {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") ?? ""
    readonly property string wlogoutScript: homeDir.length > 0
        ? homeDir + "/.config/wlogout/launch.sh"
        : ""

    width: 14
    height: 13

    Image {
        id: powerIcon
        anchors.fill: parent
        source: "../assets/svg/power.svg"
        sourceSize: Qt.size(26, 26)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: powerIcon
        source: powerIcon
        color: hoverHandler.hovered ? Colors.powerIconHover : Colors.powerIcon
        opacity: hoverHandler.hovered ? 1 : 0.75

        Behavior on color {
            ColorAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
    }

    HoverHandler { id: hoverHandler }

    Process {
        id: wlogoutProcess
        running: false
        command: ["sh", root.wlogoutScript]
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.wlogoutScript.length > 0)
                wlogoutProcess.running = true
        }
    }
}
