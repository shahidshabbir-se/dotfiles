pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.shared.theme
import "."

// Full Omarchy-shaped network panel: hero, stats, band, DNS, wifi list.
// Backend: features/bar/network/scripts/qs-network
Item {
    id: root

    function isSecured(security) {
        if (!security)
            return false
        const s = String(security).toUpperCase()
        return s !== "--" && s.indexOf("OPEN") < 0 && s !== "NOPASS"
    }

    function signalBars(strength) {
        const s = Math.max(0, Math.min(100, Number(strength) || 0))
        if (s <= 0)
            return 0
        if (s < 25)
            return 1
        if (s < 50)
            return 2
        if (s < 75)
            return 3
        return 4
    }

    function formatBytes(bytes) {
        const n = Number(bytes)
        if (!isFinite(n) || n < 0)
            return "—"
        if (n < 1024)
            return Math.round(n) + " B"
        if (n < 1024 * 1024)
            return (n / 1024).toFixed(n < 10 * 1024 ? 1 : 0) + " KB"
        if (n < 1024 * 1024 * 1024)
            return (n / (1024 * 1024)).toFixed(n < 10 * 1024 * 1024 ? 1 : 0) + " MB"
        return (n / (1024 * 1024 * 1024)).toFixed(2) + " GB"
    }

    function formatRate(bytesPerSec) {
        const n = Number(bytesPerSec)
        if (!isFinite(n) || n < 0)
            return "—"
        return formatBytes(n) + "/s"
    }

    function formatPing(ms) {
        const value = parseFloat(ms)
        if (!isFinite(value) || value < 0)
            return "—"
        return value.toFixed(value > 0 && value < 10 ? 1 : 0) + " ms"
    }

    function wifiIconFor(strength) {
        const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
        const index = Math.max(0, Math.min(4, Math.ceil(strength / 20) - 1))
        return icons[index]
    }

    function connectionIcon(kind, signalStrength) {
        if (kind === "wifi")
            return wifiIconFor(signalStrength)
        if (kind === "ethernet")
            return "󰈀"
        return "󰤮"
    }

    function bandLabel(band) {
        if (band === "auto")
            return "Auto"
        if (!band)
            return ""
        return band + " GHz"
    }

    function dnsLabel(provider) {
        if (provider === "dhcp")
            return "DHCP"
        if (provider === "cloudflare")
            return "Cloudflare"
        if (provider === "google")
            return "Google"
        return provider || "DNS"
    }


    property bool open: false

    // Absolute path — Qt.resolvedUrl() is flaky across hot-reloads and can
    // leave the panel empty (status stays "disconnected", scan never fills).
    readonly property string backend: {
        const rootDir = Quickshell.shellDir || ""
        if (rootDir.length > 0)
            return rootDir + "/features/bar/network/scripts/qs-network"
        return Qt.resolvedUrl("scripts/qs-network")
            .toString().replace(/^file:\/\//, "")
    }

    width: Constants.networkPopupWidth
    // Height follows the visible pane. Overlay used to hide `shell` while
    // height stayed bound to it → blank / zero-height popup on speed/QR.
    implicitHeight: {
        if (showQr)
            return qrPopup.implicitHeight
        if (showSpeed)
            return speedPopup.implicitHeight
        return Math.min(
            Constants.networkPopupMaxHeight,
            shell.implicitHeight
        )
    }

    property var status: ({
        kind: "disconnected",
        label: "",
        signal: -1,
        frequency: "",
        iface: "",
        ip: "",
        gateway: "",
        prefix: "",
        rx_bytes: 0,
        tx_bytes: 0,
        wifi_enabled: true,
        router_ping_ms: -1,
        internet_ping_ms: -1
    })
    property var wifiNetworks: []
    // Explicit (not readonly-expression) so ListView always sees a new model
    // reference when the scan result changes.
    property var networkSections: []
    property var bandInfo: ({ band: "", available: [], selected: "auto" })
    property var dnsInfo: ({ provider: "dhcp", servers: "", options: ["dhcp", "cloudflare", "google"] })

    property real prevRx: 0
    property real prevTx: 0
    property real prevSampleAt: 0
    property real downloadRate: 0
    property real uploadRate: 0

    property string passwordSsid: ""
    property string passwordText: ""
    property string menuSsid: ""
    property string actionSsid: ""
    property string actionKind: ""
    property string failureSsid: ""
    property string failureReason: ""
    property bool busy: actionKind !== ""
    property bool scanning: false
    property string lastScanError: ""
    // If open requests a force scan while one is mid-flight, run it next.
    property bool pendingForceScan: false
    property int emptyRetryCount: 0

    property bool showQr: false
    property bool showSpeed: false

    readonly property string kind: status.kind || "disconnected"
    readonly property bool wifiOn: status.wifi_enabled !== false
    readonly property bool hasLink: kind === "wifi" || kind === "ethernet"
    readonly property bool canShareWifi: kind === "wifi" && !!status.label
    readonly property bool canRunSpeedTest: hasLink
    readonly property bool canSelectBand: kind === "wifi"
        && Array.isArray(bandInfo.available)
        && bandInfo.available.length > 1

    readonly property string heroIcon: connectionIcon(
        hasLink ? kind : "disconnected",
        status.signal || 0
    )
    readonly property string heroTitle: {
        if (kind === "wifi")
            return status.label || "Wi-Fi"
        if (kind === "ethernet")
            return "Ethernet"
        return wifiOn ? "Disconnected" : "Wi‑Fi off"
    }
    readonly property string heroMeta: {
        if (kind === "wifi" || kind === "ethernet")
            return "CONNECTED"
        if (!wifiOn)
            return "RADIO OFF"
        return "NOT CONNECTED"
    }

    function rebuildSections(list) {
        const known = []
        const other = []
        const nets = Array.isArray(list) ? list : []
        for (let i = 0; i < nets.length; i++) {
            const n = nets[i]
            if (!n || !n.ssid)
                continue
            if (n.known || n.connected)
                known.push(n)
            else
                other.push(n)
        }
        const out = []
        if (known.length)
            out.push({ title: "KNOWN NETWORKS", items: known })
        if (other.length)
            out.push({ title: "OTHER NETWORKS", items: other })
        networkSections = out
    }

    function startIfIdle(proc) {
        if (!proc || proc.running)
            return false
        proc.running = true
        return true
    }

    function runScan(forceRescan) {
        const mode = forceRescan ? "auto" : "no"
        scanning = true
        lastScanError = ""
        scanProc.command = [root.backend, "scan", mode]
        // Command must settle before spawn (hot-reload race).
        Qt.callLater(() => {
            if (!root.open && !forceRescan && !warmPoll.running)
                return
            // Still allow background warm scans when closed.
            if (!scanProc.running)
                scanProc.running = true
        })
    }

    function refreshStatus() {
        statusProc.command = [root.backend, "status"]
        if (statusProc.running)
            return
        Qt.callLater(() => {
            if (!statusProc.running)
                statusProc.running = true
        })
    }

    function refreshScan(forceRescan) {
        forceRescan = !!forceRescan

        // Soft poll: never interrupt an in-flight scan.
        if (!forceRescan) {
            if (scanProc.running || scanning)
                return
            runScan(false)
            return
        }

        // Force (panel open): if busy, queue a force scan for when it finishes,
        // and also hard-restart so we don't wait on a stale cache-only run.
        if (scanProc.running) {
            pendingForceScan = true
            scanProc.running = false
            scanning = false
            Qt.callLater(() => {
                pendingForceScan = false
                runScan(true)
            })
            return
        }

        runScan(true)
    }

    function refreshBand() {
        if (!root.open)
            return
        bandProc.command = [root.backend, "band"]
        if (!bandProc.running)
            Qt.callLater(() => {
                if (root.open && !bandProc.running)
                    bandProc.running = true
            })
    }

    function refreshDns() {
        if (!root.open)
            return
        dnsProc.command = [root.backend, "dns"]
        if (!dnsProc.running)
            Qt.callLater(() => {
                if (root.open && !dnsProc.running)
                    dnsProc.running = true
            })
    }

    function refreshAll(forceRescan) {
        refreshStatus()
        refreshScan(!!forceRescan)
        refreshBand()
        refreshDns()
    }

    // If the panel is open and still empty, keep trying (NM cache can lag).
    function ensureNetworksVisible() {
        if (!root.open)
            return
        if (wifiNetworks.length > 0) {
            emptyRetryCount = 0
            return
        }
        if (emptyRetryCount >= 4)
            return
        emptyRetryCount++
        refreshScan(emptyRetryCount <= 2)
        emptyRetry.interval = emptyRetryCount * 400
        emptyRetry.restart()
    }

    function applyStatus(raw) {
        let next
        try {
            next = JSON.parse(raw || "{}")
        } catch (e) {
            return
        }
        if (!next || typeof next !== "object")
            return

        const now = Date.now()
        const rx = Number(next.rx_bytes || 0)
        const tx = Number(next.tx_bytes || 0)
        const sameIface = prevSampleAt > 0 && next.iface && next.iface === status.iface
        if (sameIface) {
            const dt = Math.max(0.001, (now - prevSampleAt) / 1000)
            if (rx >= prevRx)
                downloadRate = (rx - prevRx) / dt
            if (tx >= prevTx)
                uploadRate = (tx - prevTx) / dt
        } else {
            downloadRate = 0
            uploadRate = 0
        }
        status = next
        prevRx = rx
        prevTx = tx
        prevSampleAt = now
    }

    function applyScan(raw) {
        scanning = false
        lastScanError = ""
        try {
            const list = JSON.parse(raw || "[]")
            if (!Array.isArray(list))
                return
            // Always replace so ListView gets a new model reference.
            wifiNetworks = list.slice()
            rebuildSections(wifiNetworks)

            if (pendingForceScan) {
                pendingForceScan = false
                Qt.callLater(() => root.refreshScan(true))
                return
            }

            // Panel open but still empty → retry a few times instead of
            // forcing the user to close/reopen.
            if (root.open && wifiNetworks.length === 0)
                Qt.callLater(() => root.ensureNetworksVisible())
            else if (wifiNetworks.length > 0)
                emptyRetryCount = 0
        } catch (e) {
            lastScanError = "Bad scan data"
            if (root.open)
                Qt.callLater(() => root.ensureNetworksVisible())
        }
    }

    function applyBand(raw) {
        try {
            bandInfo = JSON.parse(raw || "{}")
        } catch (e) {}
    }

    function applyDns(raw) {
        try {
            dnsInfo = JSON.parse(raw || "{}")
        } catch (e) {}
    }

    function openPassword(ssid) {
        menuSsid = ""
        passwordSsid = ssid
        passwordText = ""
        failureSsid = ""
        failureReason = ""
    }

    function cancelPassword() {
        passwordSsid = ""
        passwordText = ""
    }

    function openMenu(ssid) {
        cancelPassword()
        menuSsid = (menuSsid === ssid) ? "" : ssid
    }

    function closeMenu() {
        menuSsid = ""
    }

    function clearAction() {
        actionSsid = ""
        actionKind = ""
        actionTimeout.stop()
        refreshAll(true)
    }

    function runAction(kind, ssid, stdinText, extraArgs) {
        if (busy)
            return
        // Stop scan churn while NM is associating — competing nmcli calls
        // make connect feel hung and freeze the panel.
        if (scanProc.running)
            scanProc.running = false
        scanning = false

        actionKind = kind
        actionSsid = ssid || ""
        failureSsid = ""
        failureReason = ""
        actionTimeout.restart()

        let args = [backend, kind]
        if (kind === "connect" || kind === "forget")
            args.push(ssid)
        else if (kind === "wifi")
            args = [backend, "wifi", "toggle"]
        else if (kind === "disconnect")
            args = [backend, "disconnect"]
        else if (kind === "band")
            args = [backend, "band"].concat(extraArgs || [])
        else if (kind === "dns")
            args = [backend, "dns"].concat(extraArgs || [])

        if (actionProc.running)
            actionProc.running = false

        // Connect always gets a stdin line (password or empty) then EOF.
        actionProc.stdinPayload = kind === "connect" ? (stdinText || "") : (stdinText || "")
        actionProc.needsStdin = kind === "connect" || (stdinText && stdinText.length > 0)
        actionProc.command = args
        Qt.callLater(() => {
            if (root.actionKind === kind && root.actionSsid === (ssid || ""))
                actionProc.running = true
        })
    }

    function activateRow(net) {
        if (busy || !net)
            return

        // Known / connected: expand action menu (don't auto connect/disconnect).
        if (net.known || net.connected) {
            openMenu(net.ssid)
            return
        }

        // New / unknown network: join flow.
        closeMenu()
        if (isSecured(net.security)) {
            openPassword(net.ssid)
            return
        }
        runAction("connect", net.ssid, "")
    }

    function menuConnect(net) {
        if (!net || busy)
            return
        closeMenu()
        if (net.connected)
            return
        // Known profile — connect without re-prompting password.
        runAction("connect", net.ssid, "")
    }

    function menuDisconnect(net) {
        if (!net || busy)
            return
        closeMenu()
        if (net.connected)
            runAction("disconnect", net.ssid, "")
    }

    function menuForget(net) {
        if (!net || busy)
            return
        closeMenu()
        forgetRow(net)
    }

    function submitPassword() {
        if (!passwordSsid || passwordText.length === 0)
            return
        const psk = passwordText
        passwordText = ""
        runAction("connect", passwordSsid, psk)
    }

    function forgetRow(net) {
        if (net)
            runAction("forget", net.ssid, "")
    }

    function toggleWifi() {
        runAction("wifi", "", "")
    }

    function setBand(band) {
        runAction("band", "", "", [band])
    }

    function setDns(provider) {
        runAction("dns", "", "", [provider])
    }

    function openQr() {
        showSpeed = false
        showQr = true
    }

    function openSpeed() {
        showQr = false
        showSpeed = true
    }

    function closeOverlays() {
        showQr = false
        showSpeed = false
    }

    onOpenChanged: {
        if (open) {
            cancelPassword()
            closeMenu()
            showQr = false
            showSpeed = false
            emptyRetryCount = 0
            // Keep previous list on screen; force a fresh scan underneath.
            refreshAll(true)
            poll.restart()
            // Immediate + delayed empty checks (covers slow NM / race).
            emptyRetry.interval = 350
            emptyRetry.restart()
            entrance.play()
        } else {
            poll.stop()
            emptyRetry.stop()
            pendingForceScan = false
            cancelPassword()
            closeMenu()
            showQr = false
            showSpeed = false
            entrance.reset()
        }
    }

    Component.onCompleted: {
        rebuildSections(wifiNetworks)
        // Warm cache once so first open is rarely empty.
        Qt.callLater(() => {
            root.refreshStatus()
            root.refreshScan(false)
        })
        warmPoll.start()
        if (open) {
            refreshAll(true)
            poll.start()
            entrance.play()
        }
    }

    Process {
        id: statusProc
        command: [root.backend, "status"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyStatus(text)
        }
        stderr: StdioCollector {
            waitForEnd: true
        }
    }

    Process {
        id: scanProc
        command: [root.backend, "scan", "no"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyScan(text)
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (text && text.length) {
                    root.scanning = false
                    root.lastScanError = text.replace(/^qs-network:\s*/, "").trim()
                    if (root.open)
                        Qt.callLater(() => root.ensureNetworksVisible())
                }
            }
        }
        onRunningChanged: {
            if (running)
                return
            // Finished: if we never got stdout (crash/kill), clear spinner + retry.
            Qt.callLater(() => {
                if (scanProc.running)
                    return
                if (root.scanning)
                    root.scanning = false
                if (root.pendingForceScan) {
                    root.pendingForceScan = false
                    root.refreshScan(true)
                } else if (root.open && root.wifiNetworks.length === 0) {
                    root.ensureNetworksVisible()
                }
            })
        }
    }

    Process {
        id: bandProc
        command: [root.backend, "band"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyBand(text)
        }
    }

    Process {
        id: dnsProc
        command: [root.backend, "dns"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.applyDns(text)
        }
    }

    Process {
        id: actionProc
        property string stdinPayload: ""
        property bool needsStdin: false
        // Keep stdin open only for this spawn; closed after the one write.
        stdinEnabled: needsStdin
        onStarted: {
            if (needsStdin) {
                write(stdinPayload + "\n")
                stdinPayload = ""
                // Close stdin so `read` in qs-network gets EOF (otherwise hang).
                needsStdin = false
            }
        }
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                // Success path usually lands here with JSON.
                if (root.actionKind) {
                    root.clearAction()
                    if (root.passwordSsid)
                        root.cancelPassword()
                }
            }
        }
        stderr: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                if (!text || !text.length || !root.actionKind)
                    return
                root.failureSsid = root.actionSsid
                root.failureReason = text.replace(/^qs-network:\s*/, "").trim() || "Failed"
                root.actionSsid = ""
                root.actionKind = ""
                root.actionTimeout.stop()
                if (root.failureReason.toLowerCase().indexOf("failed to connect") >= 0
                    || root.failureReason.toLowerCase().indexOf("password") >= 0
                    || root.failureReason.toLowerCase().indexOf("secrets") >= 0) {
                    if (root.failureSsid)
                        root.openPassword(root.failureSsid)
                }
                root.refreshAll(true)
            }
        }
        onExited: function(exitCode, exitStatus) {
            // Fallback if stdout/stderr collectors didn't clear busy.
            if (!root.actionKind)
                return
            if (exitCode === 0) {
                root.clearAction()
                if (root.passwordSsid)
                    root.cancelPassword()
            } else if (root.actionKind) {
                // stderr handler usually already cleared; belt-and-suspenders.
                root.actionTimeout.stop()
                if (root.actionKind) {
                    root.failureSsid = root.actionSsid
                    if (!root.failureReason)
                        root.failureReason = "Failed"
                    root.actionSsid = ""
                    root.actionKind = ""
                    root.refreshAll(true)
                }
            }
        }
    }

    Timer {
        id: actionTimeout
        interval: 30000
        repeat: false
        onTriggered: {
            if (!root.actionKind)
                return
            // Actually kill the hung nmcli — clearing busy alone left it stuck.
            if (actionProc.running)
                actionProc.running = false
            root.failureSsid = root.actionSsid
            root.failureReason = root.actionKind === "connect"
                ? "Timed out connecting"
                : "Timed out"
            root.actionSsid = ""
            root.actionKind = ""
            root.refreshAll(true)
        }
    }

    // While panel is open: fast status + cached scan.
    Timer {
        id: poll
        interval: 1500
        repeat: true
        property int tick: 0
        onTriggered: {
            if (root.busy)
                return
            root.refreshStatus()
            // Cached scan every ~3s while open (don't abort in-flight).
            if (tick % 2 === 0)
                root.refreshScan(false)
            if (tick % 6 === 0) {
                root.refreshBand()
                root.refreshDns()
            }
            tick++
        }
    }

    // Always-on light keep-alive so the list is warm before first open / after reload.
    Timer {
        id: warmPoll
        interval: 10000
        repeat: true
        onTriggered: {
            if (root.open)
                return
            root.refreshStatus()
            root.refreshScan(false)
        }
    }

    // Retries when the panel is open but the list is still empty.
    Timer {
        id: emptyRetry
        interval: 350
        repeat: false
        onTriggered: root.ensureNetworksVisible()
    }

    // If a scan is marked running for too long (stuck Process), clear and retry.
    Timer {
        id: scanWatchdog
        interval: 10000
        running: root.scanning
        repeat: false
        onTriggered: {
            if (!root.scanning)
                return
            root.scanning = false
            if (scanProc.running)
                scanProc.running = false
            if (root.open)
                Qt.callLater(() => root.refreshScan(true))
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

    opacity: entrance.revealProgress
    scale: Constants.popupFromScale + entrance.revealProgress * (1 - Constants.popupFromScale)

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

    // QR / speed overlays replace main body when open
    WifiQrPopup {
        id: qrPopup
        anchors.top: parent.top
        width: parent.width
        open: root.showQr
        backend: root.backend
        iface: root.status.iface || ""
        connectionName: root.status.label || root.heroTitle
        visible: root.showQr
        z: 2
        onOpenChanged: {
            if (!open && root.showQr)
                root.showQr = false
        }
    }

    SpeedTestPopup {
        id: speedPopup
        anchors.top: parent.top
        width: parent.width
        open: root.showSpeed
        backend: root.backend
        connectionName: root.status.label || root.heroTitle
        visible: root.showSpeed
        z: 2
        onOpenChanged: {
            if (!open && root.showSpeed)
                root.showSpeed = false
        }
    }

    Rectangle {
        id: shell
        visible: !root.showQr && !root.showSpeed
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
                    opacity: root.wifiOn ? 1 : 0.45
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.heroTitle
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeLg
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.heroMeta
                        color: Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.1
                        textFormat: Text.PlainText
                    }
                }

                // QR
                Rectangle {
                    visible: root.canShareWifi
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Constants.buttonRadius
                    color: qrArea.containsMouse
                        ? Colors.surfaceContainerHighest
                        : Colors.surfaceContainerHigh
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰐲"
                        color: Colors.surfaceForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Constants.fontSizeLg
                    }

                    MouseArea {
                        id: qrArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openQr()
                    }
                }

                // Speedtest
                Rectangle {
                    visible: root.canRunSpeedTest
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: Constants.buttonRadius
                    color: speedArea.containsMouse
                        ? Colors.surfaceContainerHighest
                        : Colors.surfaceContainerHigh
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰓅"
                        color: Colors.surfaceForeground
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Constants.fontSizeLg
                    }

                    MouseArea {
                        id: speedArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openSpeed()
                    }
                }

                // Wi-Fi radio — Omarchy ToggleSwitch proportions / motion
                ToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: root.wifiOn
                    onToggled: root.toggleWifi()
                }
            }

            // ---------- Stats ----------
            // Four continuous columns so vertical rules run full height (no
            // broken per-cell dividers / double gaps between rows).
            RowLayout {
                id: statsRow
                visible: root.hasLink
                Layout.fillWidth: true
                Layout.topMargin: Constants.spacingLg
                spacing: 0

                // [icon]  title
                //         value
                component StatCell: Item {
                    property string label: ""
                    property string value: ""
                    property string icon: ""
                    property string action: ""

                    Layout.fillWidth: true
                    implicitHeight: Math.max(32, cellRow.implicitHeight)

                    RowLayout {
                        id: cellRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Constants.spacingSm

                        Item {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignVCenter

                            ThemeIcon {
                                anchors.centerIn: parent
                                visible: icon.length > 0
                                name: icon.length > 0 ? icon : "activity"
                                iconSize: 16
                                iconColor: Colors.outline
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: label
                                color: Colors.outline
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeXs
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.4
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }

                            Text {
                                Layout.fillWidth: true
                                text: value
                                color: action === "speed"
                                    ? Colors.primary
                                    : Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: action === "speed" && root.canRunSpeedTest
                        cursorShape: enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor
                        onClicked: root.openSpeed()
                    }
                }

                component StatDivider: Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Constants.borderWidth
                    Layout.leftMargin: Constants.spacingMd
                    Layout.rightMargin: Constants.spacingMd
                    color: Colors.surfaceContainerHighest
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Constants.spacingSm

                    StatCell {
                        label: "Ping"
                        value: formatPing(root.status.internet_ping_ms)
                        icon: "activity"
                    }
                    StatCell {
                        label: "Downloaded"
                        value: formatBytes(root.status.rx_bytes || 0)
                        icon: "circle-arrow-down"
                        action: "speed"
                    }
                }

                StatDivider {}

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Constants.spacingSm

                    StatCell {
                        label: "Router"
                        value: formatPing(root.status.router_ping_ms)
                        icon: "router"
                    }
                    StatCell {
                        label: "Uploaded"
                        value: formatBytes(root.status.tx_bytes || 0)
                        icon: "circle-arrow-up"
                        action: "speed"
                    }
                }

                StatDivider {}

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Constants.spacingSm

                    StatCell {
                        label: "Receiving"
                        value: formatRate(root.downloadRate)
                        icon: "arrow-down-to-line"
                        action: "speed"
                    }
                    StatCell {
                        label: "IP Address"
                        value: root.status.ip || "—"
                        icon: "globe"
                    }
                }

                StatDivider {}

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Constants.spacingSm

                    StatCell {
                        label: "Sending"
                        value: formatRate(root.uploadRate)
                        icon: "arrow-up-to-line"
                        action: "speed"
                    }
                    StatCell {
                        label: "Gateway"
                        value: root.status.gateway || "—"
                        icon: "router"
                    }
                }
            }

            // ---------- Band ----------
            ColumnLayout {
                visible: root.canSelectBand
                Layout.fillWidth: true
                spacing: Constants.spacingSm

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: root.bandInfo.selected === "auto" && root.bandInfo.band
                            ? "WI‑FI BAND: " + String(root.bandInfo.band).toUpperCase() + "GHZ"
                            : "WI‑FI BAND"
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.8
                        textFormat: Text.PlainText
                    }

                    Text {
                        text: "AUTOMATIC"
                        color: Colors.surfaceVariantForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 22
                        radius: height / 2
                        color: root.bandInfo.selected === "auto"
                            ? Colors.primary
                            : Colors.surfaceContainerHighest

                        Rectangle {
                            width: 16
                            height: 16
                            radius: width / 2
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.bandInfo.selected === "auto"
                                ? parent.width - width - 3
                                : 3
                            color: root.bandInfo.selected === "auto"
                                ? Colors.primaryForeground
                                : Colors.surfaceVariantForeground
                            Behavior on x {
                                NumberAnimation {
                                    duration: Constants.animationNormal
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.bandInfo.selected === "auto") {
                                    if (root.bandInfo.band)
                                        root.setBand(root.bandInfo.band)
                                } else {
                                    root.setBand("auto")
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    visible: root.bandInfo.selected !== "auto"
                    Layout.fillWidth: true
                    spacing: Constants.spacingSm

                    Repeater {
                        model: root.bandInfo.available || []

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Constants.buttonSize
                            radius: Constants.buttonRadius
                            color: root.bandInfo.selected === modelData
                                ? Tokens.withAlpha(Colors.primary, 0.18)
                                : (bandPillArea.containsMouse
                                    ? Colors.surfaceContainer
                                    : Colors.surfaceContainerHigh)
                            border.width: root.bandInfo.selected === modelData
                                ? Constants.borderWidth
                                : 0
                            border.color: Tokens.withAlpha(Colors.primary, 0.4)

                            Text {
                                anchors.centerIn: parent
                                text: bandLabel(modelData)
                                color: root.bandInfo.selected === modelData
                                    ? Colors.primary
                                    : Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                                font.weight: Font.Medium
                                textFormat: Text.PlainText
                            }

                            MouseArea {
                                id: bandPillArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setBand(modelData)
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible: root.canSelectBand
                Layout.fillWidth: true
                Layout.topMargin: Constants.spacingXs
                Layout.bottomMargin: Constants.spacingXs
                height: Constants.borderWidth
                color: Colors.surfaceContainerHighest
            }

            // ---------- DNS ----------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Constants.spacingSm

                Text {
                    text: "DNS"
                    color: Colors.outline
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeSm
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                    textFormat: Text.PlainText
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Constants.spacingSm

                    Repeater {
                        model: root.dnsInfo.options || ["dhcp", "cloudflare", "google"]

                        Rectangle {
                            required property var modelData
                            readonly property bool active: root.dnsInfo.provider === modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: Constants.buttonSize + 4
                            radius: Constants.panelRadius
                            color: active
                                ? Tokens.withAlpha(Colors.primary, 0.14)
                                : (dnsPillArea.containsMouse
                                    ? Colors.surfaceContainer
                                    : "transparent")
                            border.width: Constants.borderWidth
                            border.color: active
                                ? Tokens.withAlpha(Colors.primary, 0.55)
                                : Colors.surfaceContainerHighest

                            // Label centered; check on the right (mock layout).
                            Text {
                                anchors.centerIn: parent
                                text: dnsLabel(modelData)
                                color: active
                                    ? Colors.primary
                                    : Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeSm
                                font.weight: Font.Medium
                                textFormat: Text.PlainText
                            }

                            ThemeIcon {
                                visible: active
                                anchors.right: parent.right
                                anchors.rightMargin: Constants.paddingMd
                                anchors.verticalCenter: parent.verticalCenter
                                name: "circle-check"
                                iconSize: 14
                                iconColor: Colors.primary
                            }

                            MouseArea {
                                id: dnsPillArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setDns(modelData)
                            }
                        }
                    }
                }
            }

            // ---------- Network list (card groups, mock layout) ----------
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(
                    contentHeight,
                    Constants.networkPopupMaxHeight - 220
                )
                clip: true
                // Gap between KNOWN NETWORKS and OTHER NETWORKS cards.
                spacing: Constants.spacingLg + Constants.spacingXs
                model: root.networkSections
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: list.contentHeight > list.height
                        ? ScrollBar.AsNeeded
                        : ScrollBar.AlwaysOff
                }

                delegate: ColumnLayout {
                    id: sectionWrap
                    required property var modelData
                    width: list.width
                    spacing: Constants.spacingSm

                    Text {
                        text: sectionWrap.modelData.title
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeXs
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.9
                        textFormat: Text.PlainText
                    }

                    // ClippingRectangle clips children to the rounded corners
                    // (plain Rectangle + clip only masks the axis-aligned box).
                    ClippingRectangle {
                        Layout.fillWidth: true
                        // No extra vertical pad — first/last row hover meets the radius edge.
                        implicitHeight: sectionCol.implicitHeight
                        radius: Constants.panelRadius
                        color: Colors.surfaceContainer
                        border.width: Constants.borderWidth
                        border.color: Colors.surfaceContainerHighest

                        ColumnLayout {
                            id: sectionCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 0

                            Repeater {
                                model: sectionWrap.modelData.items

                                Item {
                                    id: netRow
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    // Row height from content; separator is painted *inside*
                                    // the hover rect so it never sits in a non-hover gap.
                                    readonly property bool showSep:
                                        index < sectionWrap.modelData.items.length - 1
                                    readonly property int sepInset:
                                        Constants.paddingMd + 22 + Constants.spacingMd
                                    readonly property bool isBusy:
                                        root.actionSsid === modelData.ssid && root.busy
                                    readonly property bool isFailed:
                                        root.failureSsid === modelData.ssid
                                        && root.failureReason !== ""
                                    readonly property bool passwordOpen:
                                        root.passwordSsid === modelData.ssid
                                    readonly property bool menuOpen:
                                        root.menuSsid === modelData.ssid
                                    // actionMenu + passwordBox live *inside* rowBody, so their
                                    // height is already in rowBody.implicitHeight — don't add again.
                                    implicitHeight: Math.max(
                                        52,
                                        rowBody.implicitHeight + Constants.paddingMd * 2
                                    ) + (showSep ? 1 : 0)
                                    readonly property string statusText: {
                                        if (isBusy) {
                                            if (root.actionKind === "connect")
                                                return "Connecting…"
                                            if (root.actionKind === "disconnect")
                                                return "Disconnecting…"
                                            if (root.actionKind === "forget")
                                                return "Forgetting…"
                                            return "Working…"
                                        }
                                        if (isFailed)
                                            return root.failureReason
                                        if (modelData.connected)
                                            return "Connected"
                                        if (modelData.known)
                                            return "Saved"
                                        if (isSecured(modelData.security))
                                            return "Secured"
                                        return "Open"
                                    }

                                    // Full-row hover / active fill (edge to edge).
                                    Rectangle {
                                        anchors.fill: parent
                                        color: {
                                            if (modelData.connected)
                                                return Tokens.withAlpha(Colors.primary, 0.10)
                                            if (rowHover.containsMouse || passwordOpen || menuOpen)
                                                return Colors.surfaceContainerHigh
                                            return "transparent"
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: Constants.animationFast }
                                        }
                                    }

                                    ColumnLayout {
                                        id: rowBody
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.leftMargin: Constants.paddingMd
                                        anchors.rightMargin: Constants.paddingMd
                                        anchors.topMargin: Constants.paddingMd
                                        // Tight bottom pad when expanded; full pad when collapsed.
                                        anchors.bottomMargin: (menuOpen || passwordOpen)
                                            ? Constants.spacingSm
                                            : Constants.paddingMd
                                        spacing: Constants.spacingSm

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: Constants.spacingMd

                                            // Strength bars (0–4) from signal % — no disc bg
                                            Item {
                                                id: bars
                                                Layout.preferredWidth: 22
                                                Layout.preferredHeight: 22
                                                Layout.alignment: Qt.AlignVCenter
                                                readonly property int filled:
                                                    signalBars(modelData.signal)
                                                readonly property int barMaxH: 18

                                                Row {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    anchors.bottom: parent.bottom
                                                    anchors.bottomMargin: 2
                                                    spacing: 2.5
                                                    height: bars.barMaxH

                                                    Repeater {
                                                        model: Constants.networkSignalBars
                                                        Item {
                                                            required property int index
                                                            width: 3.5
                                                            height: bars.barMaxH

                                                            Rectangle {
                                                                anchors.bottom: parent.bottom
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                width: parent.width
                                                                height: 6 + index * 4
                                                                radius: Constants.panelRadius
                                                                color: index < bars.filled
                                                                    ? (modelData.connected
                                                                        ? Colors.primary
                                                                        : Colors.surfaceForeground)
                                                                    : (modelData.connected
                                                                        ? Tokens.withAlpha(Colors.primary, 0.28)
                                                                        : Colors.surfaceContainerHigh)
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.alignment: Qt.AlignVCenter
                                                spacing: 1

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.ssid
                                                    color: Colors.surfaceForeground
                                                    font.family: Constants.fontFamily
                                                    font.pixelSize: Constants.fontSizeMd
                                                    font.weight: Font.Medium
                                                    elide: Text.ElideRight
                                                    textFormat: Text.PlainText
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: netRow.statusText
                                                    color: netRow.isFailed
                                                        ? Colors.error
                                                        : modelData.connected
                                                            ? Colors.primary
                                                            : Colors.surfaceVariantForeground
                                                    font.family: Constants.fontFamily
                                                    font.pixelSize: Constants.fontSizeSm
                                                    elide: Text.ElideRight
                                                    textFormat: Text.PlainText
                                                }
                                            }

                                            ThemeIcon {
                                                Layout.alignment: Qt.AlignVCenter
                                                name: "chevron-right"
                                                iconSize: 16
                                                iconColor: Colors.outline
                                                opacity: 0.7
                                                rotation: netRow.menuOpen ? 90 : 0

                                                Behavior on rotation {
                                                    NumberAnimation {
                                                        duration: Constants.animationFast
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                            }
                                        }

                                        // Known-network action menu (Connect / Disconnect / Forget)
                                        ColumnLayout {
                                            id: actionMenu
                                            visible: netRow.menuOpen
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Rectangle {
                                                Layout.fillWidth: true
                                                implicitHeight: menuCol.implicitHeight + 6
                                                radius: Constants.buttonRadius
                                                color: Colors.surfaceContainerLowest
                                                border.width: Constants.borderWidth
                                                border.color: Colors.surfaceContainerHighest

                                                ColumnLayout {
                                                    id: menuCol
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    anchors.top: parent.top
                                                    anchors.margins: 3
                                                    spacing: 1

                                                    // Connect (saved, not connected)
                                                    Rectangle {
                                                        visible: !modelData.connected
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 32
                                                        radius: Constants.panelRadius
                                                        color: connectHover.containsMouse
                                                            ? Colors.surfaceContainerHigh
                                                            : "transparent"

                                                        Text {
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: Constants.paddingMd
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: "Connect"
                                                            color: Colors.primary
                                                            font.family: Constants.fontFamily
                                                            font.pixelSize: Constants.fontSizeSm
                                                            font.weight: Font.Medium
                                                            textFormat: Text.PlainText
                                                        }

                                                        MouseArea {
                                                            id: connectHover
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root.menuConnect(modelData)
                                                        }
                                                    }

                                                    // Disconnect (connected)
                                                    Rectangle {
                                                        visible: modelData.connected
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 32
                                                        radius: Constants.panelRadius
                                                        color: disconnectHover.containsMouse
                                                            ? Colors.surfaceContainerHigh
                                                            : "transparent"

                                                        Text {
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: Constants.paddingMd
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: "Disconnect"
                                                            color: Colors.surfaceForeground
                                                            font.family: Constants.fontFamily
                                                            font.pixelSize: Constants.fontSizeSm
                                                            font.weight: Font.Medium
                                                            textFormat: Text.PlainText
                                                        }

                                                        MouseArea {
                                                            id: disconnectHover
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root.menuDisconnect(modelData)
                                                        }
                                                    }

                                                    // Forget (known or connected)
                                                    Rectangle {
                                                        visible: modelData.known || modelData.connected
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 32
                                                        radius: Constants.panelRadius
                                                        color: forgetMenuHover.containsMouse
                                                            ? Tokens.withAlpha(Colors.error, 0.12)
                                                            : "transparent"

                                                        Text {
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: Constants.paddingMd
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: "Forget"
                                                            color: Colors.error
                                                            font.family: Constants.fontFamily
                                                            font.pixelSize: Constants.fontSizeSm
                                                            font.weight: Font.Medium
                                                            textFormat: Text.PlainText
                                                        }

                                                        MouseArea {
                                                            id: forgetMenuHover
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: root.menuForget(modelData)
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        ColumnLayout {
                                            id: passwordBox
                                            visible: netRow.passwordOpen
                                            Layout.fillWidth: true
                                            spacing: Constants.spacingXs

                                            TextField {
                                                id: passField
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: Constants.buttonSize + 4
                                                echoMode: TextInput.Password
                                                placeholderText: "Password"
                                                text: root.passwordText
                                                color: Colors.surfaceForeground
                                                placeholderTextColor: Colors.outline
                                                font.family: Constants.fontFamily
                                                font.pixelSize: Constants.fontSizeMd
                                                leftPadding: Constants.paddingMd
                                                rightPadding: Constants.paddingMd
                                                selectByMouse: true
                                                onTextChanged: root.passwordText = text
                                                Keys.onReturnPressed: root.submitPassword()
                                                Keys.onEnterPressed: root.submitPassword()
                                                Keys.onEscapePressed: root.cancelPassword()

                                                background: Rectangle {
                                                    radius: Constants.buttonRadius
                                                    color: Colors.surfaceContainerLowest
                                                    border.width: Constants.borderWidth
                                                    border.color: passField.activeFocus
                                                        ? Colors.primary
                                                        : Colors.surfaceContainerHighest
                                                }

                                                Component.onCompleted: {
                                                    if (passwordBox.visible)
                                                        forceActiveFocus()
                                                }
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: Constants.spacingSm
                                                Item { Layout.fillWidth: true }

                                                Rectangle {
                                                    Layout.preferredWidth: cancelLabel.implicitWidth
                                                        + Constants.paddingMd * 2
                                                    Layout.preferredHeight: Constants.buttonSize
                                                    radius: Constants.buttonRadius
                                                    color: cancelArea.containsMouse
                                                        ? Colors.surfaceContainerHighest
                                                        : Colors.surfaceContainerHigh

                                                    Text {
                                                        id: cancelLabel
                                                        anchors.centerIn: parent
                                                        text: "Cancel"
                                                        color: Colors.surfaceForeground
                                                        font.family: Constants.fontFamily
                                                        font.pixelSize: Constants.fontSizeSm
                                                        textFormat: Text.PlainText
                                                    }

                                                    MouseArea {
                                                        id: cancelArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.cancelPassword()
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: joinLabel.implicitWidth
                                                        + Constants.paddingMd * 2
                                                    Layout.preferredHeight: Constants.buttonSize
                                                    radius: Constants.buttonRadius
                                                    color: root.passwordText.length > 0
                                                        ? Colors.primary
                                                        : Colors.surfaceContainerHighest
                                                    opacity: root.passwordText.length > 0 ? 1 : 0.6

                                                    Text {
                                                        id: joinLabel
                                                        anchors.centerIn: parent
                                                        text: "Join"
                                                        color: root.passwordText.length > 0
                                                            ? Colors.primaryForeground
                                                            : Colors.surfaceVariantForeground
                                                        font.family: Constants.fontFamily
                                                        font.pixelSize: Constants.fontSizeSm
                                                        font.weight: Font.DemiBold
                                                        textFormat: Text.PlainText
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        enabled: root.passwordText.length > 0
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.submitPassword()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Inset separator sits on the bottom of the row fill
                                    // (not a sibling outside hover) — starts after icon.
                                    Rectangle {
                                        visible: netRow.showSep
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: netRow.sepInset
                                        height: Constants.borderWidth
                                        color: Colors.surfaceContainerHighest
                                        opacity: 0.7
                                        z: 2
                                    }

                                    MouseArea {
                                        id: rowHover
                                        anchors.fill: parent
                                        anchors.bottomMargin: {
                                            if (passwordOpen)
                                                return passwordBox.height + Constants.spacingSm
                                            if (menuOpen)
                                                return actionMenu.height + Constants.spacingSm
                                            return 0
                                        }
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        enabled: !passwordOpen && !root.busy
                                        z: 1
                                        onClicked: root.activateRow(modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: {
                        if (!root.wifiOn)
                            return "Wi‑Fi is off"
                        if (root.lastScanError.length > 0)
                            return root.lastScanError
                        if (root.scanning || root.wifiNetworks.length === 0)
                            return "Scanning…"
                        return "No networks found"
                    }
                    color: Colors.surfaceVariantForeground
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeMd
                    textFormat: Text.PlainText
                }
            }
        }
    }

}
