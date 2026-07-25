//@ pragma Env QT_SCALE_FACTOR=1.0
import Quickshell
import Quickshell.Io
import QtQuick
import "core"
import "config" as Config
import "sources"
import "ui"

Scope {
    id: root
    readonly property QtObject palette: MatugenColors {}

    function openMedia() {
        if (!mediaSource.available)
            return
        islandController.present(
            "media",
            mediaSource.playerModel(mediaSource.isPlaying ? "Playing" : "Paused"),
            null
        )
    }

    IslandController {
        id: islandController

        onSourceHandleReleased: handle => notificationSource.releaseHandle(handle)
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

                notificationSource.suppressMediaNotifications()
                mediaSource.handleAction(action, argument)
            }
        }
    }
}
