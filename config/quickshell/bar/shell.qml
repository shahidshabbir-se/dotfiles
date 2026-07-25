//@ pragma Env QT_SCALE_FACTOR=1.0
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import "bar"
import "popups"

Scope {
    id: root

    property bool barVisible: true
    property bool musicPlayerOpen: false
    property bool notificationsOpen: false
    property bool volumePopupOpen: false
    property bool dateTimeOpen: false
    property bool powerProfileOpen: false

    function closeAllPopups() {
        musicPlayerOpen = false
        notificationsOpen = false
        volumePopupOpen = false
        dateTimeOpen = false
        powerProfileOpen = false
    }

    function toggleMusicPlayer() {
        if (musicPlayerOpen) {
            musicPlayerOpen = false
            return
        }
        notificationsOpen = false
        volumePopupOpen = false
        dateTimeOpen = false
        powerProfileOpen = false
        musicPlayerOpen = true
    }

    function toggleNotifications() {
        if (notificationsOpen) {
            notificationsOpen = false
            return
        }
        musicPlayerOpen = false
        volumePopupOpen = false
        dateTimeOpen = false
        powerProfileOpen = false
        notificationsOpen = true
    }

    function toggleDateTime() {
        if (dateTimeOpen) {
            dateTimeOpen = false
            return
        }
        musicPlayerOpen = false
        notificationsOpen = false
        volumePopupOpen = false
        powerProfileOpen = false
        dateTimeOpen = true
    }

    function toggleLauncher() {
        closeAllPopups()
        vicinaeLauncherProcess.running = false
        vicinaeLauncherProcess.running = true
    }

    function toggleVolumePopup() {
        if (volumePopupOpen) {
            volumePopupOpen = false
            return
        }
        musicPlayerOpen = false
        notificationsOpen = false
        dateTimeOpen = false
        powerProfileOpen = false
        volumePopupOpen = true
    }

    function togglePowerProfile() {
        if (powerProfileOpen) {
            powerProfileOpen = false
            return
        }
        closeAllPopups()
        powerProfileOpen = true
    }

    IpcHandler {
        target: "bar"

        function toggleBar(): void { root.barVisible = !root.barVisible }
        function showBar(): void { root.barVisible = true }
        function hideBar(): void { root.barVisible = false }
    }

    IpcHandler {
        target: "notifications"

        function toggle(): void { root.toggleNotifications() }
        function show(): void {
            root.musicPlayerOpen = false
            root.volumePopupOpen = false
            root.dateTimeOpen = false
            root.notificationsOpen = true
        }
        function hide(): void { root.notificationsOpen = false }
        function clear_all(): void { notificationCenter.clearAll() }
        function dnd_toggle(): void { notificationCenter.dnd = !notificationCenter.dnd }
    }

    IpcHandler {
        target: "music"

        function toggle(): void { root.toggleMusicPlayer() }
        function show(): void {
            root.notificationsOpen = false
            root.volumePopupOpen = false
            root.dateTimeOpen = false
            root.musicPlayerOpen = true
        }
        function hide(): void { root.musicPlayerOpen = false }
    }

    IpcHandler {
        target: "volume"

        function toggle(): void { root.toggleVolumePopup() }
        function show(): void {
            root.musicPlayerOpen = false
            root.notificationsOpen = false
            root.dateTimeOpen = false
            root.volumePopupOpen = true
        }
        function hide(): void { root.volumePopupOpen = false }
    }

    IpcHandler {
        target: "datetime"

        function toggle(): void { root.toggleDateTime() }
        function show(): void {
            root.musicPlayerOpen = false
            root.notificationsOpen = false
            root.volumePopupOpen = false
            root.dateTimeOpen = true
        }
        function hide(): void { root.dateTimeOpen = false }
    }

    IpcHandler {
        target: "popups"

        function close(): void { root.closeAllPopups() }
    }

    NotificationServer {
        id: notifServer
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
            notificationCenter.ingest(notification)
        }
    }

    Process {
        id: vicinaeLauncherProcess
        running: false
        command: ["vicinae", "toggle"]
    }

    Bar {
        id: bar
        barVisible: root.barVisible
        notificationUnreadCount: notificationCenter.unreadCount
        onToggleMusicPlayer: root.toggleMusicPlayer()
        onToggleNotifications: root.toggleNotifications()
        onToggleLauncher: root.toggleLauncher()
        onToggleDateTime: root.toggleDateTime()
        onTogglePowerProfile: root.togglePowerProfile()
    }

    MusicPlayerPanel {
        open: root.musicPlayerOpen
        barRef: bar
        onClosed: root.musicPlayerOpen = false
    }

    NotificationCenter {
        id: notificationCenter
        open: root.notificationsOpen
        barRef: bar
        onRequestOpen: root.notificationsOpen = true
        onClosed: root.notificationsOpen = false
    }

    VolumePopup {
        open: root.volumePopupOpen
        barRef: bar
        onClosed: root.volumePopupOpen = false
    }

    DateTimePanel {
        open: root.dateTimeOpen
        barRef: bar
        onClosed: root.dateTimeOpen = false
    }

    PowerProfilePanel {
        open: root.powerProfileOpen
        barRef: bar
        onClosed: root.powerProfileOpen = false
    }

    ScreenshotOverlay {
        id: screenshotOverlay
    }

    PopoutVolume {}

    Connections {
        target: Quickshell

        function onReloadCompleted(): void {
            Quickshell.inhibitReloadPopup()
        }

        function onReloadFailed(error: string): void {
            Quickshell.inhibitReloadPopup()
        }
    }
}
