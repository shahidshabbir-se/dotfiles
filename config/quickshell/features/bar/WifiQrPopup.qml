pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.shared.theme

// Share connected Wi-Fi as a scannable QR matrix.
Item {
    id: root

    property bool open: false
    property string backend: ""
    property string iface: ""

    width: Constants.networkPopupWidth
    implicitHeight: card.implicitHeight + Constants.paddingLg * 2

    property var matrix: []
    property string ssid: ""
    property string security: ""
    property string password: ""
    property string error: ""
    property bool showPassword: false

    onOpenChanged: {
        if (open)
            load()
        else
            reset()
    }

    function reset() {
        matrix = []
        ssid = ""
        security = ""
        password = ""
        error = ""
        showPassword = false
    }

    function load() {
        reset()
        let args = [backend, "qr", "--meta"]
        if (iface)
            args.push(iface)
        qrProc.command = args
        qrProc.running = true
    }

    function parseQr(raw) {
        const lines = String(raw || "").split(/\r?\n/).filter(l => l.length > 0)
        if (lines.length === 0) {
            error = "No QR data"
            return
        }
        let i = 0
        if (lines[0].startsWith("meta\t")) {
            const parts = lines[0].split("\t")
            // meta, iface, security, ssid
            if (parts.length >= 4) {
                security = parts[2]
                ssid = parts.slice(3).join("\t")
            }
            i = 1
        }
        const rows = []
        for (; i < lines.length; i++) {
            if (/^[01]+$/.test(lines[i]))
                rows.push(lines[i])
        }
        matrix = rows
        if (matrix.length === 0)
            error = "Empty QR matrix"

        // fetch password for display
        let pwArgs = [backend, "password"]
        if (iface)
            pwArgs.push(iface)
        pwProc.command = pwArgs
        pwProc.running = true
    }

    Process {
        id: qrProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseQr(text)
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.length)
                    root.error = text.replace(/^qs-network:\s*/, "").trim()
            }
        }
    }

    Process {
        id: pwProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.password = String(text || "").replace(/\r?\n$/, "")
        }
    }

    opacity: open ? 1 : 0
    scale: open ? 1 : 0.96

    Behavior on opacity {
        NumberAnimation {
            duration: Constants.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Constants.animationSlow
            easing.type: Easing.OutBack
        }
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: body.implicitHeight + Constants.paddingLg * 2
        radius: Constants.networkPopupRadius
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
                        text: root.ssid || "Wi‑Fi QR"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Text {
                        text: root.error || "Scan to join this network"
                        color: root.error ? Colors.error : Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeSm
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
                        onClicked: root.open = false
                    }
                }
            }

            // QR matrix
            Item {
                id: qrBox
                Layout.alignment: Qt.AlignHCenter
                readonly property int modules: root.matrix.length > 0 ? root.matrix[0].length : 0
                readonly property int cell: modules > 0
                    ? Math.max(2, Math.floor(220 / modules))
                    : 4
                implicitWidth: modules * cell
                implicitHeight: modules * cell
                visible: modules > 0

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -Constants.paddingSm
                    radius: Constants.buttonRadius
                    color: "#ffffff"
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: root.matrix
                        Row {
                            required property string modelData
                            spacing: 0
                            Repeater {
                                model: modelData.length
                                Rectangle {
                                    required property int index
                                    width: qrBox.cell
                                    height: qrBox.cell
                                    color: modelData.charAt(index) === "1" ? "#000000" : "#ffffff"
                                }
                            }
                        }
                    }
                }
            }

            // Password reveal
            Rectangle {
                visible: root.password.length > 0
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

                    Text {
                        Layout.fillWidth: true
                        text: root.showPassword ? root.password : "••••••••"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeMd
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
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
        }
    }
}
