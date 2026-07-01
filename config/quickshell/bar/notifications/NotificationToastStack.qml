import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.configuration
import "."

Scope {
    id: root

    property var toastEntries: []
    property bool panelOpen: false
    property var screen: null

    readonly property int maxVisible: 3

    signal toastActivated(var entry)
    signal toastDismissed(var id)
    signal toastExpired(var id)

    LazyLoader {
        active: root.toastEntries.length > 0 && !root.panelOpen && root.screen !== null

        Scope {
            PanelWindow {
                screen: root.screen
                visible: true
                color: "transparent"
                aboveWindows: true
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell_notifications"

                anchors {
                    top: true
                    right: true
                }

                margins {
                    top: BarMetrics.popupTopMargin
                    right: BarMetrics.toastRightMargin
                }

                implicitWidth: BarMetrics.notificationPanelWidth
                implicitHeight: toastShell.implicitHeight
                width: implicitWidth
                height: implicitHeight

                Item {
                    id: toastShell
                    width: parent.width
                    implicitHeight: toastColumn.implicitHeight

                    Column {
                        id: toastColumn
                        width: toastShell.width
                        spacing: 10

                        Repeater {
                            model: root.toastEntries.slice(0, root.maxVisible)

                            NotificationToast {
                                required property var modelData

                                width: toastColumn.width
                                entry: modelData
                                onActivated: root.toastActivated(modelData)
                                onDismissed: root.toastDismissed(modelData.id)
                                onExpired: root.toastExpired(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
