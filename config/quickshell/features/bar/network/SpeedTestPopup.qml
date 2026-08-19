pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.shared.theme

// Live download/upload speed dial (fast.com via qs-network script).
Item {
    id: root

    property bool open: false
    property string backend: ""
    property string connectionName: ""

    width: Constants.networkPopupWidth
    implicitHeight: card.implicitHeight + Constants.paddingLg * 2

    property string phase: "idle" // idle | down | up | done | error
    property real downMbps: 0
    property real upMbps: 0
    property real liveMbps: 0
    property string error: ""
    property var downSamples: []
    property var upSamples: []

    readonly property real displayMbps: {
        if (phase === "down" || phase === "up")
            return liveMbps
        if (phase === "done")
            return upMbps > 0 ? upMbps : downMbps
        return 0
    }

    readonly property string phaseLabel: {
        if (phase === "down")
            return "DOWNLOAD"
        if (phase === "up")
            return "UPLOAD"
        if (phase === "done")
            return "DONE"
        if (phase === "error")
            return "ERROR"
        return "READY"
    }

    onOpenChanged: {
        if (open) {
            reset()
            start()
        } else {
            stop()
        }
    }

    function reset() {
        phase = "idle"
        downMbps = 0
        upMbps = 0
        liveMbps = 0
        error = ""
        downSamples = []
        upSamples = []
    }

    function stop() {
        if (speedProc.running)
            speedProc.running = false
    }

    function resolveBackend() {
        if (backend && backend.length > 0)
            return backend
        const rootDir = Quickshell.shellDir || ""
        if (rootDir.length > 0)
            return rootDir + "/features/bar/network/scripts/qs-network"
        return ""
    }

    function start() {
        const bin = resolveBackend()
        if (!bin) {
            error = "Speed test backend missing"
            phase = "error"
            return
        }
        phase = "down"
        liveMbps = 0
        error = ""
        if (speedProc.running)
            speedProc.running = false
        speedProc.command = [bin, "speedtest", "down"]
        // Defer start so command binding settles before spawn.
        Qt.callLater(() => {
            if (root.open && root.phase === "down")
                speedProc.running = true
        })
    }

    function startUp() {
        phase = "up"
        liveMbps = 0
        if (speedProc.running)
            speedProc.running = false
        speedProc.command = [backend, "speedtest", "up"]
        Qt.callLater(() => {
            if (root.open && root.phase === "up")
                speedProc.running = true
        })
    }

    function onLine(line) {
        const v = parseFloat(line)
        if (!isFinite(v))
            return
        liveMbps = v
        if (phase === "down") {
            const next = downSamples.slice()
            next.push(v)
            downSamples = next
        } else if (phase === "up") {
            const next = upSamples.slice()
            next.push(v)
            upSamples = next
        }
    }

    function median(arr) {
        if (!arr || arr.length === 0)
            return 0
        const s = arr.slice().sort((a, b) => a - b)
        const mid = Math.floor(s.length / 2)
        return s.length % 2 ? s[mid] : (s[mid - 1] + s[mid]) / 2
    }

    function onPhaseDone() {
        if (phase === "down") {
            downMbps = median(downSamples)
            startUp()
        } else if (phase === "up") {
            upMbps = median(upSamples)
            phase = "done"
            liveMbps = upMbps
        }
    }

    Process {
        id: speedProc
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => root.onLine(data)
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.length && root.phase !== "done") {
                    root.error = text.replace(/^qs-network:\s*/, "").trim()
                    root.phase = "error"
                }
            }
        }
        onRunningChanged: {
            if (running)
                return
            if (root.phase === "error" || root.phase === "done" || root.phase === "idle")
                return
            // Process finished current phase
            root.onPhaseDone()
        }
    }

    opacity: open ? 1 : 0
    scale: open ? 1 : Constants.popupFromScale

    Behavior on opacity {
        NumberAnimation {
            duration: open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: body.implicitHeight + Constants.paddingLg * 2
        radius: Constants.panelRadius
        color: Colors.surfaceContainerLow
        border.width: Constants.borderWidth
        border.color: Colors.surfaceContainerHighest

        ColumnLayout {
            id: body
            x: Constants.paddingLg
            y: Constants.paddingLg
            width: parent.width - Constants.paddingLg * 2
            spacing: Constants.spacingMd

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: root.connectionName || "Speed test"
                    color: Colors.surfaceForeground
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeLg
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                Rectangle {
                    Layout.preferredWidth: closeLabel.implicitWidth + Constants.paddingMd * 2
                    Layout.preferredHeight: Constants.buttonSize
                    radius: Constants.buttonRadius
                    color: closeArea.containsMouse
                        ? Colors.surfaceContainerHighest
                        : Colors.surfaceContainerHigh

                    Text {
                        id: closeLabel
                        anchors.centerIn: parent
                        text: "Close"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeSm
                        textFormat: Text.PlainText
                    }

                    MouseArea {
                        id: closeArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.stop()
                            root.open = false
                        }
                    }
                }
            }

            // Dial
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Colors.surfaceContainer
                    border.width: 2
                    border.color: Colors.surfaceContainerHighest
                }

                // progress arc approximation via ring thickness pulse
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 24
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.width: 6
                    border.color: {
                        if (root.phase === "error")
                            return Colors.error
                        if (root.phase === "done")
                            return Colors.primary
                        if (root.phase === "up")
                            return Colors.tertiary
                        return Colors.primary
                    }
                    opacity: root.phase === "idle" ? 0.25 : 0.9

                    Behavior on border.color {
                        ColorAnimation { duration: Constants.animationNormal }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.phaseLabel
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.2
                        textFormat: Text.PlainText
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.phase === "error"
                            ? "—"
                            : (root.displayMbps < 10
                                ? root.displayMbps.toFixed(1)
                                : Math.round(root.displayMbps).toString())
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: 40
                        font.weight: Font.Bold
                        textFormat: Text.PlainText
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Mbps"
                        color: Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeSm
                        textFormat: Text.PlainText
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Constants.spacingLg
                visible: root.phase === "done" || root.downMbps > 0

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "DOWNLOAD"
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }

                    Text {
                        text: root.downMbps < 10
                            ? root.downMbps.toFixed(1)
                            : Math.round(root.downMbps)
                        color: Colors.primary
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "UPLOAD"
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }

                    Text {
                        text: root.upMbps < 10
                            ? root.upMbps.toFixed(1)
                            : Math.round(root.upMbps)
                        color: Colors.tertiary
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }
                }
            }

            Text {
                visible: root.error.length > 0
                Layout.fillWidth: true
                text: root.error
                color: Colors.error
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSm
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
            }
        }
    }
}
