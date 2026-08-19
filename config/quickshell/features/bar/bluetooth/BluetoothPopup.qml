pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.shared.theme

Item {
    id: root

    property bool open: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var rawDevices: Bluetooth.devices ? Bluetooth.devices.values : []

    property int phraseIndex: 0
    readonly property var activePhrases: [
        "Untangling wires",
        "Streaming vikings",
        "Pairing mysteries",
        "Herding headsets",
        "Taming radios",
        "Summoning speakers"
    ]

    readonly property string heroIcon: {
        if (!adapter)
            return "󰂲"
        if (!adapter.enabled)
            return "󰂲"
        if (connectedDevices.length > 0)
            return "󰂱"
        return "󰂯"
    }

    readonly property string heroStatus: {
        if (!adapter)
            return "No adapter"
        if (!adapter.enabled)
            return "Turned Off"
        return activePhrases[phraseIndex % activePhrases.length]
    }

    function deviceLabel(device) {
        if (!device)
            return ""
        return String(device.deviceName || device.name || "").trim()
    }

    function isJunkLabel(label) {
        if (!label)
            return true
        if (/^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(label))
            return true
        if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(label))
            return true
        return false
    }

    function sortByLabel(list) {
        return list.slice().sort((a, b) => deviceLabel(a).localeCompare(deviceLabel(b)))
    }

    readonly property var connectedDevices: {
        const out = []
        for (let i = 0; i < rawDevices.length; i++) {
            const d = rawDevices[i]
            if (d && d.connected && !isJunkLabel(deviceLabel(d)))
                out.push(d)
        }
        return sortByLabel(out)
    }

    readonly property var knownDevices: {
        const out = []
        for (let i = 0; i < rawDevices.length; i++) {
            const d = rawDevices[i]
            if (!d || d.connected || isJunkLabel(deviceLabel(d)))
                continue
            if (d.paired || d.bonded || d.trusted)
                out.push(d)
        }
        return sortByLabel(out)
    }

    readonly property var discoveredDevices: {
        const out = []
        for (let i = 0; i < rawDevices.length; i++) {
            const d = rawDevices[i]
            if (!d || d.connected || isJunkLabel(deviceLabel(d)))
                continue
            if (d.paired || d.bonded || d.trusted)
                continue
            out.push(d)
        }
        return sortByLabel(out)
    }

    width: Constants.bluetoothPopupWidth
    implicitHeight: Math.min(
        Constants.bluetoothPopupMaxHeight,
        shell.implicitHeight
    )

    opacity: entrance.revealProgress
    scale: Constants.popupFromScale + entrance.revealProgress * (1 - Constants.popupFromScale)

    onOpenChanged: {
        if (open) {
            entrance.play()
            Qt.callLater(root.ensureDiscovery)
        } else {
            entrance.reset()
            if (adapter && adapter.discovering)
                adapter.discovering = false
        }
    }

    Component.onCompleted: {
        if (open) {
            entrance.play()
            Qt.callLater(root.ensureDiscovery)
        }
    }

    function ensureDiscovery() {
        // ponytail: no retry loop — BlueZ "already in progress" spam if we nudge
        if (!open || !adapter || !adapter.enabled || adapter.discovering)
            return
        adapter.discovering = true
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    QtObject {
        id: entrance

        property real revealProgress: 0

        function play() {
            reset()
            Qt.callLater(() => {
                if (root.open)
                    revealProgress = 1
            })
        }

        function reset() {
            revealProgress = 0
        }
    }

    Timer {
        interval: 2800
        running: root.open && root.adapter && root.adapter.enabled
        repeat: true
        onTriggered: phraseSwap.restart()
    }

    SequentialAnimation {
        id: phraseSwap

        PropertyAnimation {
            target: heroStatusText
            property: "opacity"
            to: 0
            duration: 180
            easing.type: Easing.OutQuad
        }
        ScriptAction {
            script: root.phraseIndex = (root.phraseIndex + 1) % root.activePhrases.length
        }
        PropertyAnimation {
            target: heroStatusText
            property: "opacity"
            to: 1
            duration: 260
            easing.type: Easing.InQuad
        }
    }

    function togglePower() {
        if (!adapter)
            return
        // ponytail: adapter.enabled is session-local; rfkill persist if boots matter
        adapter.enabled = !adapter.enabled
    }

    function activateDevice(device) {
        if (!device)
            return
        if (device.connected) {
            device.disconnect()
            return
        }
        if (device.paired || device.bonded || device.trusted)
            device.connect()
        else
            device.pair()
    }

    function forgetDevice(device) {
        if (device)
            device.forget()
    }

    Rectangle {
        id: shell

        width: parent.width
        implicitHeight: body.implicitHeight + Constants.paddingLg * 2
        radius: Constants.panelRadius
        color: Colors.surfaceContainerLow
        clip: true
        border.width: Constants.borderWidth
        border.color: Colors.surfaceContainerHighest

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            radius: parent.radius
            color: Tokens.withAlpha(Colors.shadow, 0.28)
            z: -1
        }

        ColumnLayout {
            id: body

            x: Constants.paddingLg
            y: Constants.paddingLg + (1 - entrance.revealProgress) * 8
            width: parent.width - Constants.paddingLg * 2
            spacing: Constants.spacingMd

            // ---------- Hero ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: Constants.spacingMd

                Text {
                    text: root.heroIcon
                    color: Colors.surfaceForeground
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Constants.fontSizeXl + 4
                    opacity: root.adapter && root.adapter.enabled ? 1 : 0.45
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Text {
                        id: heroStatusText
                        Layout.fillWidth: true
                        text: root.heroStatus.toUpperCase()
                        color: Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.1
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }
                }

                ToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: !!(root.adapter && root.adapter.enabled)
                    interactive: !!root.adapter
                    onToggled: root.togglePower()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.surfaceContainerHighest
            }

            // ---------- Connected ----------
            ColumnLayout {
                visible: root.connectedDevices.length > 0
                Layout.fillWidth: true
                spacing: Constants.spacingSm

                Text {
                    text: "CONNECTED"
                    color: Colors.outline
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeXs
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                    textFormat: Text.PlainText
                }

                Repeater {
                    model: root.connectedDevices

                    DeviceRow {
                        required property var modelData
                        Layout.fillWidth: true
                        device: modelData
                        section: "connected"
                    }
                }
            }

            Rectangle {
                visible: root.connectedDevices.length > 0
                    && (root.knownDevices.length > 0 || root.discoveredDevices.length > 0)
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.surfaceContainerHighest
            }

            // ---------- Paired + Available (scroll) ----------
            Flickable {
                id: listFlick
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 320)
                contentWidth: width
                contentHeight: listCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: contentHeight > height

                ColumnLayout {
                    id: listCol
                    width: listFlick.width
                    spacing: Constants.spacingMd

                    ColumnLayout {
                        visible: root.knownDevices.length > 0
                        Layout.fillWidth: true
                        spacing: Constants.spacingSm

                        Text {
                            text: "PAIRED"
                            color: Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeXs
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.1
                            textFormat: Text.PlainText
                        }

                        Repeater {
                            model: root.knownDevices

                            DeviceRow {
                                required property var modelData
                                Layout.fillWidth: true
                                device: modelData
                                section: "known"
                            }
                        }
                    }

                    Rectangle {
                        visible: root.knownDevices.length > 0
                            && root.adapter
                            && root.adapter.discovering
                            && root.discoveredDevices.length > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colors.surfaceContainerHighest
                    }

                    ColumnLayout {
                        visible: root.adapter
                            && root.adapter.discovering
                            && root.discoveredDevices.length > 0
                        Layout.fillWidth: true
                        spacing: Constants.spacingSm

                        Text {
                            text: "AVAILABLE"
                            color: Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: Constants.fontSizeXs
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.1
                            textFormat: Text.PlainText
                        }

                        Repeater {
                            model: root.discoveredDevices

                            DeviceRow {
                                required property var modelData
                                Layout.fillWidth: true
                                device: modelData
                                section: "discovered"
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.connectedDevices.length === 0
                    && root.knownDevices.length === 0
                    && !(root.adapter && root.adapter.discovering && root.discoveredDevices.length > 0)
                Layout.fillWidth: true
                text: !root.adapter
                    ? "No Bluetooth adapter"
                    : !root.adapter.enabled
                        ? "Turn Bluetooth on to scan"
                        : "Scanning for devices…"
                color: Colors.outline
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSm
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
            }
        }
    }

    component DeviceRow: Rectangle {
        id: row

        required property var device
        required property string section

        readonly property bool isConnected: device && device.connected
        readonly property bool canForget: section === "known" || section === "connected"
        readonly property string statusText: {
            if (!device)
                return ""
            if (device.state === BluetoothDeviceState.Disconnecting)
                return "Disconnecting…"
            if (device.state === BluetoothDeviceState.Connecting || device.pairing)
                return "Connecting…"
            if (isConnected) {
                if (device.batteryAvailable)
                    return Math.round(device.battery * 100) + "%"
                return section === "connected" ? "" : "Connected"
            }
            return ""
        }

        implicitHeight: Constants.networkRowHeight
        radius: Constants.buttonRadius
        color: rowMa.containsMouse
            ? Colors.surfaceContainerHighest
            : "transparent"

        MouseArea {
            id: rowMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (!row.device)
                    return
                if (mouse.button === Qt.RightButton) {
                    if (row.isConnected)
                        row.device.disconnect()
                    else if (row.canForget)
                        root.forgetDevice(row.device)
                    return
                }
                root.activateDevice(row.device)
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Constants.paddingMd
            anchors.rightMargin: Constants.paddingMd
            spacing: Constants.spacingMd

            Text {
                text: row.isConnected ? "󰂱" : "󰂯"
                color: row.isConnected
                    ? Colors.surfaceForeground
                    : Colors.outline
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Constants.fontSizeLg
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: root.deviceLabel(row.device) || "Device"
                    color: Colors.surfaceForeground
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeMd
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }

                Text {
                    visible: row.statusText !== ""
                    Layout.fillWidth: true
                    text: row.statusText
                    color: row.isConnected
                        ? Colors.surfaceForeground
                        : Colors.outline
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeXs
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                }
            }

            Text {
                visible: row.canForget && rowMa.containsMouse
                text: "󰅙"
                color: Colors.outline
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Constants.fontSizeLg
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.forgetDevice(row.device)
                }
            }
        }
    }
}
