import QtQuick
import Quickshell
import Quickshell.Io
import "../plugins/bar"

Scope {
    id: root

    Bar {
        id: bar
    }

    IpcHandler {
        target: "shell"

        function ping(): void {
            console.log("quickshell: ping")
        }
    }
}
