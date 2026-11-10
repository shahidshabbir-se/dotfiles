pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../../Commons"
import "Format.js" as Format

Scope {
    id: root

    // Toasts only: notification history, unread state, and do-not-disturb
    // belong to the notification center plugin.
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
            // Track while the toast is on screen. The stack expires or
            // dismisses it, which lets Quickshell release the object.
            notification.tracked = true
            Qt.callLater(root.trimOverflow)
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
}
