pragma ComponentBehavior: Bound

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
        implicitHeight: 28

        property bool seeking: false
        property real seekProgress: root.playback.progress

        readonly property real displayProgress: seeking
            ? seekProgress
            : root.playback.progress
        readonly property bool interactive: root.playback.canSeek

        function progressAt(xPosition) {
            return Math.max(0, Math.min(1, xPosition / width))
        }

        function updateSeek(xPosition) {
            seekProgress = progressAt(xPosition)
        }

        // Animated wave phase for continuous fluid ripple when playing
        property real wavePhase: 0

        NumberAnimation on wavePhase {
            from: 0
            to: Math.PI * 2
            duration: 2200
            loops: Animation.Infinite
            running: root.playback.isPlaying
        }

        // Wave soundbars / vinyl grooves container
        Row {
            id: waveBars
            anchors.fill: parent
            spacing: 2

            readonly property int barCount: Math.max(1, Math.floor((width + spacing) / (2.5 + spacing)))
            readonly property real barW: Math.max(2, (width - (barCount - 1) * spacing) / barCount)

            Repeater {
                model: waveBars.barCount

                Rectangle {
                    id: bar
                    required property int index

                    readonly property real frac: (index + 0.5) / waveBars.barCount
                    readonly property bool isPassed: frac <= slider.displayProgress

                    // Vinyl soundwave profile: undulating wave pattern across track
                    readonly property real wave1: Math.sin(frac * Math.PI * 7.5 + slider.wavePhase)
                    readonly property real wave2: Math.cos(frac * Math.PI * 13.0 - slider.wavePhase * 0.8)
                    readonly property real envelope: 0.35 + 0.65 * Math.sin(frac * Math.PI)
                    readonly property real waveHeightNorm: 0.22 + 0.78 * Math.abs(wave1 * 0.65 + wave2 * 0.35) * envelope

                    width: waveBars.barW
                    height: Math.max(4, slider.height * waveHeightNorm)
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter

                    color: isPassed
                        ? Colors.primary
                        : Tokens.withAlpha(Colors.surfaceForeground, 0.22)

                    opacity: isPassed ? 1.0 : 0.65

                    Behavior on color {
                        ColorAnimation { duration: 160 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 160 }
                    }
                }
            }
        }

        // Playhead handle / stylus indicator
        Rectangle {
            id: playhead
            x: Math.max(0, Math.min(slider.width - width, slider.width * slider.displayProgress - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: 14
            height: 14
            radius: width / 2
            color: Colors.primary
            scale: pointer.pressed ? 1.25 : 1.0
            border.width: 2
            border.color: Colors.surfaceContainerLow

            // Stylus center dot
            Rectangle {
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: Colors.primaryForeground
            }

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
