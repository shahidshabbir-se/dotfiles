import QtQuick
import Quickshell
import Quickshell.Io
import qs.Registry
import qs.plugins.bar as BarPlugin
import qs.plugins.notifications as NotificationsPlugin

Scope {
    id: root

    Registry {
        id: registry
    }

    BarPlugin.Bar {
        registry: registry
    }

    NotificationsPlugin.Notifications {}

    IpcHandler {
        target: "shell"

        function ping(): string {
            // Quickshell exits 0 for a missing target/function, so callers
            // must compare this value instead of trusting the exit status.
            return "pong"
        }
    }
}
