import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../widgets" as Widgets
import qs.configuration

Scope {
    id: root
    property bool barVisible: true
    property int notificationUnreadCount: 0
    property var screenWindows: ({})

    signal toggleMusicPlayer()
    signal toggleNotifications()
    signal toggleLauncher()
    signal toggleDateTime()

    function windowForScreen(screen) {
        if (!screen)
            return null
        return screenWindows[screen.name] ?? null
    }

    function registerBarWindow(screenName, window) {
        const next = Object.assign({}, screenWindows)
        next[screenName] = window
        screenWindows = next
    }

    function unregisterBarWindow(screenName) {
        if (!screenWindows.hasOwnProperty(screenName))
            return
        const next = Object.assign({}, screenWindows)
        delete next[screenName]
        screenWindows = next
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData

            screen: modelData
            visible: root.barVisible

            Component.onCompleted: root.registerBarWindow(modelData.name, barWindow)
            Component.onDestruction: root.unregisterBarWindow(modelData.name)

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: BarMetrics.barTopMargin
                left: Math.round(modelData.width * (1 - BarMetrics.barWidthRatio) / 2)
                right: Math.round(modelData.width * (1 - BarMetrics.barWidthRatio) / 2)
            }

            implicitHeight: BarMetrics.barVisualHeight
            color: "transparent"
            WlrLayershell.namespace: "quickshell_bar"

            Rectangle {
                id: barBackground
                anchors.fill: parent
                radius: 10
                color: Colors.barBackground
                border.width: 0

                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    RowLayout {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Widgets.LauncherButton {
                            onTogglePopup: root.toggleLauncher()
                        }
                        Widgets.BarSeparator {}
                        Widgets.ActiveWindow {}
                    }

                    Widgets.HyprlandWorkspaces {
                        anchors.centerIn: parent
                    }

                    RowLayout {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Widgets.BatteryStatus {}
                        Widgets.BarSeparator {}
                        Widgets.NotificationButton {
                            unreadCount: root.notificationUnreadCount
                            onTogglePopup: root.toggleNotifications()
                        }
                        Widgets.MediaPlayer {
                            onTogglePopup: root.toggleMusicPlayer()
                        }
                        Widgets.BarSeparator {}
                        Widgets.DateTime {
                            onTogglePopup: root.toggleDateTime()
                        }
                        Widgets.BarSeparator {}
                        Widgets.PowerButton {}
                    }
                }
            }
        }
    }
}
