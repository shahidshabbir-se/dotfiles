import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool open: false

    function toggle() {
        open = !open
    }

    function close() {
        open = false
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle() }
        function open(): void { root.open = true }
        function close(): void { root.close() }
    }

    LauncherPanel {
        open: root.open
        onCloseRequested: root.close()
    }
}
