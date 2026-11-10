import QtQuick
import qs.Commons as Commons
import qs.Ui as Ui

// Bar indicator for the notification service. Left-click opens or closes the
// center; right-click toggles do-not-disturb. Both paths use the same store as
// the IPC targets, so the bar and bindings cannot drift apart.
Ui.BarWidget {
    id: root

    Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        Row {
            id: row

            anchors.centerIn: parent
            spacing: Commons.Style.spacingXs

            Text {
                text: NotificationStore.dnd ? "\uf1f6" : "\uf0f3"
                color: NotificationStore.dnd
                    ? Commons.Color.yellow
                    : NotificationStore.centerOpen ? Commons.Color.blue : Commons.Color.foreground
                font {
                    family: Commons.Style.monoFontFamily
                    pixelSize: Commons.Style.fontSizeLg
                }
                textFormat: Text.PlainText
            }

            Text {
                visible: NotificationStore.dnd
                text: "DND"
                color: Commons.Color.yellow
                font {
                    family: Commons.Style.fontFamily
                    pixelSize: Commons.Style.fontSizeSm
                    weight: Font.DemiBold
                }
                textFormat: Text.PlainText
            }

            Rectangle {
                visible: NotificationStore.unread > 0
                width: Math.max(16, unreadLabel.implicitWidth + 8)
                height: 16
                radius: 8
                color: Commons.Color.blue

                Text {
                    id: unreadLabel

                    anchors.centerIn: parent
                    text: NotificationStore.unread > 99 ? "99+" : NotificationStore.unread.toString()
                    color: Commons.Color.background
                    font {
                        family: Commons.Style.fontFamily
                        pixelSize: Commons.Style.fontSizeSm
                        weight: Font.Bold
                    }
                    textFormat: Text.PlainText
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    NotificationStore.toggleDnd();
                else
                    NotificationStore.toggleCenter();
            }
        }
    }
}
