import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.configuration

Scope {
    id: root

    property bool open: false
    property var screen: null
    // Leave the bar strip untouched so tray/workspaces stay clickable.
    property int dismissTopMargin: BarMetrics.panelHeight

    signal clickedOutside()

    PanelWindow {
        visible: root.open && root.screen !== null
        screen: root.screen
        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        margins {
            top: root.dismissTopMargin
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.clickedOutside()
        }
    }
}
