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
import qs.configuration

Rectangle {
  id: root
  Layout.alignment: Qt.AlignHCenter
  Layout.preferredHeight: hasBattery ? 64 : 28
  Layout.minimumHeight: hasBattery ? 64 : 28
  Layout.maximumHeight: hasBattery ? 64 : 28
  width: 28
  height: hasBattery ? 64 : 28
  radius: innerModulesRadius
  color: (hoverHandler.hovered) ? Colors.moduleBackgroundHover : Colors.moduleBackground

  readonly property var batteryDevice: UPower.devices.values.find(device => device.isLaptopBattery && device.isPresent) || null
  readonly property bool hasBattery: batteryDevice !== null && batteryDevice.ready

  HoverHandler { id: hoverHandler }

  border.width: 1
  border.color: (hoverHandler.hovered) ? Colors.moduleBorderHover : Colors.moduleBorder

  Behavior on border.color {
    ColorAnimation { duration: 400 }
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 0

    // Battery Module
    QtObject {
      id: batteryModule
      readonly property real batteryLevel: root.hasBattery ? Math.round(root.batteryDevice.percentage) : 0
      readonly property real displayBatteryLevel: root.hasBattery && root.batteryDevice.state === UPowerDeviceState.Charging
        ? Math.min(100, batteryLevel + chargingAnimationIncrement)
        : batteryLevel
      property real chargingAnimationIncrement: 0

      function getBatteryColor(percent, color_type) {
        if (percent >= 50) return ((color_type == 'JUICE') ? Colors.batteryHealthyJuice : Colors.batteryHealthy)
        if (percent >= 30) return ((color_type == 'JUICE') ? Colors.batteryMediumJuice : Colors.batteryMedium)
        return ((color_type == 'JUICE') ? Colors.batteryLowJuice : Colors.batteryLow)
      }
    }

    Item {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: root.hasBattery ? 2 : 0
      Layout.preferredHeight: root.hasBattery ? 34 : 0
      Layout.minimumHeight: root.hasBattery ? 34 : 0
      Layout.maximumHeight: root.hasBattery ? 34 : 0
      visible: root.hasBattery
      width: 28
      height: root.hasBattery ? 34 : 0

      Timer {
        interval: 200
        running: root.hasBattery
        repeat: true
        onTriggered: {
          let bat_level = batteryModule.batteryLevel

          if (root.batteryDevice.state == UPowerDeviceState.Charging) {
            batteryModule.chargingAnimationIncrement += (bat_level < 85)
              ? ((bat_level < 60) ? 10 : 5)
              : 2

            batteryModule.chargingAnimationIncrement %= 101 - bat_level
          } else {
            batteryModule.chargingAnimationIncrement = 0
          }
        }
      }

      Rectangle {
        anchors.centerIn: parent
        width: 16
        height: 28
        color: "transparent"

        ColumnLayout {
          anchors.centerIn: parent
          spacing: 0

          Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 8
            height: 1
            radius: 4
            color: batteryModule.getBatteryColor(batteryModule.displayBatteryLevel, 'BORDER')
          }

          Rectangle {
            width: 14
            height: 24
            radius: 4
            color: Colors.batteryBackground
            border.color: batteryModule.getBatteryColor(batteryModule.displayBatteryLevel, 'BORDER')
            border.width: 2

            Rectangle {
              id: batteryFill
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottomMargin: 3
              anchors.leftMargin: 2
              anchors.rightMargin: 2
              width: parent.width - 6
              height: Math.max(0, (parent.height - 6) * (batteryModule.displayBatteryLevel / 100))
              radius: 1

              gradient: Gradient {
                GradientStop {
                  position: 0.0
                  color: batteryModule.getBatteryColor(batteryModule.displayBatteryLevel, 'JUICE')
                }
                GradientStop {
                  position: 1.0
                  color: batteryModule.getBatteryColor(batteryModule.displayBatteryLevel, 'JUICE')
                }
              }
            }
          }
        }
      }
    }

    // Internet Module
    QtObject {
      id: internetModule
      property bool internetConnected: false
    }

    Item {
      Layout.alignment: Qt.AlignHCenter
      width: 28
      height: 22

      Process {
        id: internetProcess
        running: true
        command: [ "ping", "-c1", "1.0.0.1" ]

        property string fullOutput: ""

        stdout: SplitParser {
          onRead: out => {
            internetProcess.fullOutput += out + "\n"
            if (out.includes("0% packet loss")) internetModule.internetConnected = true
          }
        }

        onExited: {
          internetModule.internetConnected = fullOutput.includes("0% packet loss")
          fullOutput = ""
        }
      }

      Timer {
        id: updateTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
          internetProcess.running = true
        }
      }

      Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 23
        height: 23
        source: `../svg/${internetModule.internetConnected ? 'connected' : 'disconnected'}.svg`
        sourceSize.width: 30
        sourceSize.height: 30
      }
    }
  }
}
