import QtQuick
import Quickshell
import Quickshell.Io
import qs.Registry
import qs.plugins.bar as BarPlugin

Scope {
    id: root

    Registry {
        id: registry
    }

    BarPlugin.Bar {
        registry: registry
    }

    IpcHandler {
        target: "shell"

        function ping(): void {
            console.log("quickshell: ping")
        }
    }
}
