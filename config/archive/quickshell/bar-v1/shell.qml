//@ pragma Env QT_SCALE_FACTOR=1.0
//@ pragma IconTheme Papirus-Dark
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import 'components' as Components
import qs.configuration

Scope {
  id: root

  property bool barVisible: true

  IpcHandler {
    target: "bar"

    function toggleBar(): void { root.barVisible = !root.barVisible }
    function showBar(): void { root.barVisible = true }
    function hideBar(): void { root.barVisible = false }
  }

  MouseArea {
    anchors.fill: parent
    onWheel: wheel => {
      Hyprland.dispatch("workspace 1")
      Mpris.players.values.forEach((player, idx) => player.pause())
    }
  }

  Components.PopoutVolume {}

  WlrLayershell {
    id: bar
    namespace: "quickshell_bar"
    margins { top: 10; bottom: 10; left: 8 }
    anchors { top: true; bottom: true; left: true }
    visible: root.barVisible
    
    layer: WlrLayer.Top

    implicitWidth: 44
    color: "transparent"

    MouseArea {
      anchors.fill: parent
      onWheel: wheel => {
        Hyprland.dispatch("workspace 1")
        Mpris.players.values.forEach((player, idx) => player.pause())
      }
    }

    // The actual bar - Extra rect to achieve bar-rounding
    Rectangle {
      id: barBackground
      anchors.fill: parent
      color: Colors.barBackground
      radius: 4

      border.width: 0

      Behavior on height {
        NumberAnimation {
          duration: 1000
          easing.type: Easing.InOutQuart
        }
      }

      ColumnLayout {
        id: barContent
        anchors { fill: parent; topMargin: 3; bottomMargin: 6; leftMargin: 3; rightMargin: 3 }
        spacing: 4

        TopSection {}
        CenterSection {}
        BottomSection {}
      }
    }
  }
}
