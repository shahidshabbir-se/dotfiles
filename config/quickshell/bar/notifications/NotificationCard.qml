import QtQuick
import QtQuick.Layouts
import qs.configuration
import "."

Rectangle {
    id: root

    required property var entry
    required property var formatClockTime

    signal activated(var id)

    readonly property var source: entry.ref ?? entry
    readonly property string displaySummary: source.summary ?? ""
    readonly property string displayBody: source.body ?? ""
    readonly property bool unread: !(entry.read ?? false)

    width: parent ? parent.width : 328
    radius: 10
    color: cardHover.hovered ? Colors.notificationCardHover : Colors.notificationCardBackground
    implicitHeight: cardRow.implicitHeight + 20

    RowLayout {
        id: cardRow
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        NotificationIcon {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: root.source
            size: 32
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: displaySummary
                font.family: "Outfit"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Colors.textPrimary
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                visible: displayBody.length > 0
                text: displayBody
                font.family: "Outfit"
                font.pixelSize: 12
                color: Colors.textSecondary
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }
        }

        Text {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 1
            text: formatClockTime(entry.receivedAt)
            font.family: "Outfit"
            font.pixelSize: 11
            color: Colors.textMuted
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 7
            Layout.preferredHeight: 7
            radius: 3.5
            visible: unread
            color: Colors.notificationUnreadDot
        }
    }

    HoverHandler { id: cardHover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(entry.id)
    }
}
