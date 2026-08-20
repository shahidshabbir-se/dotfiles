import QtQuick
import Quickshell
import qs.features.bar as BarFeature
import qs.features.notifications as NotificationsFeature
import qs.features.screenshot as ScreenshotFeature
import qs.features.visualizer as VisualizerFeature
import qs.features.wallpaper as WallpaperFeature

Scope {
    BarFeature.Bar {
        id: bar

        doNotDisturb: notifications.doNotDisturb
        notificationCenterOpen: notifications.centerOpen
        notificationCount: notifications.unreadCount
        recording: screenshot.recording
        orientation: Quickshell.env("BAR_ORIENTATION") === "vertical"
            ? Qt.Vertical
            : Qt.Horizontal

        onNotificationsClicked: notifications.toggleCenter()
        onRecordingStopClicked: screenshot.stopRecording()
        onPopupOpened: {
            notifications.closeCenter()
            wallpaper.close()
            screenshot.close()
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

        onOpenChanged: {
            if (open)
                screenshot.close()
        }
    }

    ScreenshotFeature.Screenshot {
        id: screenshot

        onOpenChanged: {
            if (open) {
                notifications.closeCenter()
                wallpaper.close()
                bar.closePopups()
            }
        }
    }
}
