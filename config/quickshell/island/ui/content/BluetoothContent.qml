import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import "../../config" as Config

FocusScope {
    id: root

    required property var contentModel
    required property var palette

    signal actionRequested(string action, var argument)

    readonly property real preferredWidth: Config.IslandConstants.bluetoothWidth
    readonly property real preferredHeight: Config.IslandConstants.bluetoothHeight
    readonly property var source: contentModel?.source ?? null
    readonly property var devices: source?.devices ?? []
    readonly property var selectedDevice: sortedDevices.values[selectedIndex] ?? null
    property int selectedIndex: 0
    property var selectionDevice: null
    property bool initialScanPending: true

    focus: true

    function displayName(device) {
        return String(device?.name || device?.deviceName || "Unknown device")
    }

    function deviceDetail(device) {
        const details = []
        if (device?.paired)
            details.push("Paired")
        else
            details.push("Available")
        if (device?.batteryAvailable)
            details.push(Math.round(device.battery * 100) + "% battery")
        return details.join(" · ")
    }

    function stateLabel(device) {
        if (device?.blocked) return "Blocked"
        if (device?.pairing) return "Pairing"
        switch (device?.state) {
        case BluetoothDeviceState.Connecting: return "Connecting"
        case BluetoothDeviceState.Disconnecting: return "Disconnecting"
        case BluetoothDeviceState.Connected: return "Connected"
        default: return ""
        }
    }

    function moveSelection(delta) {
        const count = sortedDevices.values.length
        if (count <= 0) {
            selectedIndex = -1
            selectionDevice = null
            return
        }
        selectedIndex = Math.max(0, Math.min(count - 1, selectedIndex + delta))
        selectionDevice = sortedDevices.values[selectedIndex]
        deviceList.currentIndex = selectedIndex
        deviceList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function activate(device) {
        if (!device)
            return
        source?.activateDevice(device)
    }

    function refreshDevices() {
        initialScanPending = true
        initialScanTimer.restart()
        source?.refresh()
    }

    Component.onCompleted: {
        focusTimer.restart()
        initialScanTimer.restart()
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.actionRequested("dismiss", null)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            root.moveSelection(1)
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            root.moveSelection(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_Space
                && root.source?.adapter && !root.source.blocked) {
            root.source.setEnabled(!root.source.enabled)
            event.accepted = true
        } else if (!(root.source?.enabled ?? false)
                && (event.key === Qt.Key_Return
                    || event.key === Qt.Key_Enter)) {
            root.source?.setEnabled(true)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activate(root.selectedDevice)
            event.accepted = true
        } else if (event.key === Qt.Key_R) {
            root.refreshDevices()
            event.accepted = true
        }
    }

    Connections {
        target: root.source

        function onEnabledChanged() {
            if (!root.source?.enabled)
                return
            root.initialScanPending = true
            initialScanTimer.restart()
        }
    }

    ScriptModel {
        id: sortedDevices
        values: root.devices.slice().sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1
            if (a.pairing !== b.pairing)
                return a.pairing ? -1 : 1
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1
            if (a.trusted !== b.trusted)
                return a.trusted ? -1 : 1
            return root.displayName(a).localeCompare(root.displayName(b))
        })

        onValuesChanged: {
            const preservedIndex = values.indexOf(root.selectionDevice)
            root.selectedIndex = preservedIndex >= 0
                ? preservedIndex
                : values.length > 0 ? 0 : -1
            root.selectionDevice = root.selectedIndex >= 0
                ? values[root.selectedIndex]
                : null
            deviceList.currentIndex = root.selectedIndex
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: root.forceActiveFocus()
    }

    Timer {
        id: initialScanTimer
        interval: 1800
        onTriggered: root.initialScanPending = false
    }

    Item {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Config.IslandConstants.bluetoothPadding
            leftMargin: Config.IslandConstants.bluetoothPadding
            rightMargin: Config.IslandConstants.bluetoothPadding
        }
        height: Config.IslandConstants.bluetoothHeaderHeight

        Rectangle {
            id: bluetoothMark
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: 38
            height: 38
            radius: 12
            color: root.source?.enabled
                ? root.palette.primaryContainer
                : root.palette.surfaceContainerHigh

            Text {
                anchors.centerIn: parent
                text: Config.IslandConstants.bluetoothIcon
                color: root.source?.enabled
                    ? root.palette.primaryContainerForeground
                    : root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.iconFontFamily
                font.pixelSize: 18
            }
        }

        Column {
            anchors {
                left: bluetoothMark.right
                leftMargin: 11
                right: refreshButton.left
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 1

            Text {
                width: parent.width
                text: "Bluetooth"
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: {
                    if (!root.source?.adapter) return "No adapter found"
                    if (root.source?.blocked) return "Disabled by hardware"
                    if (!root.source?.enabled) return "Bluetooth is off"
                    const connected = root.source?.connectedDevices?.length ?? 0
                    if (connected > 0)
                        return connected + (connected === 1 ? " device connected" : " devices connected")
                    return "Available devices"
                }
                color: root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: refreshButton
            anchors {
                right: bluetoothToggle.left
                rightMargin: 9
                verticalCenter: parent.verticalCenter
            }
            width: 36
            height: 36
            radius: 11
            color: refreshMouse.containsMouse
                ? root.palette.surfaceContainerHighest
                : root.palette.surfaceContainerHigh
            opacity: root.source?.enabled ? 1 : 0.45

            Text {
                anchors.centerIn: parent
                text: Config.IslandConstants.refreshIcon
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.iconFontFamily
                font.pixelSize: 14
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                enabled: root.source?.enabled ?? false
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.refreshDevices()
            }
        }

        Rectangle {
            id: bluetoothToggle
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            width: 44
            height: 24
            radius: height / 2
            color: root.source?.enabled
                ? root.palette.primary
                : root.palette.surfaceContainerHighest
            opacity: root.source?.adapter && !root.source?.blocked ? 1 : 0.45

            Rectangle {
                width: 18
                height: 18
                radius: width / 2
                x: root.source?.enabled ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                color: root.source?.enabled
                    ? root.palette.primaryForeground
                    : root.palette.surfaceVariantForeground
            }

            MouseArea {
                anchors.fill: parent
                enabled: Boolean(root.source?.adapter) && !root.source.blocked
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.source?.setEnabled(!root.source.enabled)
            }
        }
    }

    ListView {
        id: deviceList
        anchors {
            top: header.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Config.IslandConstants.bluetoothPadding
            rightMargin: Config.IslandConstants.bluetoothPadding
            bottomMargin: Config.IslandConstants.bluetoothPadding
        }
        visible: root.source?.enabled ?? false
        clip: true
        model: sortedDevices
        currentIndex: root.selectedIndex
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationWraps: false

        highlight: Rectangle {
            radius: 12
            color: root.palette.primaryContainer
        }
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        delegate: Item {
            id: deviceRow

            required property var modelData
            required property int index

            width: deviceList.width
            height: Config.IslandConstants.bluetoothResultHeight
            readonly property bool transitioning:
                modelData.state === BluetoothDeviceState.Connecting
                || modelData.state === BluetoothDeviceState.Disconnecting
            readonly property bool pairingBlocked:
                Boolean(root.source?.pendingDevice)
                && root.source.pendingDevice !== modelData
                && !modelData.paired

            Rectangle {
                id: iconSlot
                anchors {
                    left: parent.left
                    leftMargin: 9
                    verticalCenter: parent.verticalCenter
                }
                width: 34
                height: 34
                radius: 10
                color: root.palette.surfaceContainerHigh

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: 22
                    source: Quickshell.iconPath(
                        String(deviceRow.modelData.icon ?? ""),
                        "bluetooth"
                    )
                }

                Text {
                    anchors.centerIn: parent
                    visible: !deviceRow.modelData.icon
                    text: Config.IslandConstants.bluetoothIcon
                    color: root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.iconFontFamily
                    font.pixelSize: 14
                }
            }

            Column {
                anchors {
                    left: iconSlot.right
                    leftMargin: 11
                    right: stateText.left
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 1

                Text {
                    width: parent.width
                    text: root.displayName(deviceRow.modelData)
                    color: root.palette.surfaceForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 14
                    font.weight: deviceRow.modelData.connected ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.deviceDetail(deviceRow.modelData)
                    color: root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            Text {
                id: stateText
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                text: root.stateLabel(deviceRow.modelData)
                color: deviceRow.modelData.connected
                    ? root.palette.primary
                    : root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                enabled: !deviceRow.modelData.blocked
                    && !deviceRow.transitioning
                    && !deviceRow.pairingBlocked
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onEntered: {
                    root.selectedIndex = deviceRow.index
                    root.selectionDevice = deviceRow.modelData
                    deviceList.currentIndex = deviceRow.index
                }
                onClicked: root.activate(deviceRow.modelData)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: sortedDevices.values.length === 0
            text: root.initialScanPending
                ? "Looking for devices…"
                : "No devices found · press R to rescan"
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 12
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !(root.source?.enabled ?? false)
        text: {
            if (!root.source?.adapter) return "No Bluetooth adapter found"
            if (root.source?.blocked) return "Bluetooth is disabled by a hardware switch"
            return "Press Space to turn on Bluetooth"
        }
        color: root.palette.surfaceVariantForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: 13
    }
}
