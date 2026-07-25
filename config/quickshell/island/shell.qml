//@ pragma Env QT_SCALE_FACTOR=1.0
//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "core"
import "config" as Config
import "sources"
import "ui"

Scope {
    id: root
    readonly property QtObject palette: MatugenColors {}
    readonly property bool focusedWorkspaceEmpty: {
        const focusedWorkspace = Hyprland.focusedWorkspace
        return Boolean(focusedWorkspace)
            && (focusedWorkspace.toplevels?.values?.length ?? 0) === 0
    }
    readonly property bool focusedWorkspaceFullscreen:
        Hyprland.focusedWorkspace?.hasFullscreen ?? false
    property bool pastePending: false
    property string pasteTargetClass: ""

    function openMedia() {
        if (!mediaSource.available)
            return
        focusRestorer.capture()
        islandController.present(
            "media",
            mediaSource.playerModel(mediaSource.isPlaying ? "Playing" : "Paused"),
            null
        )
    }

    function openLauncher() {
        focusRestorer.capture()
        islandController.present("launcher", {
            source: launcherSource
        }, null)
    }

    function openClipboard() {
        focusRestorer.capture()
        clipboardSource.refresh()
        islandController.present("clipboard", {
            source: clipboardSource
        }, null)
    }

    function openWifi() {
        focusRestorer.capture()
        islandController.present("wifi", {
            source: wifiSource
        }, null)
    }

    function pasteClipboard(entry) {
        pastePending = true
        pasteTargetClass = focusRestorer.capturedAppClass
        clipboardSource.copy(entry)
        islandController.dismiss()
    }

    function pasteModifiers() {
        const appClass = pasteTargetClass.toLowerCase()
        return /ghostty|kitty|alacritty|foot|wezterm|konsole|gnome-terminal|gnome-console|blackbox|tilix|rio|xterm/.test(appClass)
            ? "CTRL SHIFT"
            : "CTRL"
    }

    IslandController {
        id: islandController
        persistentReveal: root.focusedWorkspaceEmpty
        mediaAvailable: mediaSource.available
        fullscreenActive: root.focusedWorkspaceFullscreen

        onSourceHandleReleased: handle => notificationSource.releaseHandle(handle)
        onPresentationDismissed: focusRestorer.restore()
    }

    FocusRestorer {
        id: focusRestorer
    }

    IpcHandler {
        target: "visibility"

        function reveal(): void { islandController.setKeyboardReveal(true) }
        function conceal(): void { islandController.setKeyboardReveal(false) }
    }

    IpcHandler {
        target: "media"

        function open(): void { root.openMedia() }
        function close(): void {
            if (islandController.kind === "media")
                islandController.dismiss()
        }
        function toggle(): void {
            if (islandController.kind === "media")
                islandController.dismiss()
            else
                root.openMedia()
        }
    }

    IpcHandler {
        target: "launcher"

        function open(): void { root.openLauncher() }
        function close(): void {
            if (islandController.kind === "launcher")
                islandController.dismiss()
        }
        function toggle(): void {
            if (islandController.kind === "launcher")
                islandController.dismiss()
            else
                root.openLauncher()
        }
    }

    IpcHandler {
        target: "clipboard"

        function open(): void { root.openClipboard() }
        function close(): void {
            if (islandController.kind === "clipboard")
                islandController.dismiss()
        }
        function toggle(): void {
            if (islandController.kind === "clipboard")
                islandController.dismiss()
            else
                root.openClipboard()
        }
    }

    IpcHandler {
        target: "wifi"

        function open(): void { root.openWifi() }
        function close(): void {
            if (islandController.kind === "wifi")
                islandController.dismiss()
        }
        function toggle(): void {
            if (islandController.kind === "wifi")
                islandController.dismiss()
            else
                root.openWifi()
        }
    }

    MediaSource {
        id: mediaSource

        onUpdated: model => {
            notificationSource.suppressMediaNotifications()
            if (islandController.kind === "media") {
                islandController.present("media", model, null)
                return
            }

            if (mediaSource.activeAppFocused)
                return

            islandController.present("notification", {
                summary: model.stateLabel,
                body: model.title,
                iconText: Config.IslandConstants.mediaIcon,
                action: "openMedia"
            }, null)
        }

        onRefreshed: model => islandController.updateModel("media", model)
    }

    NotificationSource {
        id: notificationSource
        activeMediaIdentity: mediaSource.activeIdentity

        onPresented: (model, handle) => islandController.present("notification", model, handle)
    }

    WorkspaceSource {
        id: workspaceSource

        onPresented: model => islandController.present("workspace", model, null)
    }

    LauncherSource {
        id: launcherSource
    }

    ClipboardSource {
        id: clipboardSource

        onCopyFinished: success => {
            if (!root.pastePending)
                return
            root.pastePending = false
            if (success)
                pasteTimer.restart()
            else
                root.pasteTargetClass = ""
        }
    }

    WifiSource {
        id: wifiSource
        active: islandController.kind === "wifi"
    }

    Timer {
        id: pasteTimer
        interval: 260
        onTriggered: {
            Hyprland.dispatch("sendshortcut " + root.pasteModifiers() + ",V,activewindow")
            root.pasteTargetClass = ""
        }
    }

    Variants {
        model: Quickshell.screens

        IslandWindow {
            controller: islandController
            palette: root.palette

            onActionRequested: (action, argument) => {
                if (action === "dismiss") {
                    islandController.dismiss()
                    return
                }

                if (action === "openMedia") {
                    root.openMedia()
                    return
                }


                if (action === "launchApp") {
                    focusRestorer.discard()
                    islandController.dismiss()
                    launcherSource.launch(argument)
                    return
                }

                if (action === "copyClipboard") {
                    clipboardSource.copy(argument)
                    islandController.dismiss()
                    return
                }

                if (action === "pasteClipboard") {
                    root.pasteClipboard(argument)
                    return
                }

                if (action === "openClipboardUrl") {
                    const url = String(argument ?? "").trim()
                    if (!clipboardSource.isUrl(url))
                        return
                    focusRestorer.discard()
                    islandController.dismiss()
                    Quickshell.execDetached(["xdg-open", url])
                    return
                }

                notificationSource.suppressMediaNotifications()
                mediaSource.handleAction(action, argument)
            }
        }
    }
}
