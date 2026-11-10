import QtQuick
import Quickshell
import Quickshell.Io
import "../plugins/bar"
import "../plugins/notifications"

Scope {
    id: root

    Bar {
        id: bar
    }

    Notifications {}

    IpcHandler {
        target: "shell"

        function ping(): void {
            console.log("quickshell: ping")
        }
    }
}
