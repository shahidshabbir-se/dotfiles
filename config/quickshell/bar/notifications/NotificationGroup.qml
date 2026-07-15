import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.configuration
import "."

ColumnLayout {
    id: root

    required property string appName
    required property string appIcon
    required property var items
    required property bool collapsed
    required property var formatClockTime
    required property var activateHandler
    required property var toggleCollapsed

    spacing: 6

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        radius: 8
        color: headerHover.hovered ? Colors.notificationCardHover : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: appName
                font.family: "Outfit"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Colors.textPrimary
                elide: Text.ElideRight
            }

            Text {
                text: items.length
                font.family: "Outfit"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Colors.textMuted
            }

            Text {
                text: collapsed ? "\u25be" : "\u25b4"
                font.family: "Outfit"
                font.pixelSize: 10
                color: Colors.textMuted
            }
        }

        HoverHandler { id: headerHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleCollapsed(appName)
        }
    }

    ListView {
        id: cardsList
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        interactive: false
        spacing: 6

        model: ScriptModel {
            objectProp: "id"
            values: {
                if (!items || items.length === 0)
                    return []
                if (collapsed)
                    return [items[0]]
                return items
            }
        }

        delegate: NotificationCard {
            required property var modelData

            width: root.width > 0 ? root.width : cardsList.width
            entry: modelData
            formatClockTime: root.formatClockTime
            onActivated: id => root.activateHandler(id)
        }
    }
}
