import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared.theme

Item {
    id: root

    property bool active: false
    property bool online: false

    signal clicked

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.active
            ? Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.14)
            : pointer.containsMouse
                ? Colors.surfaceContainerHighest
                : "transparent"
        scale: pointer.pressed ? 0.94 : 1

        ThemeIcon {
            anchors.centerIn: parent
            name: "wifi"
            iconSize: Constants.iconSizeLg
        }

        MouseArea {
            id: pointer

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: Constants.animationFast }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Constants.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }

    readonly property string backend: {
        const rootDir = Quickshell.shellDir || ""
        if (rootDir.length > 0)
            return rootDir + "/features/bar/scripts/qs-network-bin"
        return Qt.resolvedUrl("scripts/qs-network-bin")
            .toString().replace(/^file:\/\//, "")
    }

    // Lightweight online probe via rust backend
    Process {
        id: onlineProc
        command: [root.backend, "status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const s = JSON.parse(text || "{}")
                    root.online = s.kind === "wifi" || s.kind === "ethernet"
                } catch (e) {
                    root.online = false
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (onlineProc.running)
                onlineProc.running = false
            Qt.callLater(() => { onlineProc.running = true })
        }
    }
}
