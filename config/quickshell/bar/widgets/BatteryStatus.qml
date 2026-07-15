import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.configuration

Rectangle {
    id: root
    signal togglePopup()

    readonly property var batteryDevice: UPower.devices.values.find(
        device => device.isLaptopBattery && device.isPresent
    ) || null
    readonly property bool hasBattery: batteryDevice !== null && batteryDevice.ready
    readonly property int level: hasBattery ? Math.round(batteryDevice.percentage) : 0
    readonly property string profileName: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance: return "Performance"
        case PowerProfile.PowerSaver: return "Power Saver"
        default: return "Balanced"
        }
    }
    readonly property string profileIcon: {
        switch (PowerProfiles.profile) {
        case PowerProfile.Performance: return ""
        case PowerProfile.PowerSaver: return ""
        default: return ""
        }
    }

    implicitWidth: content.implicitWidth + 14
    implicitHeight: 28
    radius: 7
    color: hoverHandler.hovered ? Colors.moduleBackgroundHover : "transparent"

    function batteryColor(percent) {
        if (percent >= 50) return Colors.batteryHealthy
        if (percent >= 30) return Colors.batteryMedium
        return Colors.batteryLow
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        Item {
            visible: root.hasBattery
            Layout.preferredWidth: visible ? 20 : 0
            Layout.preferredHeight: 12

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                width: 16
                height: 10
                radius: 2
                color: "transparent"
                border.color: root.batteryColor(root.level)
                border.width: 1.2

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1.5
                    width: Math.max(0, (parent.width - 3) * (root.level / 100))
                    radius: 1
                    color: root.batteryColor(root.level)
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
                color: root.batteryColor(root.level)
            }
        }

        Text {
            visible: root.hasBattery
            text: root.level + "%"
            font.family: "Outfit"
            font.pixelSize: 14
            color: Colors.textPrimary
        }

        Text {
            visible: root.hasBattery
            text: "·"
            font.pixelSize: 14
            color: Colors.textMuted
        }

        Text {
            text: root.profileIcon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            color: Colors.textSecondary
        }

        Text {
            text: root.profileName
            font.family: "Outfit"
            font.pixelSize: 13
            color: Colors.textPrimary
        }
    }

    HoverHandler { id: hoverHandler }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.togglePopup()
    }
}
