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
    columnSpacing: 2
    rowSpacing: 2

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

        delegate: Item {
            required property var modelData

            Layout.preferredWidth: Constants.buttonSize
            Layout.preferredHeight: Constants.buttonSize
            Layout.leftMargin: workspaces.vertical
                ? Math.max(0, (workspaces.width - Constants.buttonSize) / 2)
                : 0
            Layout.rightMargin: Layout.leftMargin

            // Active: filled square. Others: number.
            Rectangle {
                visible: modelData.focused
                anchors.centerIn: parent
                width: Constants.spacingLg
                height: Constants.spacingLg
                color: Colors.primary
                radius: Constants.panelRadius
            }

            Text {
                visible: !modelData.focused
                anchors.centerIn: parent
                text: modelData.id
                color: Colors.surfaceForeground
                font {
                    family: Constants.fontFamily
                    pixelSize: Constants.fontSizeMd
                    weight: Font.Medium
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
