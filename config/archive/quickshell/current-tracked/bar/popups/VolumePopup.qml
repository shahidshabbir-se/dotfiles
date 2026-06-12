import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration
import "."
import "../volume"

Scope {
    id: root

    property bool open: false
    property var barRef: null

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    signal closed()

    function close() {
        if (!open)
            return
        closed()
    }

    LazyLoader {
        active: root.open

        Scope {
            PopupDismissGrab {
                active: root.open
                panelWindow: panelWindow
                barRef: root.barRef
                screen: root.activeScreen
                onDismissed: root.close()
            }

            PanelWindow {
                id: panelWindow
                screen: root.activeScreen
                visible: root.open && root.activeScreen !== null
                color: "transparent"
                aboveWindows: true
                focusable: true
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell_volume_popup"
                WlrLayershell.keyboardFocus: visible
                    ? WlrKeyboardFocus.OnDemand
                    : WlrKeyboardFocus.None

                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: BarMetrics.popupTopMargin
                    right: root.activeScreen
                        ? Math.max(120, (root.activeScreen.width * 0.125))
                        : 120
                }

                implicitWidth: 48
                implicitHeight: 94
                width: implicitWidth
                height: implicitHeight

                onVisibleChanged: if (visible) popupFocus.refocus()

                PopupFocusHost {
                    id: popupFocus
                    active: root.open
                    anchors.fill: parent
                    onEscapePressed: root.close()

                    BarVolumeControl {
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
