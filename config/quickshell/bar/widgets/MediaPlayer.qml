import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.configuration

Item {
    signal togglePopup()

    readonly property var player: {
        return Mpris.players.values.find(p => p.isPlaying)
            ?? Mpris.players.values[0]
            ?? null
    }
    readonly property bool playing: player?.isPlaying ?? false

    visible: playing
    width: 16
    height: 16
    opacity: 1

    Image {
        id: musicIcon
        anchors.fill: parent
        source: "../assets/svg/music.svg"
        sourceSize: Qt.size(32, 32)
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: musicIcon
        source: musicIcon
        color: Colors.textSecondary
        opacity: hoverHandler.hovered ? 1 : 0.75
    }

    HoverHandler { id: hoverHandler }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: togglePopup()
    }
}
