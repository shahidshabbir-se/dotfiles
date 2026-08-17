import QtQuick
import QtQuick.Layouts
import qs.shared.theme

ColumnLayout {
    id: root

    required property var playback

    spacing: Constants.spacingXs

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            seconds = 0

        const total = Math.floor(seconds)
        const minutes = Math.floor(total / 60)
        const remainder = total % 60

        return minutes + ":" + (remainder < 10 ? "0" : "") + remainder
    }

    Item {
        id: slider

        Layout.fillWidth: true
        implicitHeight: 18

        property bool seeking: false
        property real seekProgress: root.playback.progress

        readonly property real displayProgress: seeking
            ? seekProgress
            : root.playback.progress
        readonly property bool interactive: root.playback.canSeek

        function progressAt(xPosition) {
            return Math.max(
                0,
                Math.min(1, (xPosition - track.x) / track.width)
            )
        }

        function updateSeek(xPosition) {
            seekProgress = progressAt(xPosition)
        }

        Rectangle {
            id: track

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 2
            radius: height / 2
            color: "#35ffffff"

            Rectangle {
                width: parent.width * slider.displayProgress
                height: parent.height
                radius: parent.radius
                color: Colors.primary

                Behavior on width {
                    enabled: !slider.seeking

                    NumberAnimation {
                        duration: 450
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        Rectangle {
            x: track.x + track.width * slider.displayProgress - width / 2
            anchors.verticalCenter: track.verticalCenter
            width: 12
            height: 12
            radius: width / 2
            color: Colors.primary
            scale: pointer.pressed ? 1.18 : 1

            Behavior on x {
                enabled: !slider.seeking

                NumberAnimation {
                    duration: 450
                    easing.type: Easing.Linear
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: pointer

            anchors.fill: parent
            enabled: slider.interactive
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onPressed: mouse => {
                slider.seeking = true
                slider.updateSeek(mouse.x)
            }

            onPositionChanged: mouse => {
                if (pressed)
                    slider.updateSeek(mouse.x)
            }

            onReleased: mouse => {
                slider.updateSeek(mouse.x)
                root.playback.seekTo(slider.seekProgress)
                slider.seeking = false
            }

            onCanceled: slider.seeking = false
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: root.formatTime(
                slider.seeking
                    ? slider.seekProgress * root.playback.durationSeconds
                    : root.playback.positionSeconds
            )
            color: "#b8fff8ef"
            font.family: Constants.fontFamily
            font.pixelSize: 10
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: "-" + root.formatTime(
                Math.max(
                    0,
                    root.playback.durationSeconds - (
                        slider.seeking
                            ? slider.seekProgress * root.playback.durationSeconds
                            : root.playback.positionSeconds
                    )
                )
            )
            color: "#b8fff8ef"
            font.family: Constants.fontFamily
            font.pixelSize: 10
        }
    }
}
