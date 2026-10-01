import QtQuick
import Quickshell
import qs.features.audio as AudioFeature
import qs.features.bar as BarFeature
import qs.features.hyprview as HyprviewFeature
import qs.features.notifications as NotificationsFeature
import qs.features.screenshot as ScreenshotFeature
import qs.features.visualizer as VisualizerFeature
import qs.features.volume as VolumeFeature
import qs.features.weather as WeatherFeature
import qs.features.wallpaper as WallpaperFeature

Scope {
    BarFeature.Bar {
        id: bar

        doNotDisturb: notifications.doNotDisturb
        notificationCenterOpen: notifications.centerOpen
        notificationCount: notifications.unreadCount
        recording: screenshot.recording
        audioOpen: audio.open
        audioIcon: audio.outputIcon()
        audioMuted: audio.outputMuted
        weatherOpen: weather.open
        weatherGlyph: weather.label
        orientation: Quickshell.env("BAR_ORIENTATION") === "vertical"
            ? Qt.Vertical
            : Qt.Horizontal

        onNotificationsClicked: notifications.toggleCenter()
        onRecordingStopClicked: screenshot.stopRecording()
        onAudioToggleRequested: audio.toggle()
        onAudioCloseRequested: audio.close()
        onWeatherToggleRequested: weather.toggle()
        onWeatherCloseRequested: weather.close()
        onPopupOpened: {
            notifications.closeCenter()
            wallpaper.close()
            screenshot.close()
            hyprview.close()
            audio.close()
            weather.close()
        }
    }

    AudioFeature.Audio {
        id: audio

        screen: bar.screen
        barVertical: bar.vertical
        barWidth: bar.implicitWidth
    }

    WeatherFeature.Weather {
        id: weather

        screen: bar.screen
    }

    VisualizerFeature.Visualizer {
        screen: bar.screen
    }

    VolumeFeature.Volume {}

    NotificationsFeature.Notifications {
        id: notifications

        screen: bar.screen
        barVertical: bar.vertical
        barWidth: bar.implicitWidth
    }

    WallpaperFeature.Wallpaper {
        id: wallpaper

        onOpenChanged: {
            if (open) {
                screenshot.close()
                hyprview.close()
            }
        }
    }

    ScreenshotFeature.Screenshot {
        id: screenshot

        onOpenChanged: {
            if (open) {
                notifications.closeCenter()
                wallpaper.close()
                bar.closePopups()
                hyprview.close()
            }
        }
    }

    HyprviewFeature.Hyprview {
        id: hyprview

        onOpenChanged: {
            if (open) {
                notifications.closeCenter()
                wallpaper.close()
                screenshot.close()
                bar.closePopups()
            }
        }
    }

}
