import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.shared.theme
import "."

ClippingRectangle {
    id: root

    width: Constants.musicPopupWidth
    height: Constants.musicPopupHeight
    implicitHeight: height
    radius: Constants.panelRadius
    color: "transparent"
    contentUnderBorder: true

    property bool open: false

    opacity: entrance.revealProgress
    scale: Constants.popupFromScale + entrance.revealProgress * (1 - Constants.popupFromScale)

    onOpenChanged: {
        if (open)
            entrance.play()
        else
            entrance.reset()
    }

    Component.onCompleted: {
        if (open)
            entrance.play()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    QtObject {
        id: entrance

        property real revealProgress: 0
        property bool ready: false

        function play() {
            reset()
            Qt.callLater(() => {
                if (!root.open)
                    return

                ready = true
                revealProgress = 1
            })
        }

        function reset() {
            ready = false
            revealProgress = 0
        }
    }

    MprisPlaybackSession {
        id: playback
    }

    MusicBackdrop {
        anchors.fill: parent
        artworkSource: playback.artworkSource
        entranceReady: entrance.ready
    }

    ColumnLayout {
        x: Constants.paddingLg
        y: Constants.paddingLg + (1 - entrance.revealProgress) * 10
        width: root.width - Constants.paddingLg * 2
        height: root.height - Constants.paddingLg * 2
        spacing: 0
        opacity: Math.min(1, entrance.revealProgress * 1.25)

        Behavior on opacity {
            NumberAnimation {
                duration: Constants.animationNormal
                easing.type: Easing.OutCubic
            }
        }

        NowPlayingHero {
            Layout.fillWidth: true
            playback: playback
            entranceReady: entrance.ready
            popupOpen: root.open
        }

        Item {
            Layout.preferredHeight: Constants.spacingLg
        }

        TrackProgress {
            Layout.fillWidth: true
            playback: playback
        }

        Item {
            Layout.preferredHeight: Constants.spacingSm
        }

        PlaybackControls {
            Layout.fillWidth: true
            playback: playback
            entranceReady: entrance.ready
        }

        Item {
            Layout.preferredHeight: Constants.spacingXl
        }

        VolumeControl {
            Layout.fillWidth: true
            playback: playback
        }
    }
}
