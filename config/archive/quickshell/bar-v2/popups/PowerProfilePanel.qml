import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Wayland
import qs.configuration
import "."

Scope {
    id: root
    property bool open: false
    property var barRef: null

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null
    readonly property var profiles: [
        { name: "Performance", description: "Maximum responsiveness and power use", icon: "⚡", value: PowerProfile.Performance, available: PowerProfiles.hasPerformanceProfile },
        { name: "Balanced", description: "Balance performance and energy use", icon: "◐", value: PowerProfile.Balanced, available: true },
        { name: "Power Saver", description: "Reduce power use and extend battery life", icon: "♻", value: PowerProfile.PowerSaver, available: true },
    ]

    signal closed()
    function close() {
        if (open)
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
                WlrLayershell.namespace: "quickshell_power_profile_popup"
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

                anchors { top: true; right: true }
                margins {
                    top: BarMetrics.popupTopMargin
                    right: root.activeScreen ? Math.max(120, Math.round(root.activeScreen.width * 0.125)) : 120
                }

                implicitWidth: 340
                implicitHeight: 252
                width: implicitWidth
                height: implicitHeight
                onVisibleChanged: if (visible) popupFocus.refocus()

                PopupFocusHost {
                    id: popupFocus
                    active: root.open
                    anchors.fill: parent
                    onEscapePressed: root.close()

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: Colors.notificationPanelBackground
                        border.width: 1
                        border.color: Colors.notificationPanelBorder

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Text {
                                text: "Power mode"
                                font.family: "Outfit"
                                font.pixelSize: 19
                                font.weight: Font.DemiBold
                                color: Colors.textPrimary
                            }

                            Text {
                                visible: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
                                text: "Performance is limited: " + PerformanceDegradationReason.toString(PowerProfiles.degradationReason)
                                font.family: "Outfit"
                                font.pixelSize: 12
                                color: Colors.batteryMedium
                            }

                            Repeater {
                                model: root.profiles

                                Rectangle {
                                    id: profileRow
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 52
                                    radius: 10
                                    enabled: modelData.available
                                    opacity: enabled ? 1 : 0.45
                                    color: PowerProfiles.profile === modelData.value
                                        ? Colors.workspaceActiveBg
                                        : (rowHover.hovered ? Colors.moduleBackgroundHover : Colors.moduleBackground)
                                    border.width: 1
                                    border.color: PowerProfiles.profile === modelData.value ? Colors.workspaceActive : Colors.moduleBorder

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 11

                                        Text { text: profileRow.modelData.icon; font.pixelSize: 18; color: Colors.textPrimary }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                text: profileRow.modelData.name
                                                font.family: "Outfit"
                                                font.pixelSize: 14
                                                font.weight: Font.DemiBold
                                                color: Colors.textPrimary
                                            }
                                            Text {
                                                text: profileRow.modelData.available ? profileRow.modelData.description : "Not supported by this hardware"
                                                font.family: "Outfit"
                                                font.pixelSize: 11
                                                color: Colors.textSecondary
                                            }
                                        }

                                        Rectangle {
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: PowerProfiles.profile === profileRow.modelData.value ? Colors.workspaceActive : "transparent"
                                            border.width: 1
                                            border.color: PowerProfiles.profile === profileRow.modelData.value ? Colors.workspaceActive : Colors.textMuted
                                            Rectangle {
                                                visible: PowerProfiles.profile === profileRow.modelData.value
                                                anchors.centerIn: parent
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: Colors.workspaceActiveText
                                            }
                                        }
                                    }

                                    HoverHandler { id: rowHover }
                                    TapHandler {
                                        enabled: profileRow.enabled
                                        onTapped: PowerProfiles.profile = profileRow.modelData.value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
