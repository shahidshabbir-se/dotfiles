pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../../Commons"
import "Format.js" as Format

Scope {
    id: root

    // History, unread, DND, and center visibility live in NotificationStore.
    // The server owns tracking (toasts); the store owns what survives them.
    property int maxVisible: 4
    property int defaultTimeoutMs: 6000

    readonly property var targetScreen: {
        const screens = Quickshell.screens
        for (let i = 0; i < screens.length; i++) {
            if (Util.isRealScreen(screens[i]))
                return screens[i]
        }
        return null
    }

    function trimOverflow() {
        const overflow = Format.overflowedToasts(
            server.trackedNotifications.values,
            root.maxVisible
        )
        for (let i = 0; i < overflow.length; i++) {
            if (overflow[i])
                overflow[i].expire()
        }
    }

    function dismissToasts() {
        const values = server.trackedNotifications.values
        for (let i = 0; i < values.length; i++) {
            if (values[i] && values[i].tracked)
                values[i].expire()
        }
    }

    function statusJson() {
        return JSON.stringify({
            open: NotificationStore.centerOpen,
            dnd: NotificationStore.dnd,
            unread: NotificationStore.unread,
            history: NotificationStore.history.length,
            toasts: server.trackedNotifications.values.length
        })
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
            // History is recorded first so DND silences the toast without
            // losing the notification. Untracked objects are released after
            // this handler returns.
            NotificationStore.record(notification)
            notification.tracked = !NotificationStore.dnd
            if (notification.tracked)
                Qt.callLater(root.trimOverflow)
        }
    }

    Connections {
        target: NotificationStore

        function onDndChanged() {
            if (NotificationStore.dnd)
                root.dismissToasts()
        }

        function onCenterOpenChanged() {
            if (NotificationStore.centerOpen)
                root.dismissToasts()
        }
    }

    IpcHandler {
        target: "notifications"

        function toggleCenter(): string {
            NotificationStore.toggleCenter()
            return root.statusJson()
        }

        function toggleDnd(): string {
            NotificationStore.toggleDnd()
            return root.statusJson()
        }

        function clearHistory(): string {
            NotificationStore.clear()
            return root.statusJson()
        }

        function status(): string {
            return root.statusJson()
        }

        function history(): string {
            return JSON.stringify(NotificationStore.history)
        }
    }

    Component {
        id: toastComponent

        ToastStack {
            screen: root.targetScreen
            notificationModel: server.trackedNotifications
            maxVisible: root.maxVisible
            defaultTimeoutMs: root.defaultTimeoutMs
        }
    }

    Loader {
        active: root.targetScreen !== null
        sourceComponent: toastComponent
    }

    Component {
        id: centerComponent

        Center {
            panelScreen: root.targetScreen
        }
    }

    Loader {
        active: root.targetScreen !== null
        sourceComponent: centerComponent
    }
}
