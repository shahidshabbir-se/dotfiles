import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.configuration

RowLayout {
    spacing: 6

    readonly property var batteryDevice: UPower.devices.values.find(
        device => device.isLaptopBattery && device.isPresent
    ) || null
    readonly property bool hasBattery: batteryDevice !== null && batteryDevice.ready
    readonly property int level: hasBattery ? Math.round(batteryDevice.percentage) : 0

    visible: hasBattery

    function batteryColor(percent) {
        if (percent >= 50) return Colors.batteryHealthy
        if (percent >= 30) return Colors.batteryMedium
        return Colors.batteryLow
    }

    Item {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 12

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: 16
            height: 10
            radius: 2
            color: "transparent"
            border.color: batteryColor(level)
            border.width: 1.2

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 1.5
                width: Math.max(0, (parent.width - 3) * (level / 100))
                radius: 1
                color: batteryColor(level)
                opacity: 0.85
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 5
            radius: 1
            color: batteryColor(level)
        }
    }

    Text {
        text: level + "%"
        font.family: "Cartograph CF"
        font.pixelSize: 14
        color: Colors.textPrimary
    }
}
