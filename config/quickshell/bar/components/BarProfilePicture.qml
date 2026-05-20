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
import "." as Components
import qs.configuration

Rectangle {
  Layout.alignment: Qt.AlignHCenter
  Layout.topMargin: 4//2
  Layout.bottomMargin: 2//2
  width: 26//32
  height: 26//32
  radius: innerModulesRadius
  color: Colors.barBackground
  clip: true

  Components.AppLauncher { id: appLauncher }

  Image {
    anchors.centerIn: parent
    width: 20
    height: 20
    source: "../svg/nix-snowflake-colours.svg"
    sourceSize.width: 40
    sourceSize.height: 40
    fillMode: Image.PreserveAspectFit
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: appLauncher.toggle()
  }

//  Rectangle {
//    anchors.centerIn: parent
//    radius: 8
//    width: 26
//    height: 24
//    clip: true
//    color: "transparent"
//
//  }
}
