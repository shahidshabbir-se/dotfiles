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

        function ping(): string {
            // Quickshell exits 0 for a missing target/function, so callers
            // must compare this value instead of trusting the exit status.
            return "pong"
        }
    }
}
