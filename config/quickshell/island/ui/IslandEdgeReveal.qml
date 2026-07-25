import Quickshell
import Quickshell.Wayland
import QtQuick
import "../config" as Config

Scope {
    id: root

    required property var targetScreen
    required property var controller

    PanelWindow {
        screen: root.targetScreen
        visible: root.controller.kind === "clock"
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_island_edge"

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Config.IslandConstants.edgeRevealHeight

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.controller.setEdgeReveal(true)
            onExited: root.controller.setEdgeReveal(false)
        }
    }
}
