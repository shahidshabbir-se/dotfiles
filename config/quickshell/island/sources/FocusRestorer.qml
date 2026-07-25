import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    property string capturedAddress: ""
    property string capturedWorkspaceId: ""
    property string pendingAddress: ""
    property string pendingWorkspaceId: ""

    function capture() {
        const window = Hyprland.activeToplevel
        const focusedWorkspace = Hyprland.focusedWorkspace
        const windowWorkspace = window?.workspace

        if (!window || !focusedWorkspace || !windowWorkspace
                || windowWorkspace.id !== focusedWorkspace.id) {
            discard()
            return
        }

        const ipc = window?.lastIpcObject || {}
        capturedAddress = String(ipc.address || "")
        capturedWorkspaceId = capturedAddress ? String(focusedWorkspace.id) : ""
    }

    function discard() {
        capturedAddress = ""
        capturedWorkspaceId = ""
        pendingAddress = ""
        pendingWorkspaceId = ""
        restoreTimer.stop()
    }

    function restore() {
        if (!capturedAddress)
            return

        pendingAddress = capturedAddress
        pendingWorkspaceId = capturedWorkspaceId
        capturedAddress = ""
        capturedWorkspaceId = ""
        restoreTimer.restart()
    }

    Timer {
        id: restoreTimer
        interval: 200
        onTriggered: {
            if (!root.pendingAddress)
                return

            if (String(Hyprland.focusedWorkspace?.id ?? "") !== root.pendingWorkspaceId) {
                root.pendingAddress = ""
                root.pendingWorkspaceId = ""
                return
            }

            Hyprland.dispatch("focuswindow address:" + root.pendingAddress)
            root.pendingAddress = ""
            root.pendingWorkspaceId = ""
        }
    }
}
