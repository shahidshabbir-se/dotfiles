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

        function ping(): string {
            // Quickshell exits 0 for a missing target/function, so callers
            // must compare this value instead of trusting the exit status.
            return "pong"
        }
    }
}
