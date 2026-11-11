pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../../Commons"
import "Format.js" as Format

Item {
    id: root

    required property var notification
    property int defaultTimeoutMs: 6000

    readonly property string appName:
        Format.cleanSingleLine(notification ? notification.appName : "", 128)
            || "Notification"
    readonly property string summary:
        Format.cleanSingleLine(notification ? notification.summary : "", 512)
            || "Notification"
    readonly property string body:
        Format.cleanBody(notification ? notification.body : "")
    readonly property bool critical: notification
        ? notification.urgency === NotificationUrgency.Critical
        : false
    readonly property var actions:
        Format.actionList(notification ? notification.actions : [], 3)
    readonly property string iconSource: Format.iconSource(
        notification ? notification.appIcon : "",
        notification ? notification.image : "",
        function(name) {
            return Quickshell.iconPath(name, true)
        }
    )
    readonly property int timeoutMs: Format.toastTimeout(
        notification ? notification.expireTimeout : -1,
        critical,
        defaultTimeoutMs
    )
    readonly property bool hovered: hoverHandler.hovered

    implicitHeight: surface.height
    height: implicitHeight

    function invokeAction(action) {
        if (!action)
            return
        action.invoke()
        notification.dismiss()
    }

    Rectangle {
        id: surface

        width: root.width
        height: layout.implicitHeight + Style.spacingLg * 2
        radius: 8
        color: Color.surface
        border.width: 1
        border.color: root.critical ? Color.red : Color.outline

        ColumnLayout {
            id: layout

            anchors {
                fill: parent
                margins: Style.spacingLg
            }
            spacing: Style.spacingSm

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMd

                Item {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    Layout.alignment: Qt.AlignTop

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Color.surfaceHigh

                        Text {
                            anchors.centerIn: parent
                            visible: iconImage.status !== Image.Ready
                            text: root.appName.charAt(0).toUpperCase() || "?"
                            color: Color.blue
                            font {
                                family: Style.fontFamily
                                pixelSize: Style.fontSizeLg
                                weight: Font.DemiBold
                            }
                        }
                    }

                    Image {
                        id: iconImage

                        anchors {
                            fill: parent
                            margins: 3
                        }
                        visible: status === Image.Ready
                        source: root.iconSource
                        sourceSize {
                            width: 76
                            height: 76
                        }
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        smooth: true
                        mipmap: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.appName
                        color: Color.comment
                        font {
                            family: Style.fontFamily
                            pixelSize: Style.fontSizeSm
                            weight: Font.Medium
                        }
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.summary
                        color: Color.foregroundBright
                        font {
                            family: Style.fontFamily
                            pixelSize: Style.fontSizeMd
                            weight: Font.DemiBold
                        }
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 2
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.body.length > 0
                        text: root.body
                        color: Color.foreground
                        font {
                            family: Style.fontFamily
                            pixelSize: Style.fontSizeSm
                        }
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        maximumLineCount: 6
                        lineHeight: 1.15
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Style.spacingXs
                visible: root.actions.length > 0
                spacing: Style.spacingSm

                Repeater {
                    model: root.actions

                    Rectangle {
                        id: actionButton

                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: Style.widgetRadius
                        color: actionArea.containsMouse
                            ? Color.selection
                            : Color.surfaceHigh

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 16
                            text: Format.cleanSingleLine(actionButton.modelData.text, 64)
                            color: Color.blue
                            font {
                                family: Style.fontFamily
                                pixelSize: Style.fontSizeSm
                                weight: Font.Medium
                            }
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        MouseArea {
                            id: actionArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.invokeAction(actionButton.modelData)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            margins: 6
        }
        width: 20
        height: 20
        radius: 4
        color: closeArea.containsMouse ? Color.selection : "transparent"

        Text {
            anchors.centerIn: parent
            text: "×"
            color: Color.comment
            font {
                family: Style.fontFamily
                pixelSize: Style.fontSizeMd
            }
            textFormat: Text.PlainText
        }

        MouseArea {
            id: closeArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.notification.dismiss()
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    Timer {
        interval: Math.max(1, root.timeoutMs)
        running: root.timeoutMs > 0 && !root.hovered
        repeat: false
        onTriggered: root.notification.expire()
    }
}
