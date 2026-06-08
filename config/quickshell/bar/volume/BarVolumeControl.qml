import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.configuration

Rectangle {
    id: root

    width: 28
    height: 78
    radius: 2
    color: hoverHandler.hovered ? Colors.volumeBackgroundHover : Colors.moduleBackground
    border.width: 1
    border.color: hoverHandler.hovered ? Colors.volumeBorderHover : Colors.moduleBorder

    HoverHandler { id: hoverHandler }

    Behavior on border.color {
        ColorAnimation { duration: 400 }
    }

    readonly property PwNode sink: Pipewire.defaultAudioSink

    property bool muted: sink?.audio?.muted ?? false
    property real volume: sink?.audio?.volume ?? 0
    property real lastVolume: 0
    property bool volumeDragging: false

    function setVolumeFromBarY(barY) {
        if (!sink?.audio)
            return

        if (muted)
            sink.audio.muted = false
        sink.audio.volume = Math.max(0, Math.min(1.5, 1 - (barY / volumeBar.height)))
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    SequentialAnimation {
        id: bounceAnimation

        PropertyAnimation {
            target: volumeBar
            property: "anchors.bottomMargin"
            to: -8
            duration: 120
            easing.type: Easing.OutBack
        }
        PropertyAnimation {
            target: volumeBar
            property: "anchors.bottomMargin"
            to: 10
            duration: 180
            easing.type: Easing.InOutBounce
        }
        PropertyAnimation {
            target: volumeBar
            property: "anchors.bottomMargin"
            to: -4
            duration: 140
            easing.type: Easing.OutBounce
        }
        PropertyAnimation {
            target: volumeBar
            property: "anchors.bottomMargin"
            to: 6
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: volumeBar
            property: "anchors.bottomMargin"
            to: 0
            duration: 160
            easing.type: Easing.OutElastic
        }
    }

    onVolumeChanged: {
        if (Math.abs(volume - lastVolume) > 0.01) {
            bounceAnimation.start()
            lastVolume = volume
        }
    }

    ColumnLayout {
        z: 1
        anchors.centerIn: parent
        spacing: 6

        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 14
            height: 14

            SpeakerIcon {
                anchors.fill: parent
                muted: root.muted
                volume: root.volume
            }
        }

        Rectangle {
            id: volumeBar
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4
            width: 8
            height: 46
            color: Colors.volumeBarBackground
            radius: 1
            clip: true

            VolumeBarFill {
                anchors.fill: parent
                volume: root.volume
                muted: root.muted
                vertical: true
                cornerRadius: 1
            }

            MouseArea {
                id: volumeHitArea
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor

                onPressed: mouse => {
                    mouse.accepted = true
                    root.volumeDragging = true
                    root.setVolumeFromBarY(mouse.y + volumeHitArea.y)
                }

                onPositionChanged: mouse => {
                    if (root.volumeDragging)
                        root.setVolumeFromBarY(mouse.y + volumeHitArea.y)
                }

                onReleased: mouse => {
                    mouse.accepted = true
                    root.setVolumeFromBarY(mouse.y + volumeHitArea.y)
                    root.volumeDragging = false
                }

                onCanceled: root.volumeDragging = false
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (sink?.audio)
                sink.audio.muted = !root.muted
        }

        onWheel: wheel => {
            if (!sink?.audio || root.muted)
                return

            const delta = wheel.angleDelta.y > 0 ? 0.1 : -0.1
            sink.audio.volume = Math.max(0, Math.min(1.5, root.volume + delta))
        }
    }
}
