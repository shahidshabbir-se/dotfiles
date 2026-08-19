import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared.theme

Item {
    id: root

    property bool active: false
    property bool online: false
    property string kind: "disconnected"
    property int signal: -1
    property bool wifiEnabled: true

    signal clicked

    implicitWidth: Constants.buttonSize
    implicitHeight: Constants.buttonSize

    readonly property string glyph: {
        if (kind === "ethernet")
            return "󰈀"
        if (kind === "wifi") {
            const s = Math.max(0, Math.min(100, Number(signal) || 0))
            const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
            const index = Math.max(0, Math.min(4, Math.ceil(s / 20) - 1))
            return icons[index]
        }
        if (!wifiEnabled)
            return "󰤭"
        return "󰤮"
    }

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: root.active
            ? Tokens.withAlpha(Colors.primary, 0.14)
            : pointer.containsMouse
                ? Colors.surfaceContainerHighest
                : "transparent"
        scale: pointer.pressed ? 0.94 : 1
        opacity: root.online || root.wifiEnabled ? 1 : 0.55

        Text {
            anchors.centerIn: parent
            text: root.glyph
            color: Colors.surfaceForeground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: Constants.iconSizeLg + 2
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
            return rootDir + "/features/bar/network/scripts/qs-network"
        return Qt.resolvedUrl("scripts/qs-network")
            .toString().replace(/^file:\/\//, "")
    }

    Process {
        id: statusProc
        command: [root.backend, "status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const s = JSON.parse(text || "{}")
                    root.kind = s.kind || "disconnected"
                    root.signal = Number(s.signal)
                    if (!isFinite(root.signal))
                        root.signal = -1
                    root.wifiEnabled = s.wifi_enabled !== false
                    root.online = root.kind === "wifi" || root.kind === "ethernet"
                } catch (e) {
                    root.kind = "disconnected"
                    root.signal = -1
                    root.online = false
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (statusProc.running)
                statusProc.running = false
            Qt.callLater(() => { statusProc.running = true })
        }
    }
}
