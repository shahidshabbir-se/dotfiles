import QtQuick
import Quickshell
import qs

// Standalone harness: thin top bar + Omarchy network panel, open on start.
// Run: reference/omarchy-network/run.sh
ShellRoot {
    StubBar {
        id: stubBar

        Loader {
            id: networkLoader
            anchors.fill: parent
            source: Qt.resolvedUrl("panel/Panel.qml")

            onLoaded: {
                item.bar = stubBar
                // Delay past KeyboardPanel layout so outside-click dismiss
                // doesn't fire on the same frame as open.
                openTimer.start()
            }

            Timer {
                id: openTimer
                interval: 250
                onTriggered: {
                    if (networkLoader.item && !networkLoader.item.opened)
                        networkLoader.item.open()
                }
            }
        }
    }
}
