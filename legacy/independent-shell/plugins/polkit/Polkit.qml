pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Commons"
import "."

// A full polkit agent: Agent.qml registers with polkitd, this file renders
// the authentication dialog on the first real monitor.
Scope {
    id: root

    readonly property var flow: agent.flow
    readonly property bool dialogOpen: agent.flow !== null
        && !agent.flow.isCompleted
    property string dialogScreenName: ""

    function firstRealScreenName() {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (Util.isRealScreen(screens[i]))
                return String(screens[i].name);
        }
        return "";
    }

    onDialogOpenChanged: {
        if (root.dialogOpen)
            root.dialogScreenName = root.firstRealScreenName();
    }

    Agent {
        id: agent
    }

    IpcHandler {
        target: "polkitDialog"

        function open(): string {
            return root.dialogOpen ? "yes" : "no";
        }

        function screen(): string {
            return root.dialogScreenName;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dialogWindow

            required property var modelData

            screen: modelData
            visible: root.dialogOpen
                && String(modelData.name) === root.dialogScreenName
            focusable: root.dialogOpen
            color: "transparent"
            exclusiveZone: 0
            aboveWindows: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "qs-polkit"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: root.dialogOpen
                ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            AuthDialog {
                anchors.fill: parent
                flow: root.flow
                onCloseRequested: root.dialogScreenName = ""
            }
        }
    }
}
