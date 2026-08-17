import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.shared.theme

GridLayout {
    id: workspaces

    property bool vertical: false
    property int refreshAttempts: 0

    columns: vertical ? 1 : -1
    rows: vertical ? -1 : 1
    columnSpacing: Constants.spacingXs
    rowSpacing: Constants.spacingXs

    Component.onCompleted: workspaceRefresh.start()

    Timer {
        id: workspaceRefresh

        interval: Constants.workspaceRefreshInterval
        repeat: true

        onTriggered: {
            Hyprland.refreshWorkspaces()
            workspaces.refreshAttempts++

            if (
                Hyprland.workspaces.values.length > 0
                || workspaces.refreshAttempts >= Constants.workspaceRefreshAttempts
            ) {
                stop()
            }
        }
    }

    Repeater {
        model: Hyprland.workspaces.values

        delegate: Rectangle {
            required property var modelData

            Layout.preferredWidth: Constants.buttonSize
            Layout.preferredHeight: Constants.buttonSize
            Layout.leftMargin: workspaces.vertical
                ? Math.max(0, (workspaces.width - Constants.buttonSize) / 2)
                : 0
            Layout.rightMargin: Layout.leftMargin

            radius: Constants.buttonRadius

            color: modelData.focused
                ? Colors.primaryContainer
                : "transparent"

            Text {
                anchors.centerIn: parent

                text: modelData.id

                color: modelData.focused
                    ? Colors.primaryContainerForeground
                    : Colors.surfaceForeground

                font {
                    family: Constants.fontFamily
                    pixelSize: Constants.fontSizeMd
                    weight: modelData.focused
                        ? Font.DemiBold
                        : Font.Medium
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: modelData.activate()
            }
        }
    }
}
