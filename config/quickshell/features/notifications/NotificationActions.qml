pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.shared.theme
import "NotificationText.js" as NotificationText

RowLayout {
    id: root

    required property var actions

    spacing: Constants.spacingMd
    implicitHeight: NotificationMetrics.actionHeight

    Repeater {
        model: Math.min(3, root.actions.length)

        Rectangle {
            id: actionButton

            required property int index

            readonly property var action: root.actions[index]

            Layout.fillWidth: true
            Layout.preferredHeight: NotificationMetrics.actionHeight
            radius: NotificationMetrics.controlRadius
            color: actionArea.containsMouse
                ? index === 0
                    ? Tokens.withAlpha(Colors.primary, 0.18)
                    : Tokens.whitePress
                : Tokens.whiteSubtle
            scale: actionArea.pressed ? 0.975 : 1

            Behavior on color {
                ColorAnimation { duration: Constants.animationFast }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Constants.animationFast
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 18
                text: NotificationText.singleLine(actionButton.action.text, 64)
                color: actionButton.index === 0
                    ? Colors.primary
                    : Colors.surfaceForeground
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeSm
                font.weight: Font.DemiBold
                textFormat: Text.PlainText
                maximumLineCount: 1
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            MouseArea {
                id: actionArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: actionButton.action.invoke()
            }
        }
    }
}
