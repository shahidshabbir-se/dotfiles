import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "../config" as Config

PanelWindow {
    id: root

    required property var modelData
    required property var controller
    required property var palette

    signal actionRequested(string action, var argument)

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    margins.top: Config.IslandConstants.windowTopMargin
    implicitHeight: Config.IslandConstants.windowSurfaceHeight
    exclusiveZone: Config.IslandConstants.windowExclusiveZone
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell_island"
    WlrLayershell.keyboardFocus: controller.kind === "launcher"
            || controller.kind === "clipboard"
            || controller.kind === "media"
            || controller.kind === "wifi"
            || controller.kind === "bluetooth"
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: (root.controller.kind === "media"
                || root.controller.kind === "launcher"
                || root.controller.kind === "clipboard"
                || root.controller.kind === "wifi"
                || root.controller.kind === "bluetooth")
            && root.visible
        windows: [root]
        onCleared: {
            if (root.controller.kind === "media"
                    || root.controller.kind === "launcher"
                    || root.controller.kind === "clipboard"
                    || root.controller.kind === "wifi"
                    || root.controller.kind === "bluetooth")
                root.controller.dismiss()
        }
    }
    mask: Region {
        x: Math.floor(capsule.x)
        y: Math.floor(capsule.y)
        width: root.controller.revealed ? Math.ceil(capsule.width) : 0
        height: root.controller.revealed ? Math.ceil(capsule.height) : 0
    }

    IslandCapsule {
        id: capsule
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        maximumWidth: root.width - Config.IslandConstants.windowHorizontalInset * 2
        controller: root.controller
        palette: root.palette
        revealed: root.controller.revealed

        onExpandedRequested: value => root.controller.setExpanded(value)
        onActionRequested: (action, argument) => root.actionRequested(action, argument)
        onHoverChanged: hovered => {
            root.controller.setEdgeReveal(hovered)
            root.controller.setPointerInside(hovered)
        }
    }

    IslandEdgeReveal {
        targetScreen: root.modelData
        controller: root.controller
    }

    IslandDismissLayer {
        targetScreen: root.modelData
        controller: root.controller
        onDismissed: root.controller.dismiss()
    }
}
