import Quickshell
import Quickshell.Hyprland
import QtQuick

Scope {
    id: root

    signal presented(var model)

    Connections {
        target: Hyprland

        function onFocusedWorkspaceChanged() {
            const workspace = Hyprland.focusedWorkspace
            if (workspace)
                root.presented({ text: "Workspace " + workspace.id, workspaceId: workspace.id })
        }
    }
}
