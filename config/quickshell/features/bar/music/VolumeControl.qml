import QtQuick
import QtQuick.Layouts
import qs.shared.theme

RowLayout {
    id: root

    required property var playback

    spacing: Constants.spacingLg

    ThemeIcon {
        name: "volume"
        iconSize: Constants.iconSizeLg
        iconColor: Colors.primary
    }

    Item {
        id: slider

        Layout.fillWidth: true
        implicitHeight: 18

        property bool adjusting: false
        property real pendingVolume: root.playback.volume

        readonly property real displayVolume: adjusting
            ? pendingVolume
            : root.playback.volume
        readonly property bool interactive: root.playback.canSetVolume

        function volumeAt(xPosition) {
            return Math.max(0, Math.min(1, xPosition / width))
        }

        function updateVolume(xPosition) {
            pendingVolume = volumeAt(xPosition)
            root.playback.setVolume(pendingVolume)
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
                width: parent.width * slider.displayVolume
                height: parent.height
                radius: parent.radius
                color: Colors.primary

                Behavior on width {
                    enabled: !slider.adjusting

                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Rectangle {
            x: track.x + track.width * slider.displayVolume - width / 2
            anchors.verticalCenter: track.verticalCenter
            width: 12
            height: 12
            radius: width / 2
            color: Colors.primary
            scale: pointer.pressed ? 1.18 : 1

            Behavior on x {
                enabled: !slider.adjusting

                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
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
                slider.adjusting = true
                slider.updateVolume(mouse.x)
            }

            onPositionChanged: mouse => {
                if (pressed)
                    slider.updateVolume(mouse.x)
            }

            onReleased: mouse => {
                slider.updateVolume(mouse.x)
                slider.adjusting = false
            }

            onCanceled: slider.adjusting = false
        }
    }
}
