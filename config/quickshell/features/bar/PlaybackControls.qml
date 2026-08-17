import QtQuick
import QtQuick.Layouts
import qs.shared.theme

RowLayout {
    id: root

    required property var playback
    required property bool entranceReady

    readonly property int animationDuration: 140

    spacing: Constants.spacingXl
    opacity: entranceReady ? 1 : 0

    transform: Translate {
        y: root.entranceReady ? 0 : 16

        Behavior on y {
            NumberAnimation {
                duration: 460
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 420
            easing.type: Easing.OutCubic
        }
    }

    Item {
        Layout.preferredWidth: 28
        Layout.preferredHeight: Constants.musicPrimaryControlSize
        scale: shufflePointer.pressed
            ? 0.86
            : shufflePointer.containsMouse ? 1.08 : 1

        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ThemeIcon {
            anchors.centerIn: parent
            visible: root.playback.shuffleSupported
            name: "shuffle"
            iconSize: 20
            iconColor: root.playback.shuffleActive
                ? Colors.primary
                : "#fff8ef"
            opacity: root.playback.shuffleActive ? 1 : 0.62

            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration }
            }
        }

        MouseArea {
            id: shufflePointer

            anchors.fill: parent
            enabled: root.playback.canToggleShuffle
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.playback.toggleShuffle()
        }
    }

    Item {
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.preferredWidth: Constants.musicControlSize
        Layout.preferredHeight: Constants.musicControlSize
        radius: width / 2
        scale: previousPointer.pressed
            ? 0.86
            : previousPointer.containsMouse ? 1.06 : 1
        color: previousPointer.containsMouse
            ? Qt.lighter("#1d1c28", 1.12)
            : "#1d1c28"

        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ThemeIcon {
            anchors.centerIn: parent
            name: "skip-back"
            iconSize: 22
            iconColor: "#fff8ef"
        }

        MouseArea {
            id: previousPointer

            anchors.fill: parent
            enabled: root.playback.canGoPrevious
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.playback.goPrevious()
        }
    }

    Rectangle {
        Layout.preferredWidth: Constants.musicPrimaryControlSize
        Layout.preferredHeight: Constants.musicPrimaryControlSize
        radius: width / 2
        scale: playPointer.pressed
            ? 0.88
            : playPointer.containsMouse ? 1.08 : 1
        color: playPointer.containsMouse
            ? Qt.lighter(Colors.primary, 1.08)
            : Colors.primary

        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ThemeIcon {
            anchors.centerIn: parent
            name: root.playback.isPlaying ? "pause" : "play"
            iconSize: 24
            iconColor: Colors.primaryForeground
        }

        MouseArea {
            id: playPointer

            anchors.fill: parent
            enabled: root.playback.canTogglePlaying
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.playback.togglePlaying()
        }
    }

    Rectangle {
        Layout.preferredWidth: Constants.musicControlSize
        Layout.preferredHeight: Constants.musicControlSize
        radius: width / 2
        scale: nextPointer.pressed
            ? 0.86
            : nextPointer.containsMouse ? 1.06 : 1
        color: nextPointer.containsMouse
            ? Qt.lighter("#1d1c28", 1.12)
            : "#1d1c28"

        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ThemeIcon {
            anchors.centerIn: parent
            name: "skip-forward"
            iconSize: 22
            iconColor: "#fff8ef"
        }

        MouseArea {
            id: nextPointer

            anchors.fill: parent
            enabled: root.playback.canGoNext
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.playback.goNext()
        }
    }

    Item {
        Layout.fillWidth: true
    }

    Item {
        Layout.preferredWidth: 28
        Layout.preferredHeight: Constants.musicPrimaryControlSize
        scale: repeatPointer.pressed
            ? 0.86
            : repeatPointer.containsMouse ? 1.08 : 1

        Behavior on scale {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        ThemeIcon {
            anchors.centerIn: parent
            visible: root.playback.loopSupported
            name: "repeat"
            iconSize: 20
            iconColor: root.playback.loopActive
                ? Colors.primary
                : "#fff8ef"
            opacity: root.playback.loopActive ? 1 : 0.62

            Behavior on opacity {
                NumberAnimation { duration: root.animationDuration }
            }
        }

        MouseArea {
            id: repeatPointer

            anchors.fill: parent
            enabled: root.playback.canToggleLoop
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.playback.toggleLoop()
        }
    }
}
