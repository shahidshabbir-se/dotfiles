import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.shared.theme
import "."

ColumnLayout {
    id: root

    required property var playback
    required property bool entranceReady
    required property bool popupOpen

    spacing: 0

    Text {
        Layout.fillWidth: true
        visible: root.playback.hasCurrentPlayback
        text: "Now Playing"
        horizontalAlignment: Text.AlignHCenter
        color: "#fff8ef"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeLg
        font.weight: Font.DemiBold
        opacity: root.entranceReady ? 1 : 0

        transform: Translate {
            y: root.entranceReady ? 0 : -6

            Behavior on y {
                NumberAnimation {
                    duration: 340
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
    }

    Item {
        Layout.preferredHeight: root.playback.hasCurrentPlayback
            ? Constants.spacingLg
            : 0
    }

    ClippingRectangle {
        id: artworkContainer

        Layout.preferredWidth: Constants.musicArtworkSize
        Layout.preferredHeight: Constants.musicArtworkSize
        Layout.alignment: Qt.AlignHCenter
        radius: width / 2
        color: Colors.surfaceContainerHigh
        opacity: root.entranceReady ? 1 : 0
        scale: root.entranceReady ? 1 : 0.88

        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutBack
                easing.overshoot: 0.6
            }
        }

        Image {
            anchors.fill: parent
            source: root.playback.artworkSource
            sourceSize: Qt.size(
                Constants.musicArtworkSize,
                Constants.musicArtworkSize
            )
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
        }
    }

    RotationAnimator {
        target: artworkContainer
        from: 0
        to: 360
        duration: 18000
        loops: Animation.Infinite
        running: root.popupOpen && root.playback.isPlaying
    }

    Item {
        Layout.preferredHeight: Constants.spacingMd
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: metadataColumn.implicitHeight
        opacity: root.entranceReady ? 1 : 0

        transform: Translate {
            y: root.entranceReady ? 0 : 12

            Behavior on y {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: metadataColumn

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            MarqueeText {
                Layout.fillWidth: true
                active: root.entranceReady
                text: root.playback.title
                color: "#fff8ef"
                font.family: "Doto"
                font.pixelSize: Constants.fontSizeXl
                font.weight: Font.Black
            }

            MarqueeText {
                Layout.fillWidth: true
                active: root.entranceReady
                text: root.playback.artist
                color: "#99fff8ef"
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeMd
            }
        }
    }
}
