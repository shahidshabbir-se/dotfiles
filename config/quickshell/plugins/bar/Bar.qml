import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Commons"
import "../../Ui"
import "../clock"

Scope {
    id: root

    readonly property bool hasUsableScreen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (Util.isRealScreen(screens[i]))
                return true;
        }
        return false;
    }

    property bool hyprlandHasLitMonitor: false

    // A shell that survives suspend on a Qt placeholder output never remounts
    // its bar. Only exit when Hyprland still reports a lit real output, so a
    // long DPMS-off period cannot burn through systemd's start limit.
    Process {
        id: monitorProbe

        command: [ "hyprctl", "-j", "monitors" ]

        stdout: StdioCollector {
            waitForEnd: true

            onStreamFinished: {
                let lit = false;
                try {
                    const monitors = JSON.parse(text || "[]");
                    lit = monitors.some(monitor => {
                        const name = String(monitor.name || "");
                        return name !== "" && name !== "FALLBACK"
                            && name.toLowerCase().indexOf("placeholder") < 0
                            && monitor.disabled !== true
                            && monitor.dpmsStatus !== false;
                    });
                } catch (error) {
                }
                root.hyprlandHasLitMonitor = lit;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        property int missingTicks: 0

        onTriggered: {
            if (root.hasUsableScreen) {
                missingTicks = 0;
                return;
            }
            if (!monitorProbe.running)
                monitorProbe.running = true;
            if (!root.hyprlandHasLitMonitor) {
                missingTicks = 0;
                return;
            }
            missingTicks += 1;
            if (missingTicks >= 8)
                Qt.quit();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            screen: modelData
            visible: Util.isRealScreen(modelData)

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Style.barHeight
            color: "transparent"
            exclusiveZone: Style.barHeight
            aboveWindows: true

            WlrLayershell.namespace: "qs-bar"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                color: Color.background
            }

            BarWidget {
                anchors.centerIn: parent

                Clock {}
            }
        }
    }
}
