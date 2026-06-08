import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import qs.configuration

Rectangle {
  Layout.alignment: Qt.AlignHCenter
  implicitHeight: Math.max(46, workspaceIds.length * 12 + 58)
  width: 24
  radius: 2
  color: (hoverHandler.hovered) ? Colors.workspaceBackgroundHover : Colors.moduleBackground

  property var workspaceIds: []
  property int activeWorkspaceId: 0

  function refreshWorkspaces() {
    workspacesProcess.running = true
    activeWorkspaceProcess.running = true
  }

  HoverHandler { id: hoverHandler }

  Component.onCompleted: refreshWorkspaces()

  Process {
    id: workspacesProcess
    running: false
    command: ["hyprctl", "-i", "0", "-j", "workspaces"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          let parsed = JSON.parse(text)
          workspaceIds = parsed
            .map(workspace => workspace.id)
            .filter(id => id > 0)
            .sort((a, b) => a - b)
        } catch (e) {
          workspaceIds = []
        }
      }
    }
  }

  Process {
    id: activeWorkspaceProcess
    running: false
    command: ["hyprctl", "-i", "0", "-j", "activeworkspace"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          activeWorkspaceId = JSON.parse(text).id ?? 0
        } catch (e) {
          activeWorkspaceId = 0
        }
      }
    }
  }

  Process {
    id: workspaceDispatchProcess
    running: false
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: refreshWorkspaces()
  }

  border.width: 1
  border.color: (hoverHandler.hovered) ? Colors.workspaceBorderHover : Colors.moduleBorder

  Behavior on border.color {
    ColorAnimation { duration: 400 }
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 3

    ColumnLayout {
      spacing: -3

      Repeater {
        model: workspaceIds

        Item {
          id: segment
          required property int modelData
          property bool hovered: false
          property bool active: modelData === activeWorkspaceId

          width: 12
          Layout.preferredHeight: active ? 40 : 15
          Layout.alignment: Qt.AlignHCenter

          Shape {
            id: slantShape
            anchors.centerIn: parent
            width: 8
            height: parent.height
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

              startX: 0
              startY: 6

              PathLine { x: slantShape.width; y: 0 }
              PathLine { x: slantShape.width; y: slantShape.height - 6 }
              PathLine { x: 0; y: slantShape.height }
              PathLine { x: 0; y: 6 }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              workspaceDispatchProcess.command = ["hyprctl", "-i", "0", "dispatch", "workspace", modelData.toString()]
              workspaceDispatchProcess.running = true
            }

            hoverEnabled: true
            onEntered: { parent.hovered = true }
            onExited: { parent.hovered = false }
          }
        }
      }
    }
  }
}
