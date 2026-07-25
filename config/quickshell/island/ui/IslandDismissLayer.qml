import Quickshell
import Quickshell.Wayland
import QtQuick
import "../config" as Config

Scope {
    id: root

    required property var targetScreen
    required property var controller

    readonly property bool active: controller.kind === "media"
    readonly property real sideWidth: Math.max(
        0,
        (targetScreen.width - Config.IslandConstants.mediaWidth) / 2
    )

    signal dismissed()

    PanelWindow {
        visible: root.active
        screen: root.targetScreen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_island_dismiss_top"

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Config.IslandConstants.windowTopMargin

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    PanelWindow {
        visible: root.active
        screen: root.targetScreen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_island_dismiss_bottom"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        margins.top: Config.IslandConstants.windowTopMargin
            + Config.IslandConstants.mediaHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    PanelWindow {
        visible: root.active && root.sideWidth > 0
        screen: root.targetScreen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_island_dismiss_left"

        anchors {
            top: true
            left: true
        }
        margins.top: Config.IslandConstants.windowTopMargin
        implicitWidth: root.sideWidth
        implicitHeight: Config.IslandConstants.mediaHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    PanelWindow {
        visible: root.active && root.sideWidth > 0
        screen: root.targetScreen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell_island_dismiss_right"

        anchors {
            top: true
            right: true
        }
        margins.top: Config.IslandConstants.windowTopMargin
        implicitWidth: root.sideWidth
        implicitHeight: Config.IslandConstants.mediaHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }
}
