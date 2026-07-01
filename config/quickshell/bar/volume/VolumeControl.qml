import QtQuick
import Quickshell.Services.Pipewire
import qs.configuration

Item {
    signal togglePopup()

    readonly property PwNode sink: Pipewire.defaultAudioSink
    property bool muted: sink?.audio?.muted ?? false
    property real volume: sink?.audio?.volume ?? 0

    width: 18
    height: 18

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    SpeakerIcon {
        anchors.fill: parent
        muted: root.muted
        volume: root.volume
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        cursorShape: Qt.PointingHandCursor

        onClicked: togglePopup()

        onWheel: wheel => {
            if (!sink?.audio || muted)
                return

            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            sink.audio.volume = Math.max(0, Math.min(1.5, volume + delta))
        }
    }
}
