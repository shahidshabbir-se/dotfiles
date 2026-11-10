import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons as Commons
import qs.Ui as Ui
import qs.services

Scope {
    id: root

    property var registry: null

    readonly property string position: Config.position
    readonly property bool hasUsableScreen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (Commons.Util.isRealScreen(screens[i]))
                return true;
        }
        return false;
    }

    function unknownEntries() {
        const unknown = [];
        const sections = [ "left", "centerBegin", "center", "centerEnd", "tray", "right" ];

        for (let s = 0; s < sections.length; s++) {
            const section = sections[s];
            const entries = Config.layout[section] || [];

            for (let e = 0; e < entries.length; e++) {
                const id = entries[e].id;
                if (!root.registry || !root.registry.entryFor(id))
                    unknown.push({ section: section, id: id });
            }
        }
        return unknown;
    }

    // The effective layout is the reload seam: the acceptance harness can edit
    // shell.json and read this back without inspecting pixels.
    IpcHandler {
        target: "bar"

        function layout(): string {
            return JSON.stringify({
                version: Config.version,
                position: Config.position,
                layout: Config.layout,
                errors: Config.errors,
                unknown: root.unknownEntries()
            });
        }
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

        // qmllint disable uncreatable-type
        PanelWindow {
            id: bar

            required property var modelData

            screen: modelData
            visible: Commons.Util.isRealScreen(modelData)

            anchors.top: root.position === "top"
            anchors.bottom: root.position === "bottom"
            anchors.left: true
            anchors.right: true

            implicitHeight: Commons.Style.barHeight
            color: "transparent"
            exclusiveZone: Commons.Style.barHeight
            aboveWindows: true

            WlrLayershell.namespace: "qs-bar"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                color: Commons.Color.background
            }

            BarSection {
                section: "left"
                entries: Config.layout.left
                registry: root.registry
                barWindow: bar
                barScreen: bar.screen

                anchors.left: parent.left
                anchors.leftMargin: Commons.Style.barPadding
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                id: centerGroup

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: Commons.Style.spacingSm

                BarSection {
                    section: "centerBegin"
                    entries: Config.layout.centerBegin
                    registry: root.registry
                    barWindow: bar
                    barScreen: bar.screen
                }

                BarSection {
                    section: "center"
                    entries: Config.layout.center
                    registry: root.registry
                    barWindow: bar
                    barScreen: bar.screen
                }

                BarSection {
                    section: "centerEnd"
                    entries: Config.layout.centerEnd
                    registry: root.registry
                    barWindow: bar
                    barScreen: bar.screen
                }

                Ui.BarWidget {
                    visible: Config.errors.length > 0

                    Item {
                        implicitWidth: errorLabel.implicitWidth
                        implicitHeight: errorLabel.implicitHeight

                        Text {
                            id: errorLabel

                            color: Commons.Color.red
                            text: "config error"
                            font {
                                family: Commons.Style.monoFontFamily
                                pixelSize: Commons.Style.fontSizeSm
                            }
                        }
                    }
                }
            }

            Row {
                id: rightGroup

                anchors.right: parent.right
                anchors.rightMargin: Commons.Style.barPadding
                anchors.verticalCenter: parent.verticalCenter
                spacing: Commons.Style.spacingSm

                BarSection {
                    section: "tray"
                    entries: Config.layout.tray
                    registry: root.registry
                    barWindow: bar
                    barScreen: bar.screen
                }

                BarSection {
                    section: "right"
                    entries: Config.layout.right
                    registry: root.registry
                    barWindow: bar
                    barScreen: bar.screen
                }
            }
        }
    }
}
