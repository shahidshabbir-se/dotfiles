import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    property string capturedAddress: ""
    property string pendingAddress: ""

    function capture() {
        const window = Hyprland.activeToplevel
        const ipc = window?.lastIpcObject || {}
        capturedAddress = String(ipc.address || "")
    }

    function discard() {
        capturedAddress = ""
        pendingAddress = ""
        restoreTimer.stop()
    }

    function restore() {
        if (!capturedAddress)
            return

        pendingAddress = capturedAddress
        capturedAddress = ""
        restoreTimer.restart()
    }

    Timer {
        id: restoreTimer
        interval: 200
        onTriggered: {
            if (!root.pendingAddress)
                return
            Hyprland.dispatch("focuswindow address:" + root.pendingAddress)
            root.pendingAddress = ""
        }
    }
}
