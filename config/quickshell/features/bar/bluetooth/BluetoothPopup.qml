pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import qs.shared.theme

Item {
    id: root

    property bool open: false

    // Actions go out over BlueZ's D-Bus object rather than through
    // `Bluetooth.devices`. That model only carries the discovery set, and the
    // keepalive below restarts discovery every 20s — so a device can leave the
    // model between the row being drawn and the click landing on it, and the
    // pair or connect then does nothing at all. BlueZ recreates the device
    // object on demand, so addressing it directly is what makes the click
    // work. This is the same thing blueman does.
    readonly property string backend: Quickshell.shellPath(
        "features/bar/bluetooth/scripts/qs-bluetooth"
    )

    function bluez(action, device) {
        const address = String((device && device.address) || "").trim()
        if (address.length === 0)
            return
        Quickshell.execDetached([root.backend, action, address])
    }

    // ---------- Bond registry ----------
    //
    // BlueZ reports Paired/Bonded/Trusted from the device object, and that
    // object is not always the bonded one: a device that has gone out of range
    // and come back can be a stale record reporting Paired=false, which filed
    // a speaker the user had already paired under AVAILABLE. The address of
    // anything this machine has actually paired is kept here, so the panel can
    // still say "this is mine" when BlueZ forgets.
    readonly property string registryPath: (Quickshell.env("XDG_STATE_HOME")
        || Quickshell.env("HOME") + "/.local/state") + "/quickshell/bluetooth-devices.json"

    property var bonds: ({})

    FileView {
        id: bondsFile

        path: root.registryPath
        // Synchronous on purpose: a registry that arrives a tick late would
        // misfile the first device it saw.
        preload: true
        printErrors: false
        atomicWrites: true
        // The new contents arrive as the signal argument. Reading `text` as a
        // property does not work here: the FileView wrapper shadows it with a
        // function of the same name.
        onTextChanged: (changed) => root.loadBonds(changed)
    }

    function loadBonds(raw) {
        let parsed = null
        try {
            parsed = JSON.parse(String(raw || "{}"))
        } catch (e) {
            parsed = null
        }
        root.bonds = (parsed && typeof parsed === "object" && !Array.isArray(parsed))
            ? parsed
            : {}
    }

    function saveBonds() {
        // `__text` is read-only, so the write goes through the setter.
        bondsFile.setText(JSON.stringify(root.bonds, null, 2))
    }

    function isKnownBond(device) {
        const address = String((device && device.address) || "")
        return address.length > 0 && root.bonds[address] !== undefined
    }

    // Returns true when it was new, so callers can keep it cheap: this runs
    // for every device on every list rebuild.
    function rememberBond(device) {
        if (!device)
            return false
        const address = String(device.address || "")
        if (address.length === 0 || root.bonds[address] !== undefined)
            return false
        root.bonds = Object.assign({}, root.bonds, {
            [address]: root.deviceLabel(device)
        })
        saveBonds()
        return true
    }

    function forgetBond(address) {
        if (!address || root.bonds[address] === undefined)
            return
        const next = Object.assign({}, root.bonds)
        delete next[address]
        root.bonds = next
        saveBonds()
    }

    // BlueZ's own opinion, or ours. A device either reports as bonded or the
    // registry remembers pairing it here.
    function isOurs(device) {
        if (!device)
            return false
        return !!(device.paired || device.bonded || device.trusted || root.isKnownBond(device))
    }

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

    // A device with no usable name is shown by its address, the way blueman
    // does. Hiding it instead left a speaker that was plainly visible in blueman
    // missing from this panel, with no way to pair or remove it.
    function deviceLabel(device) {
        if (!device)
            return ""
        const name = String(device.deviceName || device.name || "").trim()
        if (name.length > 0 && !isJunkLabel(name))
            return name
        const address = String(device.address || "").trim()
        return address.length > 0 ? address : "Unknown device"
    }

    // Still used to decide whether a label is worth showing, not to drop rows.
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
            if (!d || !d.connected)
                continue
            root.notePairing(d)
            if (!root.isForgotten(d))
                out.push(d)
        }
        return sortByLabel(out)
    }

    readonly property var knownDevices: {
        const out = []
        for (let i = 0; i < rawDevices.length; i++) {
            const d = rawDevices[i]
            if (!d || d.connected)
                continue
            if (root.isOurs(d)) {
                root.notePairing(d)
                if (!root.isForgotten(d))
                    out.push(d)
            }
        }
        return sortByLabel(out)
    }

    readonly property var discoveredDevices: {
        const out = []
        for (let i = 0; i < rawDevices.length; i++) {
            const d = rawDevices[i]
            if (!d || d.connected)
                continue
            if (root.isOurs(d))
                continue
            // A device we just removed is still being rediscovered by BlueZ;
            // listing it again under AVAILABLE is what made the cross look inert.
            if (!root.isForgotten(d))
                out.push(d)
        }
        return sortByLabel(out)
    }

    // ---------- Removal ----------
    //
    // BlueZ refuses to remove a device that is still connected, so removing a
    // connected one is two steps: disconnect, then forget once the device
    // reports it is down. `removing` is the addresses in that window, so the
    // row can say what it is doing instead of silently doing nothing.
    //
    // `forgotten` is the addresses removed in this session. BlueZ keeps the
    // object in `Bluetooth.devices` after a forget — and keeps rediscovering
    // the device — so without this the row simply reappeared under AVAILABLE a
    // moment later and the cross looked like it had done nothing.
    property var removing: []
    property var forgotten: []


    // Remembering is a side effect, so it is kept out of the list bindings
    // above: those read `bonds` to classify, and writing `bonds` from inside
    // one of them is a binding loop.
    function syncBonds() {
        const devices = root.rawDevices
        for (let i = 0; i < devices.length; i++) {
            const d = devices[i]
            if (d && (d.paired || d.bonded || d.trusted))
                root.rememberBond(d)
        }
    }

    onRawDevicesChanged: Qt.callLater(root.syncBonds)

    function isRemoving(device) {
        return !!device && root.removing.indexOf(String(device.address || "")) >= 0
    }

    function isForgotten(device) {
        return !!device && root.forgotten.indexOf(String(device.address || "")) >= 0
    }

    // A device that pairs again is genuinely back; clear the memory of it.
    function notePairing(device) {
        if (!device)
            return
        const address = String(device.address || "")
        if (root.isOurs(device) && root.forgotten.indexOf(address) >= 0) {
            const next = root.forgotten.slice()
            next.splice(next.indexOf(address), 1)
            root.forgotten = next
        }
    }

    function removeDevice(device) {
        if (!device || root.isRemoving(device))
            return

        const address = String(device.address || "")
        if (address.length === 0) {
            root.bluez("forget", device)
            return
        }

        if (device.connected) {
            if (root.removing.indexOf(address) < 0) {
                const next = root.removing.slice()
                next.push(address)
                root.removing = next
            }
            root.bluez("disconnect", device)
            return
        }

        root.bluez("forget", device)
        root.markForgotten(address)
    }

    function completeRemoval(device) {
        if (!device)
            return
        const address = String(device.address || "")
        if (root.removing.indexOf(address) < 0)
            return

        const next = root.removing.slice()
        next.splice(next.indexOf(address), 1)
        root.removing = next

        root.bluez("forget", device)
        root.markForgotten(address)
    }

    function markForgotten(address) {
        // An explicit removal is the user saying they no longer want this
        // pairing, so the registry gives it up too — otherwise the device would
        // come back filed under PAIRED with nothing behind it.
        root.forgetBond(address)
        if (root.forgotten.indexOf(address) < 0) {
            const next = root.forgotten.slice()
            next.push(address)
            root.forgotten = next
        }
    }

    function forgetDevice(device) {
        root.removeDevice(device)
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
            Qt.callLater(root.syncBonds)
            keepalive.start()
        } else {
            entrance.reset()
            keepalive.stop()
            if (adapter && adapter.discovering)
                adapter.discovering = false
            // The memory of what was removed only has to outlive the click that
            // removed it, so a row does not reappear under the pointer. Held
            // across the session it hid a device the user could see in blueman
            // and could not get back without restarting the shell.
            forgotten = []
            removing = []
        }
    }

    Component.onCompleted: {
        if (open) {
            entrance.play()
            Qt.callLater(root.ensureDiscovery)
            Qt.callLater(root.syncBonds)
            keepalive.start()
        }
    }

    function ensureDiscovery() {
        // No retry loop: BlueZ answers a second "already in progress" request
        // with an error, and the keepalive below covers the timeout case.
        if (!open || !adapter || !adapter.enabled || adapter.discovering)
            return
        adapter.discovering = true
    }

    // BlueZ ends a discovery run on its own (the daemon times it out), which
    // used to leave the panel claiming to scan while nothing was scanning.
    // Re-arm while the panel is open so AVAILABLE keeps filling.
    Timer {
        id: keepalive

        interval: 20000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.open)
                return
            if (adapter && adapter.discovering)
                adapter.discovering = false
            Qt.callLater(root.ensureDiscovery)
        }
    }

    // Discovering is the truth the empty state reports.
    readonly property bool discovering: !!(adapter && adapter.enabled && adapter.discovering)

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
        if (!device || root.isRemoving(device))
            return
        if (device.connected) {
            root.bluez("disconnect", device)
            return
        }
        if (root.isOurs(device)) {
            root.bluez("connect", device)
            return
        }
        root.bluez("pair", device)
    }

    Rectangle {
        id: shell

        width: parent.width
        implicitHeight: body.implicitHeight + Constants.paddingLg * 2
        radius: Constants.panelRadius
        color: Colors.surfaceContainerLow
        clip: true
        // The popup's own outline: primary, and tuned from Constants so the
        // weight and colour live in one place.
        border.width: Constants.popupBorderWidth
        border.color: Constants.popupBorderColor

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

                // Rescan. Discovery times out on its own, and the panel keeps
                // its own keepalive, so this is for "look again now" rather
                // than for keeping the scan alive.
                Rectangle {
                    visible: root.adapter && root.adapter.enabled
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    radius: Constants.buttonRadius
                    color: scanArea.containsMouse
                        ? Colors.surfaceContainerHighest
                        : Colors.surfaceContainerHigh
                    Layout.alignment: Qt.AlignVCenter

                    // Spins while BlueZ is discovering: that is the only
                    // visible sign the panel is doing anything, and the phrase
                    // in the hero says nothing about a scan being in flight.
                    Text {
                        id: scanGlyph

                        anchors.centerIn: parent
                        text: "󰑐"
                        color: Colors.surfaceForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Constants.fontSizeLg

                        RotationAnimator on rotation {
                            running: root.discovering
                            from: 0
                            to: 360
                            duration: 1200
                            loops: Animation.Infinite
                        }
                    }

                    MouseArea {
                        id: scanArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.adapter && root.adapter.discovering)
                                root.adapter.discovering = false
                            Qt.callLater(root.ensureDiscovery)
                        }
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
                            && root.discovering
                            && root.discoveredDevices.length > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colors.surfaceContainerHighest
                    }

                    ColumnLayout {
                        visible: root.discovering
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
                    && !(root.discovering && root.discoveredDevices.length > 0)
                Layout.fillWidth: true
                text: !root.adapter
                    ? "No Bluetooth adapter"
                    : !root.adapter.enabled
                        ? "Turn Bluetooth on to scan"
                        : root.discovering
                            ? "Scanning for devices…"
                            : "No devices yet"
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
        // RemoveDevice works on any device. For a paired one it is "forget"; for
        // one that only ever turned up in a scan it is the same reset blueman
        // does, which is what makes an unreachable device pairable again.
        readonly property bool canForget: section !== ""
        // Removing a connected device is disconnect-then-forget, so the row has
        // to report the whole thing: the X is live while it waits.
        readonly property bool isRemoving: root.isRemoving(device)
        readonly property bool canAct: !root.isRemoving(device)

        // A pair or connect that ends without success used to look like nothing
        // had happened. BlueZ reports the failure only by dropping the flag
        // again, so the flag going false without the result is the signal.
        property bool attemptedPair: false
        property bool attemptedConnect: false
        property string failureText: ""

        // Dot state, the minimal row model's whole status channel:
        // filled while connected, hollow when idle, ringed while busy.
        readonly property bool busy: device
            && (device.pairing
                || device.state === BluetoothDeviceState.Connecting
                || device.state === BluetoothDeviceState.Disconnecting
                || root.isRemoving(device))

        readonly property color dotColor: row.busy
            ? Colors.primary
            : (row.isConnected ? Colors.primary : Colors.outline)

        readonly property string statusText: {
            if (!device)
                return ""
            if (root.isRemoving(device))
                return isConnected ? "Disconnecting…" : "Removing…"
            if (device.state === BluetoothDeviceState.Disconnecting)
                return "Disconnecting…"
            if (device.state === BluetoothDeviceState.Connecting || device.pairing)
                return device.pairing ? "Pairing…" : "Connecting…"
            if (isConnected) {
                if (device.batteryAvailable)
                    return Math.round(device.battery * 100) + "%"
                return section === "connected" ? "" : "Connected"
            }
            if (failureText !== "")
                return failureText
            return section === "known" ? "Not connected" : "Tap to pair"
        }

        function noteAttempt(pair) {
            attemptedPair = pair
            attemptedConnect = !pair
            failureText = ""
        }

        function noteOutcome(paired) {
            if (paired) {
                if (attemptedPair)
                    failureText = "Paired — connecting…"
                attemptedPair = false
                return
            }
            if (attemptedPair) {
                attemptedPair = false
                // BlueZ answers "not available" for a device that is out of
                // range or still held by another host, and it keeps that stale
                // record until it is removed. Say so, because no amount of
                // retrying from here will get past it.
                failureText = "Not in range or held elsewhere — ✕ then rescan"
            } else if (attemptedConnect) {
                attemptedConnect = false
                failureText = "Connect failed — ✕ then rescan"
            }
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
                        root.bluez("disconnect", row.device)
                    else if (row.canForget)
                        root.forgetDevice(row.device)
                    return
                }
                const paired = root.isOurs(row.device)
                row.noteAttempt(!paired)
                root.activateDevice(row.device)
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Constants.paddingMd
            anchors.rightMargin: Constants.paddingMd
            spacing: Constants.spacingMd

            // Status dot: filled when connected, hollow when idle, and it
            // spins while a pair or connect is in flight.
            Item {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    id: dot

                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    radius: 5
                    color: row.isConnected && !row.busy ? row.dotColor : "transparent"
                    border.width: row.busy || !row.isConnected ? 2 : 0
                    border.color: row.dotColor

                    RotationAnimator on rotation {
                        running: row.busy
                        from: 0
                        to: 360
                        duration: 1100
                        loops: Animation.Infinite
                    }
                }
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
                visible: row.canForget
                    && !row.isRemoving
                    && (rowMa.containsMouse || row.failureText !== "")
                text: "󰅙"
                color: Colors.outline
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: Constants.fontSizeLg
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.removeDevice(row.device)
                }
            }
        }

        Connections {
            target: row.device

            function onConnectedChanged() {
                if (!row.device)
                    return
                if (!row.device.connected) {
                    // Second half of a connected removal: as soon as BlueZ
                    // reports the device is down, finish the forget.
                    if (row.isRemoving)
                        root.completeRemoval(row.device)
                    else
                        row.noteOutcome(false)
                    return
                }
                row.failureText = ""
                row.attemptedConnect = false
            }

            function onPairedChanged() {
                if (row.device)
                    row.noteOutcome(row.device.paired)
            }

            function onPairingChanged() {
                if (!row.device || row.device.pairing)
                    return
                // The flag dropping is the end of the attempt, successful or not.
                row.noteOutcome(!!row.device.paired)
            }
        }
    }
}

