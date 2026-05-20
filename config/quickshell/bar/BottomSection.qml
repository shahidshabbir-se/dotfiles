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

Rectangle {
  Layout.fillWidth: true
  Layout.preferredHeight: 234
  Layout.minimumHeight: 234
  Layout.maximumHeight: 234
  implicitHeight: 234
  color: "transparent"
  
  property real innerModulesRadius: 3

  // Date/time formatting
  property string currentTime: Qt.formatDateTime(new Date(), "hh:mm")
  property string currentHours: Qt.formatDateTime(new Date(), "hh")
  property string currentMinutes: Qt.formatDateTime(new Date(), "mm")

  property string username: ""

  Process {
    command: ["whoami"]
    running: true
    stdout: SplitParser { onRead: name => username = name }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      currentTime = Qt.formatDateTime(new Date(), "hh:mm")
      currentHours = Qt.formatDateTime(new Date(), "hh")
      currentMinutes = Qt.formatDateTime(new Date(), "mm")
    }
  }

  ColumnLayout {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 2
    spacing: 6

    // Components.BarInternetStatus {}
    Item {
      Layout.alignment: Qt.AlignHCenter
      Layout.preferredWidth: 28
      Layout.minimumWidth: 28
      Layout.maximumWidth: 28
      Layout.preferredHeight: 120
      Layout.minimumHeight: 120
      Layout.maximumHeight: 120
      clip: false

      Components.Player {
        anchors.fill: parent
      }
    }
    Components.BarBatteryInternet {}
    Components.Power {}

//// Time module
//    Rectangle {
//      Layout.alignment: Qt.AlignHCenter
//      width: 24
//      height: 40
//      radius: 2
//      color: Colors.moduleBackground
//
//      ColumnLayout {
//        anchors.centerIn: parent
//        spacing: 0
//
//        Text {
//          Layout.alignment: Qt.AlignHCenter
//          text: currentHours
//          color: Colors.timeText
//          font.family: "Cartograph CF Heavy"
//          font.pixelSize: 11
//        }
//
//        Text {
//          Layout.alignment: Qt.AlignHCenter
//          text: currentMinutes
//          color: Colors.timeText
//          font.family: "Cartograph CF Heavy"
//          font.pixelSize: 11
//        }
//      }
//    }
  }
}
