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
        target: "wallpaper"

        function toggle(): void { root.toggle() }
        function close(): void { root.close() }
    }

    WallpaperPicker {
        open: root.open
        onCloseRequested: root.close()
    }
}
