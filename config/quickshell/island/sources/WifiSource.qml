import Quickshell
import Quickshell.Networking
import QtQuick

Scope {
    id: root

    readonly property string panelKind: "wifi"
    property bool active: false
    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property var device: {
        const devices = Networking.devices.values ?? []
        return devices.find(candidate => candidate.type === DeviceType.Wifi) ?? null
    }
    readonly property var networks: device?.networks?.values ?? []
    readonly property var connectedNetwork:
        networks.find(network => network.connected) ?? null
    readonly property bool scanning: device?.scannerEnabled ?? false

    function updateScanner() {
        if (device)
            device.scannerEnabled = active && enabled
    }

    function setEnabled(value) {
        if (!hardwareEnabled && value)
            return
        Networking.wifiEnabled = value
    }

    function refresh() {
        if (!device || !enabled)
            return
        device.scannerEnabled = false
        Qt.callLater(() => {
            if (root.active && root.device)
                root.device.scannerEnabled = true
        })
    }

    function supportsPassword(network) {
        if (!network)
            return false
        return network.security === WifiSecurityType.WpaPsk
            || network.security === WifiSecurityType.Wpa2Psk
            || network.security === WifiSecurityType.Sae
    }

    function connect(network) {
        if (!network)
            return
        network.connect()
    }

    function connectWithPassword(network, password) {
        if (!network || !supportsPassword(network) || !password)
            return
        network.connectWithPsk(password)
    }

    function disconnect(network) {
        if (network)
            network.disconnect()
    }

    function failureMessage(reason) {
        switch (reason) {
        case ConnectionFailReason.NoSecrets: return "A password is required"
        case ConnectionFailReason.WifiAuthTimeout: return "Authentication timed out"
        case ConnectionFailReason.WifiNetworkLost: return "Network is no longer available"
        case ConnectionFailReason.WifiClientDisconnected: return "Connection was interrupted"
        case ConnectionFailReason.WifiClientFailed: return "Wi-Fi authentication failed"
        default: return "Could not connect to this network"
        }
    }

    onActiveChanged: updateScanner()
    onEnabledChanged: updateScanner()
    onDeviceChanged: updateScanner()
}
