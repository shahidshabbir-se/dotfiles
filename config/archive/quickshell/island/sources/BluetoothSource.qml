import Quickshell
import Quickshell.Bluetooth
import QtQuick

Scope {
    id: root

    readonly property string panelKind: "bluetooth"
    property bool active: false
    property var pendingDevice: null
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool blocked: adapter?.state === BluetoothAdapterState.Blocked
    readonly property bool scanning: adapter?.discovering ?? false
    readonly property var devices: adapter?.devices?.values ?? []
    readonly property var connectedDevices:
        devices.filter(device => device.connected)

    function updateDiscovery() {
        if (adapter)
            adapter.discovering = active && enabled
    }

    function setEnabled(value) {
        if (!adapter || (blocked && value))
            return
        adapter.enabled = value
    }

    function refresh() {
        if (!adapter || !enabled)
            return
        const refreshAdapter = adapter
        refreshAdapter.discovering = false
        Qt.callLater(() => {
            if (root.active && root.enabled && root.adapter === refreshAdapter)
                refreshAdapter.discovering = true
        })
    }

    function activateDevice(device) {
        if (!device || device.blocked)
            return
        if (device.state === BluetoothDeviceState.Connecting
                || device.state === BluetoothDeviceState.Disconnecting)
            return
        if (device.pairing) {
            device.cancelPair()
            if (pendingDevice === device)
                pendingDevice = null
            return
        }
        if (device.connected) {
            device.disconnect()
            return
        }
        if (device.paired) {
            device.connect()
            return
        }
        if (pendingDevice && pendingDevice !== device)
            return
        pendingDevice = device
        device.pair()
    }

    Connections {
        target: root.pendingDevice

        function onPairedChanged() {
            const device = root.pendingDevice
            if (!device?.paired)
                return
            device.trusted = true
            if (root.enabled && device.adapter === root.adapter)
                device.connect()
            root.pendingDevice = null
        }

        function onPairingChanged() {
            const device = root.pendingDevice
            if (device && !device.pairing && !device.paired)
                root.pendingDevice = null
        }
    }

    onActiveChanged: updateDiscovery()
    onEnabledChanged: {
        if (!enabled) {
            if (pendingDevice?.pairing)
                pendingDevice.cancelPair()
            pendingDevice = null
        }
        updateDiscovery()
    }
    onAdapterChanged: {
        pendingDevice = null
        updateDiscovery()
    }
}
