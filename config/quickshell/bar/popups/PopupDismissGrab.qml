import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration

Scope {
    id: root

    property bool active: false
    property var panelWindow: null
    property var barRef: null
    property var screen: null

    signal dismissed()

    readonly property int sideStripWidth: root.screen
        ? Math.round(root.screen.width * (1 - BarMetrics.barWidthRatio) / 2)
        : 0

    // Gap above the visible bar (full width).
    PanelWindow {
        visible: root.active && root.screen !== null
        screen: root.screen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell_popup_dismiss_top"

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: BarMetrics.barTopMargin
        height: implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    // Desktop area below the bar.
    PanelWindow {
        visible: root.active && root.screen !== null
        screen: root.screen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell_popup_dismiss"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        margins {
            top: BarMetrics.panelHeight
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    // Top-left strip beside the 75% bar — not part of the bar window.
    PanelWindow {
        visible: root.active && root.screen !== null && root.sideStripWidth > 0
        screen: root.screen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell_popup_dismiss_left"

        anchors {
            top: true
            left: true
        }

        margins {
            top: BarMetrics.barTopMargin
        }

        implicitWidth: root.sideStripWidth
        implicitHeight: BarMetrics.barVisualHeight
        width: implicitWidth
        height: implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    // Top-right strip beside the 75% bar.
    PanelWindow {
        visible: root.active && root.screen !== null && root.sideStripWidth > 0
        screen: root.screen
        color: "transparent"
        aboveWindows: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell_popup_dismiss_right"

        anchors {
            top: true
            right: true
        }

        margins {
            top: BarMetrics.barTopMargin
        }

        implicitWidth: root.sideStripWidth
        implicitHeight: BarMetrics.barVisualHeight
        width: implicitWidth
        height: implicitHeight

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
    }

    HyprlandFocusGrab {
        active: root.active
            && root.panelWindow !== null
            && root.panelWindow.visible
        windows: {
            const wins = []
            if (root.panelWindow?.visible)
                wins.push(root.panelWindow)
            if (root.barRef && root.screen) {
                const barWindow = root.barRef.windowForScreen(root.screen)
                if (barWindow)
                    wins.push(barWindow)
            }
            return wins
        }
        onCleared: root.dismissed()
    }
}
