import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../config" as Config

Scope {
    id: root

    property string activeMediaIdentity: ""
    property real mediaSuppressedUntil: 0

    signal presented(var model, var handle)

    function suppressMediaNotifications() {
        mediaSuppressedUntil = Date.now()
            + Config.IslandConstants.mediaNotificationSuppressionInterval
    }

    function cleanText(text) {
        return String(text ?? "")
            .replace(/<[^>]*>/g, " ")
            .replace(/&nbsp;/g, " ")
            .replace(/&amp;/g, "&")
            .replace(/&quot;/g, "\"")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/\s+/g, " ")
            .trim()
    }

    function isRawMediaState(appName, summary) {
        if (Date.now() < mediaSuppressedUntil)
            return true

        if (/^(play|pause|playing|paused|music (is )?(playing|paused))[\s.!]*$/i.test(summary))
            return true

        const app = appName.toLowerCase()
        const player = activeMediaIdentity.toLowerCase()
        const samePlayer = app && player
            && (app.includes(player) || player.includes(app))
        if (!samePlayer)
            return false

        const browserPlayer = /firefox|chromium|chrome|brave|vivaldi|opera|edge/.test(player)
        return !browserPlayer || /\b(play|pause|playing|paused)\b/i.test(summary)
    }

    function releaseHandle(handle) {
        if (!handle)
            return
        if (handle.tracked)
            handle.tracked = false
    }

    NotificationServer {
        actionsSupported: false
        bodySupported: true
        imageSupported: false
        persistenceSupported: false
        keepOnReload: true

        onNotification: notification => {
            const appName = root.cleanText(notification.appName)
            const summary = root.cleanText(notification.summary)
            const body = root.cleanText(notification.body)

            if (root.isRawMediaState(appName, summary)) {
                notification.tracked = false
                return
            }

            notification.tracked = true
            root.presented({
                summary: summary || body || appName || "Notification",
                body: summary ? body : "",
                iconText: Config.IslandConstants.notificationIcon
            }, notification)
        }
    }
}
