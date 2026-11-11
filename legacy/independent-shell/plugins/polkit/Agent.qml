import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit

// The agent alone, with no UI. Tests mount this to prove polkit registration
// without needing a live Wayland surface.
Scope {
    id: root

    property alias agent: agent
    readonly property var flow: agent.flow
    readonly property bool registered: agent.isRegistered
    readonly property bool active: agent.isActive

    function statusJson() {
        return JSON.stringify({
            registered: root.registered,
            active: root.active,
            path: String(agent.path || ""),
            awaiting: root.flow ? Boolean(root.flow.isResponseRequired) : false,
            actionId: root.flow ? String(root.flow.actionId || "") : ""
        });
    }

    PolkitAgent {
        id: agent

        // Explicit path documents the D-Bus object the agent exports. This
        // is also the default, so changing it is only needed for debugging
        // two agents in one session.
        path: "/org/quickshell/PolkitAgent"
    }

    IpcHandler {
        target: "polkit"

        function status(): string {
            return root.statusJson();
        }

        function isRegistered(): string {
            return root.registered ? "yes" : "no";
        }

        function cancel(): void {
            if (root.flow)
                root.flow.cancelAuthenticationRequest();
        }
    }
}
