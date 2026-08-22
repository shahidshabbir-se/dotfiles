import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.shared.theme
import "NotificationText.js" as NotificationText

Scope {
    id: root

    required property var screen
    property bool barVertical: false
    // Floating bar width — used to right-align popups with the bar edge
    // (same math as Bar LayerPopup).
    property int barWidth: 0
    property int maxVisible: 4
    property int defaultTimeoutMs: 6000
    property int historyLimit: 50

    property bool centerOpen: false
    property bool doNotDisturb: false
    property int unreadCount: 0
    // Deliberately memory-only: history is bounded and cleared on shell reload.
    property var historyEntries: []

    // 8px under the bar; center stays bar-aligned, toast is 8px from screen right.
    readonly property int topOffset: barVertical
        ? Constants.spacingMd
        : Constants.barTopMargin + Constants.barHeight + Constants.spacingMd
    readonly property int rightOffset: barVertical
        ? Constants.spacingMd
        : Math.max(
            Constants.spacingMd,
            Math.round(
                (((screen ? screen.width : 0) - (barWidth > 0 ? barWidth : Constants.barMaxWidth)) / 2)
            )
        )
    readonly property int historyCount: historyEntries.length

    function cleanSingleLine(value, maximumLength) {
        return NotificationText.singleLine(value, maximumLength)
    }

    function cleanBody(value) {
        return NotificationText.body(value)
    }

    function remember(notification) {
        const existingIndex = historyEntries.findIndex(
            item => item.notificationId === notification.id
        )
        const entry = {
            key: String(notification.id),
            notificationId: notification.id,
            appName: cleanSingleLine(notification.appName, 128) || "Notification",
            appIcon: cleanSingleLine(notification.appIcon, 128),
            summary: cleanSingleLine(notification.summary, 512) || "Notification",
            body: cleanBody(notification.body),
            urgency: Number(notification.urgency),
            timestamp: Date.now()
        }

        historyEntries = [entry]
            .concat(historyEntries.filter(item => item.notificationId !== entry.notificationId))
            .slice(0, Math.max(1, historyLimit))

        if (!centerOpen && existingIndex === -1)
            unreadCount = Math.min(99, historyLimit, unreadCount + 1)
    }

    function refreshHistory(notification) {
        const index = historyEntries.findIndex(
            item => item.notificationId === notification.id
        )

        if (index < 0)
            return

        const entries = historyEntries.slice()
        const previous = entries[index]
        entries[index] = {
            key: previous.key,
            notificationId: previous.notificationId,
            appName: cleanSingleLine(notification.appName, 128) || "Notification",
            appIcon: cleanSingleLine(notification.appIcon, 128),
            summary: cleanSingleLine(notification.summary, 512) || "Notification",
            body: cleanBody(notification.body),
            urgency: Number(notification.urgency),
            timestamp: previous.timestamp
        }
        historyEntries = entries
    }

    function watchHistoryChanges(notification) {
        const update = () => root.refreshHistory(notification)

        notification.appNameChanged.connect(update)
        notification.appIconChanged.connect(update)
        notification.summaryChanged.connect(update)
        notification.bodyChanged.connect(update)
        notification.urgencyChanged.connect(update)
    }

    function toggleCenter() {
        centerOpen = !centerOpen
    }

    function closeCenter() {
        centerOpen = false
    }

    // Hyprland: qs ipc call notifications toggleCenter
    IpcHandler {
        target: "notifications"

        function toggleCenter(): void { root.toggleCenter() }
        function closeCenter(): void { root.closeCenter() }
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb

        if (!doNotDisturb)
            return

        const notifications = server.trackedNotifications.values.slice()
        for (let i = 0; i < notifications.length; i++) {
            const notification = notifications[i]

            if (notification && notification.urgency !== NotificationUrgency.Critical)
                notification.expire()
        }
    }

    function clearHistory() {
        historyEntries = []
        unreadCount = 0
    }

    function trimOverflow() {
        const notifications = server.trackedNotifications.values
        const overflow = notifications.length - Math.max(1, maxVisible)

        if (overflow <= 0)
            return

        const expirable = notifications.filter(notification => notification
            && notification.urgency !== NotificationUrgency.Critical
            && notification.expireTimeout !== 0)

        for (let i = 0; i < Math.min(overflow, expirable.length); i++) {
            const notification = expirable[i]

            if (notification)
                notification.expire()
        }
    }

    onMaxVisibleChanged: Qt.callLater(trimOverflow)
    onHistoryLimitChanged: {
        historyEntries = historyEntries.slice(0, Math.max(1, historyLimit))
        unreadCount = Math.min(unreadCount, historyEntries.length)
    }
    onCenterOpenChanged: {
        if (centerOpen)
            unreadCount = 0
    }

    NotificationServer {
        id: server

        keepOnReload: false
        persistenceSupported: false
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        imageSupported: true
        inlineReplySupported: false

        onNotification: notification => {
            notification.tracked = true

            if (!notification.transient) {
                root.remember(notification)
                root.watchHistoryChanges(notification)
            }

            if (root.doNotDisturb
                    && notification.urgency !== NotificationUrgency.Critical) {
                Qt.callLater(() => notification.expire())
                return
            }

            Qt.callLater(root.trimOverflow)
        }
    }

    ScriptModel {
        id: historyModel

        values: root.historyEntries
        objectProp: "key"
    }

    NotificationToastStack {
        screen: root.screen
        notificationModel: server.trackedNotifications
        defaultTimeoutMs: root.defaultTimeoutMs
        maxVisible: root.maxVisible
        topOffset: root.topOffset
        suppressed: root.centerOpen
        doNotDisturb: root.doNotDisturb
    }

    NotificationCenter {
        screen: root.screen
        open: root.centerOpen
        historyModel: historyModel
        historyCount: root.historyCount
        topOffset: root.topOffset
        rightOffset: root.rightOffset
        doNotDisturb: root.doNotDisturb

        onCloseRequested: root.centerOpen = false
        onClearRequested: root.clearHistory()
        onDoNotDisturbToggled: root.toggleDoNotDisturb()
    }
}
