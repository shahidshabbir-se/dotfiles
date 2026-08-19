pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.shared.theme

// Share connected Wi-Fi as a scannable QR — same open/load lifecycle as SpeedTestPopup.
Item {
    id: root

    property bool open: false
    property string backend: ""
    property string iface: ""
    property string connectionName: ""

    width: Constants.networkPopupWidth
    implicitHeight: card.implicitHeight + Constants.paddingLg * 2

    property string phase: "idle" // idle | loading | ready | error
    property string qrSource: ""
    property string ssid: ""
    property string security: ""
    property string password: ""
    property string error: ""
    property bool showPassword: false

    readonly property int qrSize: 220

    onOpenChanged: {
        if (open) {
            reset()
            start()
        } else {
            stop()
            reset()
        }
    }

    function reset() {
        phase = "idle"
        qrSource = ""
        ssid = ""
        security = ""
        password = ""
        error = ""
        showPassword = false
    }

    function stop() {
        if (qrProc.running)
            qrProc.running = false
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
            error = "QR backend missing"
            phase = "error"
            return
        }

        phase = "loading"
        error = ""
        qrSource = ""
        if (qrProc.running)
            qrProc.running = false

        let args = [bin, "qr", "--meta"]
        if (iface)
            args.push(iface)
        qrProc.command = args

        // Defer start so command binding settles before spawn (same as speedtest).
        Qt.callLater(() => {
            if (root.open && root.phase === "loading")
                qrProc.running = true
        })
    }

    function parseQr(raw) {
        const lines = String(raw || "").split(/\r?\n/).filter(l => l.length > 0)
        if (lines.length === 0) {
            if (!error)
                error = "No QR data"
            phase = "error"
            return
        }

        let pngB64 = ""
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("meta\t")) {
                const parts = lines[i].split("\t")
                // meta, iface, security, ssid, password?
                if (parts.length >= 4) {
                    security = parts[2]
                    ssid = parts[3]
                    password = parts.length >= 5 ? parts.slice(4).join("\t") : ""
                }
            } else if (lines[i].startsWith("png\t")) {
                pngB64 = lines[i].slice(4)
            }
        }

        if (!pngB64) {
            if (!error)
                error = "Empty QR image"
            phase = "error"
            return
        }

        qrSource = "data:image/png;base64," + pngB64
        phase = "ready"
    }

    Process {
        id: qrProc

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (root.phase === "loading")
                    root.parseQr(text)
            }
        }

        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.length && (root.phase === "loading" || root.phase === "error"))
                    root.error = text.replace(/^qs-network:\s*/, "").trim()
            }
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
                spacing: Constants.spacingMd

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.ssid || root.connectionName || "Wi‑Fi QR"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (root.phase === "loading")
                                return "Building QR…"
                            if (root.phase === "error")
                                return root.error || "Failed"
                            if (root.security)
                                return root.security + " · Scan to join"
                            return "Scan to join this network"
                        }
                        color: root.phase === "error"
                            ? Colors.error
                            : Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeSm
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
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

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: root.qrSize + Constants.paddingMd * 2
                Layout.preferredHeight: root.qrSize + Constants.paddingMd * 2

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.buttonRadius
                    color: root.phase === "ready" ? "#ffffff" : Colors.surfaceContainer
                    border.width: root.phase === "ready" ? 0 : 1
                    border.color: Colors.surfaceContainerHighest
                }

                Column {
                    visible: root.phase === "loading"
                    anchors.centerIn: parent
                    spacing: Constants.spacingSm

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰐲"
                        color: Colors.outline
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ENCODING"
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.2
                        textFormat: Text.PlainText
                    }
                }

                Text {
                    visible: root.phase === "error"
                    anchors.centerIn: parent
                    width: parent.width - Constants.paddingLg * 2
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    text: root.error || "Could not build Wi‑Fi QR"
                    color: Colors.error
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeSm
                    textFormat: Text.PlainText
                }

                Image {
                    anchors.centerIn: parent
                    width: root.qrSize
                    height: root.qrSize
                    visible: root.phase === "ready" && root.qrSource.length > 0
                    source: root.qrSource
                    fillMode: Image.PreserveAspectFit
                    smooth: false
                    mipmap: false
                    asynchronous: false
                    cache: false
                }
            }

            Rectangle {
                visible: root.phase === "ready" && root.password.length > 0
                Layout.fillWidth: true
                implicitHeight: pwRow.implicitHeight + Constants.paddingMd
                radius: Constants.buttonRadius
                color: Colors.surfaceContainer

                RowLayout {
                    id: pwRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Constants.paddingMd
                    spacing: Constants.spacingMd

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "PASSWORD"
                            color: Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeXs
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.8
                            textFormat: Text.PlainText
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.showPassword ? root.password : "••••••••"
                            color: Colors.surfaceForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeMd
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: revealLabel.implicitWidth + Constants.paddingMd * 2
                        Layout.preferredHeight: Constants.buttonSize - 4
                        radius: Constants.buttonRadius
                        color: revealArea.containsMouse
                            ? Colors.surfaceContainerHighest
                            : Colors.surfaceContainerHigh

                        Text {
                            id: revealLabel
                            anchors.centerIn: parent
                            text: root.showPassword ? "Hide" : "Show"
                            color: Colors.surfaceForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeSm
                            textFormat: Text.PlainText
                        }

                        MouseArea {
                            id: revealArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showPassword = !root.showPassword
                        }
                    }
                }
            }

            Rectangle {
                visible: root.phase === "error"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: retryLabel.implicitWidth + Constants.paddingLg * 2
                Layout.preferredHeight: Constants.buttonSize
                radius: Constants.buttonRadius
                color: retryArea.containsMouse
                    ? Colors.surfaceContainerHighest
                    : Colors.surfaceContainerHigh

                Text {
                    id: retryLabel
                    anchors.centerIn: parent
                    text: "Retry"
                    color: Colors.surfaceForeground
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeSm
                    textFormat: Text.PlainText
                }

                MouseArea {
                    id: retryArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.start()
                }
            }
        }
    }
}
