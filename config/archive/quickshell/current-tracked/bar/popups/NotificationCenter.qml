import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration
import "."
import "../notifications"

Scope {
    id: root

    property bool open: false
    property var notificationPanelWindow: null
    property bool dnd: false
    property var barRef: null
    property var collapsedGroups: ({})
    property int unreadCount: 0
    property var entries: []
    property var groupList: []
    property var toastEntries: []

    readonly property int maxToastEntries: 3
    readonly property int maxStoredEntries: 80

    function pushToast(entry) {
        if (!entry)
            return

        const without = toastEntries.filter(item => item.id !== entry.id)
        toastEntries = [entry].concat(without).slice(0, maxToastEntries)
    }

    function removeToast(id) {
        toastEntries = toastEntries.filter(item => item.id !== id)
    }

    function shouldPlaySound(notification) {
        if (root.dnd || notification.lastGeneration)
            return false

        const hints = notification.hints ?? {}
        if (hints["x-canonical-private-synchronous"])
            return false
        if (hints["transient"] === true)
            return false

        return true
    }

    function playNotificationSound() {
        notificationSoundProcess.running = false
        notificationSoundProcess.running = true
    }

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    readonly property bool anyGroupExpanded: {
        for (let i = 0; i < groupList.length; i++) {
            if (!isGroupCollapsed(groupList[i].appName))
                return true
        }
        return false
    }

    signal closed()
    signal requestOpen()

    function close() {
        if (!open)
            return
        closed()
    }

    function formatAppName(name) {
        const raw = (name ?? "").trim()
        if (raw.length === 0)
            return "Unknown"
        return raw
            .replace(/[-_]+/g, " ")
            .split(/\s+/)
            .filter(part => part.length > 0)
            .map(part => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
            .join(" ")
    }

    function isMediaKeyIcon(icon) {
        return (icon ?? "").includes("music.svg")
    }

    function resolveEntryIcon(notification, previousIcon) {
        const icon = (notification.appIcon ?? "").trim()
        if (icon.length > 0)
            return icon
        if (isMediaKeyIcon(previousIcon))
            return previousIcon
        return ""
    }

    function makeEntry(notification) {
        return {
            id: notification.id,
            summary: notification.summary ?? "",
            body: notification.body ?? "",
            appName: formatAppName(notification.appName),
            appIcon: resolveEntryIcon(notification, ""),
            image: notification.image ?? "",
            receivedAt: Date.now(),
            read: false,
            ref: notification,
        }
    }

    function isGroupCollapsed(appName) {
        return collapsedGroups[appName] === true
    }

    function toggleGroupCollapsed(appName) {
        const copy = Object.assign({}, collapsedGroups)
        copy[appName] = !isGroupCollapsed(appName)
        collapsedGroups = copy
    }

    function collapseAllGroups() {
        const copy = {}
        for (let i = 0; i < groupList.length; i++)
            copy[groupList[i].appName] = true
        collapsedGroups = copy
    }

    function expandAllGroups() {
        collapsedGroups = {}
    }

    function normalizeFilePath(value) {
        const raw = (value ?? "").trim()
        if (raw.length === 0)
            return ""
        if (raw.startsWith("file://"))
            return raw.slice(7)
        return raw
    }

    function isScreenshotEntry(entry) {
        if (!entry)
            return false

        const source = entry.ref ?? entry
        const app = (entry.appName ?? source.appName ?? "").toLowerCase()
        const summary = (entry.summary ?? source.summary ?? "").toLowerCase()

        if (app.includes("grimblast"))
            return true
        if (summary.startsWith("screenshot"))
            return true

        return resolveScreenshotPath(entry).length > 0
    }

    function resolveScreenshotPath(entry) {
        if (!entry)
            return ""

        const source = entry.ref ?? entry
        const candidates = [
            normalizeFilePath(entry.image ?? source.image),
            normalizeFilePath(entry.appIcon ?? source.appIcon),
            (entry.body ?? source.body ?? "").trim(),
        ]

        for (let i = 0; i < candidates.length; i++) {
            const candidate = candidates[i]
            if (candidate.startsWith("/") && /\.(png|jpe?g|webp|gif|bmp|avif|heic|tiff)$/i.test(candidate))
                return candidate
        }

        const body = (entry.body ?? source.body ?? "")
        const savedMatch = body.match(/saved to (.+\.(?:png|jpe?g|webp|gif|bmp|avif|heic|tiff))/i)
        if (savedMatch)
            return savedMatch[1]

        const basename = body.match(/^[\w.-]+\.(?:png|jpe?g|webp|gif|bmp|avif|heic|tiff)$/i)
        if (basename)
            return basename[0]

        return ""
    }

    function openScreenshot(entry) {
        const path = resolveScreenshotPath(entry)
        if (path.length === 0)
            return false

        openImageProcess.pathArg = path
        openImageProcess.running = false
        openImageProcess.running = true
        return true
    }

    function markEntryRead(id) {
        const idx = entries.findIndex(item => item.id === id)
        if (idx < 0 || entries[idx].read)
            return
        entries[idx].read = true
        entries = entries.slice()
        rebuildGroups()
        schedulePersist()
    }

    function activateEntry(id) {
        const entry = entries.find(item => item.id === id)
        if (!entry)
            return

        if (isScreenshotEntry(entry))
            openScreenshot(entry)

        markEntryRead(id)
    }

    function syncEntryFields(entry, notification) {
        entry.summary = notification.summary ?? ""
        entry.body = notification.body ?? ""
        entry.image = notification.image ?? ""
        entry.appIcon = resolveEntryIcon(notification, entry.appIcon)
        const name = notification.appName ?? ""
        if (name.length > 0)
            entry.appName = formatAppName(name)
    }

    function syncEntry(entry, notification) {
        syncEntryFields(entry, notification)
        rebuildGroups()
        schedulePersist()
    }

    function serializeEntries(list) {
        const sorted = list.slice().sort((a, b) => b.receivedAt - a.receivedAt)
        const capped = sorted.slice(0, maxStoredEntries)
        const out = []
        for (let i = 0; i < capped.length; i++) {
            const e = capped[i]
            out.push({
                id: e.id,
                summary: e.summary ?? "",
                body: e.body ?? "",
                appName: formatAppName(e.appName),
                appIcon: e.appIcon ?? "",
                image: e.image ?? "",
                receivedAt: e.receivedAt ?? 0,
                read: e.read ?? false,
            })
        }
        return out
    }

    function deserializeEntries(list) {
        if (!list || list.length === 0)
            return []
        const out = []
        for (let i = 0; i < list.length; i++) {
            const e = list[i]
            out.push({
                id: e.id,
                summary: e.summary ?? "",
                body: e.body ?? "",
                appName: formatAppName(e.appName),
                appIcon: e.appIcon ?? "",
                image: e.image ?? "",
                receivedAt: e.receivedAt ?? 0,
                read: e.read ?? false,
                ref: null,
            })
        }
        return out
    }

    function mergeEntries(stored, live) {
        const byId = {}
        for (let i = 0; i < stored.length; i++)
            byId[stored[i].id] = stored[i]
        for (let i = 0; i < live.length; i++) {
            const e = live[i]
            if (byId[e.id]) {
                byId[e.id].ref = e.ref ?? byId[e.id].ref
                if (e.ref)
                    syncEntryFields(byId[e.id], e.ref)
                else {
                    byId[e.id].summary = e.summary ?? byId[e.id].summary
                    byId[e.id].body = e.body ?? byId[e.id].body
                    byId[e.id].image = e.image ?? byId[e.id].image
                    byId[e.id].appIcon = e.appIcon ?? byId[e.id].appIcon
                    byId[e.id].appName = formatAppName(e.appName ?? byId[e.id].appName)
                    byId[e.id].receivedAt = Math.max(byId[e.id].receivedAt, e.receivedAt ?? 0)
                }
            } else {
                byId[e.id] = e
            }
        }
        const merged = Object.keys(byId).map(key => byId[key])
        merged.sort((a, b) => b.receivedAt - a.receivedAt)
        return merged
    }

    function restoreFromStore() {
        if (!notificationStore.loaded)
            return
        root.dnd = notificationStoreAdapter.dnd
        const stored = deserializeEntries(notificationStoreAdapter.notifications)
        entries = mergeEntries(stored, entries)
        if (unreadCount === 0)
            unreadCount = notificationStoreAdapter.unreadCount
        rebuildGroups()
    }

    function persistState() {
        if (!notificationStore.loaded)
            return
        notificationStoreAdapter.dnd = root.dnd
        notificationStoreAdapter.unreadCount = root.unreadCount
        notificationStoreAdapter.notifications = serializeEntries(entries)
        notificationStore.writeAdapter()
    }

    function schedulePersist() {
        persistTimer.restart()
    }

    function attachNotificationSignals(entry, notification) {
        const sync = () => syncEntry(entry, notification)
        if (entry._signalsAttached)
            return sync
        notification.summaryChanged.connect(sync)
        notification.bodyChanged.connect(sync)
        notification.imageChanged.connect(sync)
        notification.appIconChanged.connect(sync)
        notification.appNameChanged.connect(sync)
        entry._signalsAttached = true
        return sync
    }

    function ingest(notification) {
        const fromReload = notification.lastGeneration === true
        let entry = entries.find(item => item.id === notification.id)

        if (entry) {
            entry.ref = notification
            const sync = attachNotificationSignals(entry, notification)
            sync()
            Qt.callLater(sync)
            schedulePersist()
            return
        }

        entry = makeEntry(notification)
        const sync = attachNotificationSignals(entry, notification)
        entries = entries.concat([entry])
        sync()
        Qt.callLater(sync)

        if (!fromReload && !open)
            unreadCount++

        if (!fromReload && !dnd && !open)
            pushToast(entry)

        if (shouldPlaySound(notification))
            playNotificationSound()

        rebuildGroups()
        schedulePersist()
    }

    function rebuildGroups() {
        const map = {}

        for (let i = 0; i < entries.length; i++) {
            const entry = entries[i]
            const name = entry.appName.length > 0 ? entry.appName : "Unknown"

            if (!map[name]) {
                map[name] = {
                    appName: name,
                    appIcon: entry.appIcon,
                    items: [],
                    latestAt: 0,
                }
            }

            if (!map[name].appIcon || isMediaKeyIcon(entry.appIcon))
                map[name].appIcon = entry.appIcon

            map[name].items.push(entry)
            map[name].latestAt = Math.max(map[name].latestAt, entry.receivedAt)
        }

        const groups = Object.keys(map).map(key => map[key])
        for (let g = 0; g < groups.length; g++)
            groups[g].items.sort((a, b) => b.receivedAt - a.receivedAt)

        groups.sort((a, b) => b.latestAt - a.latestAt)
        groupList = groups
    }

    function clearAll() {
        for (let i = 0; i < entries.length; i++) {
            if (entries[i].ref)
                entries[i].ref.dismiss()
        }
        entries = []
        groupList = []
        toastEntries = []
        schedulePersist()
    }

    function formatClockTime(timestamp) {
        if (!timestamp || timestamp <= 0)
            return ""
        const d = new Date(timestamp)
        const h = d.getHours().toString().padStart(2, "0")
        const m = d.getMinutes().toString().padStart(2, "0")
        return h + ":" + m
    }

    onDndChanged: schedulePersist()

    onOpenChanged: {
        if (open) {
            toastEntries = []
            unreadCount = 0
            for (let i = 0; i < entries.length; i++) {
                const entry = entries[i]
                if (entry.ref)
                    syncEntryFields(entry, entry.ref)
            }
            rebuildGroups()
            schedulePersist()
        }
    }

    Timer {
        id: persistTimer
        interval: 400
        onTriggered: root.persistState()
    }

    Process {
        id: notificationSoundProcess
        running: false
        command: ["sh", Quickshell.shellPath("scripts/play-notification-sound.sh")]
    }

    Process {
        id: openImageProcess
        property string pathArg: ""
        running: false
        command: ["sh", Quickshell.shellPath("scripts/open-image.sh"), pathArg]
    }

    Timer {
        interval: 60000
        running: root.entries.length > 0
        repeat: true
        onTriggered: root.rebuildGroups()
    }

    FileView {
        id: notificationStore
        path: Quickshell.dataPath("notifications.json")
        watchChanges: false
        atomicWrites: true
        onLoaded: root.restoreFromStore()

        JsonAdapter {
            id: notificationStoreAdapter
            property bool dnd: false
            property int unreadCount: 0
            property var notifications: []
        }
    }

    PopupDismissGrab {
        active: root.open
        panelWindow: root.notificationPanelWindow
        barRef: root.barRef
        screen: root.activeScreen
        onDismissed: root.close()
    }

    NotificationToastStack {
        toastEntries: root.toastEntries
        panelOpen: root.open
        screen: root.activeScreen
        onToastActivated: entry => {
            if (root.isScreenshotEntry(entry)) {
                root.openScreenshot(entry)
                root.markEntryRead(entry.id)
                root.removeToast(entry.id)
                return
            }

            root.removeToast(entry.id)
            root.requestOpen()
        }
        onToastDismissed: id => {
            const entry = root.entries.find(item => item.id === id)
            if (entry?.ref)
                entry.ref.dismiss()
            root.removeToast(id)
        }
        onToastExpired: id => root.removeToast(id)
    }

    LazyLoader {
        active: root.open

        Scope {
            PanelWindow {
                id: panelWindow
                screen: root.activeScreen
                visible: root.open && root.activeScreen !== null
                color: "transparent"
                aboveWindows: true
                focusable: false
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell_notifications"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                Component.onCompleted: root.notificationPanelWindow = panelWindow
                Component.onDestruction: {
                    if (root.notificationPanelWindow === panelWindow)
                        root.notificationPanelWindow = null
                }

                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: BarMetrics.popupTopMargin
                    right: BarMetrics.popupRightMargin(root.activeScreen)
                }

                implicitWidth: BarMetrics.notificationPanelWidth
                implicitHeight: BarMetrics.notificationPanelExpandedHeight
                width: implicitWidth
                height: implicitHeight

                // Fractional-scale guard: on a non-integer monitor scale, a single
                // static commit can land before the compositor's scale event,
                // rendering the surface at scale 1.0 ("scaled down"). Pumping a few
                // frames after the surface appears forces a recommit at the correct
                // scale once the event arrives.
                property int scalePump: 0

                onVisibleChanged: {
                    if (visible) {
                        scalePump = 0
                        scalePumpTimer.start()
                    } else {
                        scalePumpTimer.stop()
                    }
                }

                Timer {
                    id: scalePumpTimer
                    interval: 16
                    repeat: true
                    onTriggered: {
                        panelWindow.scalePump++
                        if (panelWindow.scalePump > 8)
                            stop()
                    }
                }

                Item {
                    id: panelShell
                    anchors.fill: parent
                    implicitWidth: BarMetrics.notificationPanelWidth
                    implicitHeight: BarMetrics.notificationPanelExpandedHeight

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: Colors.notificationPanelBackground
                        clip: true

                        // Repaints during the scale-pump window to force recommits.
                        Rectangle {
                            width: 1
                            height: 1
                            opacity: 0.01
                            color: panelWindow.scalePump % 2 === 0 ? "#010101" : "#020202"
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: BarMetrics.notificationPanelHeaderHeight
                                spacing: 10

                                Text {
                                    Layout.fillWidth: true
                                    text: "Notifications"
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                    color: Colors.textPrimary
                                }

                                ColumnLayout {
                                    spacing: 4

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "Do Not Disturb"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 10
                                        color: Colors.textMuted
                                    }

                                    Rectangle {
                                        width: 44
                                        height: 24
                                        radius: 12
                                        color: root.dnd
                                            ? Colors.notificationDndOn
                                            : Colors.notificationDndTrack

                                        Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 9
                                            y: 3
                                            x: root.dnd ? parent.width - width - 3 : 3
                                            color: root.dnd
                                                ? Colors.notificationDndThumb
                                                : Colors.textMuted

                                            Behavior on x {
                                                NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.dnd = !root.dnd
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: clearLabel.implicitWidth + 22
                                    Layout.preferredHeight: 30
                                    radius: 8
                                    color: clearHover.hovered
                                        ? Colors.notificationCardHover
                                        : "transparent"
                                    border.color: Colors.notificationClearBorder
                                    border.width: 1

                                    Text {
                                        id: clearLabel
                                        anchors.centerIn: parent
                                        text: "Clear"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: Colors.textSecondary
                                    }

                                    HoverHandler { id: clearHover }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.clearAll()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: Colors.separator
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: BarMetrics.notificationListHeight

                                ListView {
                                    id: groupListView
                                    anchors.fill: parent
                                    clip: true
                                    spacing: 14
                                    interactive: contentHeight > height

                                    model: ScriptModel {
                                        objectProp: "appName"
                                        values: root.groupList
                                    }

                                    delegate: Item {
                                        required property var modelData

                                        width: groupListView.width
                                        height: group.implicitHeight

                                        NotificationGroup {
                                            id: group
                                            width: parent.width
                                            appName: modelData.appName
                                            appIcon: modelData.appIcon
                                            items: modelData.items
                                            collapsed: root.isGroupCollapsed(modelData.appName)
                                            formatClockTime: root.formatClockTime
                                            activateHandler: id => root.activateEntry(id)
                                            toggleCollapsed: appName => root.toggleGroupCollapsed(appName)
                                        }
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    visible: root.groupList.length === 0

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "No notifications"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: Colors.textSecondary
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "You're all caught up"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 12
                                        color: Colors.textMuted
                                    }
                                }
                            }

                            Rectangle {
                                visible: root.groupList.length > 1
                                Layout.fillWidth: true
                                Layout.preferredHeight: BarMetrics.notificationPanelFooterHeight
                                radius: 8
                                color: collapseHover.hovered
                                    ? Colors.notificationCardHover
                                    : "transparent"

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Text {
                                        text: root.anyGroupExpanded ? "Show less" : "Show more"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 12
                                        color: Colors.textSecondary
                                    }

                                    Text {
                                        text: root.anyGroupExpanded ? "\u25b4" : "\u25be"
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 10
                                        color: Colors.textMuted
                                    }
                                }

                                HoverHandler { id: collapseHover }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.anyGroupExpanded)
                                            root.collapseAllGroups()
                                        else
                                            root.expandAllGroups()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
