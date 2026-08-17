import QtQuick
import Quickshell
import qs.features.bar as BarFeature
import qs.features.notifications as NotificationsFeature
import qs.features.visualizer as VisualizerFeature
import qs.features.wallpaper as WallpaperFeature

Scope {
    BarFeature.Bar {
        id: bar

        doNotDisturb: notifications.doNotDisturb
        notificationCenterOpen: notifications.centerOpen
        notificationCount: notifications.unreadCount
        orientation: Quickshell.env("BAR_ORIENTATION") === "vertical"
            ? Qt.Vertical
            : Qt.Horizontal

        onNotificationsClicked: notifications.toggleCenter()
        onPopupOpened: {
            notifications.closeCenter()
            wallpaper.close()
        }
    }

    VisualizerFeature.Visualizer {
        screen: bar.screen
    }

    NotificationsFeature.Notifications {
        id: notifications

        screen: bar.screen
        barVertical: bar.vertical
        barWidth: bar.implicitWidth
    }

    WallpaperFeature.Wallpaper {
        id: wallpaper
    }
}
