import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Hyprland
import qs.configuration

Item {
    id: root

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace?.id ?? 0
    property var workspaceIds: []

    function updateWorkspaceIds() {
        const values = Hyprland.workspaces?.values ?? []
        workspaceIds = values
            .map(ws => ws.id)
            .filter(id => id > 0)
            .sort((a, b) => a - b)
    }

    Component.onCompleted: updateWorkspaceIds()

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { root.updateWorkspaceIds() }
    }

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 4

        RowLayout {
            spacing: -3

            Repeater {
                model: workspaceIds

                Item {
                    id: segment
                    required property int modelData
                    property bool hovered: false
                    property bool active: modelData === root.activeWorkspaceId

                    height: 15
                    Layout.preferredWidth: active ? 52 : 20
                    Layout.alignment: Qt.AlignVCenter

                    Shape {
                        id: slantShape
                        anchors.centerIn: parent
                        width: parent.width
                        height: 10
                        antialiasing: true
                        smooth: true
                        layer.enabled: true
                        layer.samples: 8

                        ShapePath {
                            fillColor: segment.active
                                ? Colors.workspaceActive
                                : segment.hovered
                                    ? Colors.workspaceHover
                                    : Colors.workspaceInactive
                            strokeColor: "transparent"
                            strokeWidth: 0

                            startX: 6
                            startY: 0

                            PathLine { x: slantShape.width; y: 0 }
                            PathLine { x: slantShape.width - 6; y: slantShape.height }
                            PathLine { x: 0; y: slantShape.height }
                            PathLine { x: 6; y: 0 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: segment.hovered = true
                        onExited: segment.hovered = false
                        onClicked: Hyprland.dispatch("workspace " + modelData)
                    }
                }
            }
        }
    }
}
