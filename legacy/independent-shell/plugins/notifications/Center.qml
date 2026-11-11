pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../Commons"
import "Format.js" as Format

// Full notification center. The service loads one instance for the active
// screen; opening the center is the only thing that clears the unread count.
//
// The linter reports PanelWindow as non-creatable because Quickshell's qmltypes
// describe the internal proxy; it is creatable at runtime.
// qmllint disable uncreatable-type
PanelWindow {
    id: root

    property var panelScreen: null

    readonly property int padding: Style.spacingLg
    readonly property int maxBodyHeight: screen
        ? Math.max(120, screen.height - Style.barHeight - Style.spacingMd * 2 - 96)
        : 480
    readonly property int bodyHeight: Math.min(listColumn.implicitHeight, maxBodyHeight)

    screen: root.panelScreen
    visible: NotificationStore.centerOpen
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    // qmllint disable unresolved-type unqualified
    margins {
        top: Style.barHeight + Style.spacingMd
        right: Style.spacingMd
    }
    // qmllint enable unresolved-type unqualified

    implicitWidth: screen
        ? Math.min(380, Math.max(1, screen.width - Style.spacingMd * 2))
        : 380
    implicitHeight: content.implicitHeight + root.padding * 2
    exclusiveZone: 0
    aboveWindows: true
    focusable: NotificationStore.centerOpen

    WlrLayershell.namespace: "qs-notification-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Color.surface
        radius: Style.widgetRadius
        border.width: 1
        border.color: Color.outline
    }

    Column {
        id: content

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: root.padding
            leftMargin: root.padding
            rightMargin: root.padding
        }
        spacing: Style.spacingMd

        RowLayout {
            id: header

            width: parent.width
            height: 28
            spacing: Style.spacingSm

            Text {
                text: "Notifications"
                color: Color.foregroundBright
                font {
                    family: Style.fontFamily
                    pixelSize: Style.fontSizeLg
                    weight: Font.DemiBold
                }
                textFormat: Text.PlainText
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Rectangle {
                visible: NotificationStore.history.length > 0
                Layout.preferredWidth: clearLabel.implicitWidth + 16
                Layout.preferredHeight: 24
                radius: Style.widgetRadius
                color: clearArea.containsMouse ? Color.selection : Color.surfaceHigh

                Text {
                    id: clearLabel

                    anchors.centerIn: parent
                    text: "Clear"
                    color: Color.foreground
                    font {
                        family: Style.fontFamily
                        pixelSize: Style.fontSizeSm
                        weight: Font.Medium
                    }
                    textFormat: Text.PlainText
                }

                MouseArea {
                    id: clearArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationStore.clear()
                }
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: Style.widgetRadius
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
                    onClicked: NotificationStore.closeCenter()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Color.outline
        }

        Flickable {
            id: body

            width: parent.width
            height: root.bodyHeight
            contentHeight: listColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listColumn

                width: body.width
                spacing: Style.spacingSm

                Repeater {
                    model: NotificationStore.history

                    Rectangle {
                        id: row

                        required property var modelData

                        readonly property string timeText: {
                            const stamp = Number(row.modelData.timestamp);
                            return stamp > 0 ? Qt.formatDateTime(new Date(stamp), "HH:mm") : "";
                        }

                        width: listColumn.width
                        height: rowLayout.implicitHeight + Style.spacingLg * 2
                        radius: Style.widgetRadius
                        color: Color.surfaceHigh

                        ColumnLayout {
                            id: rowLayout

                            anchors {
                                fill: parent
                                margins: Style.spacingLg
                            }
                            spacing: Style.spacingXs

                            RowLayout {
                                Layout.fillWidth: true

                                spacing: Style.spacingSm

                                Text {
                                    Layout.fillWidth: true
                                    text: Format.cleanSingleLine(row.modelData.appName, 128)
                                        || "Notification"
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
                                    text: row.timeText
                                    color: Color.comment
                                    font {
                                        family: Style.monoFontFamily
                                        pixelSize: Style.fontSizeSm
                                    }
                                    textFormat: Text.PlainText
                                }

                                Rectangle {
                                    Layout.preferredWidth: 18
                                    Layout.preferredHeight: 18
                                    radius: 3
                                    color: entryCloseArea.containsMouse ? Color.selection : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: Color.comment
                                        font {
                                            family: Style.fontFamily
                                            pixelSize: Style.fontSizeSm
                                        }
                                        textFormat: Text.PlainText
                                    }

                                    MouseArea {
                                        id: entryCloseArea

                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: NotificationStore.remove(row.modelData.id)
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: Format.cleanSingleLine(row.modelData.summary, 512)
                                    || "Notification"
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
                                visible: String(row.modelData.body || "").length > 0
                                text: String(row.modelData.body || "")
                                color: Color.foreground
                                font {
                                    family: Style.fontFamily
                                    pixelSize: Style.fontSizeSm
                                }
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 5
                                lineHeight: 1.15
                            }
                        }
                    }
                }

                Text {
                    width: listColumn.width
                    height: 48
                    visible: NotificationStore.history.length === 0
                    text: "No notifications"
                    color: Color.comment
                    font {
                        family: Style.fontFamily
                        pixelSize: Style.fontSizeSm
                    }
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
// qmllint enable uncreatable-type
